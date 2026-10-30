import gc
import io
import logging
import os
import struct
import sys
import warnings

from PIL import Image, ImageOps, UnidentifiedImageError
from .settings import RUNTIME, MAX_PIXELS, MAX_MESH_BYTES, MESH_RESOLUTION

log = logging.getLogger(__name__)


class InputError(Exception):
    pass


def decode_image(payload, mime):
    Image.MAX_IMAGE_PIXELS = MAX_PIXELS
    try:
        with warnings.catch_warnings():
            warnings.simplefilter('error', Image.DecompressionBombWarning)
            with Image.open(io.BytesIO(payload)) as image:
                if image.format != {'image/jpeg': 'JPEG', 'image/png': 'PNG'}.get(mime):
                    raise InputError('unsupported_image')
                if getattr(image, 'is_animated', False):
                    raise InputError('unsupported_image')
                image.verify()
            with Image.open(io.BytesIO(payload)) as image:
                return ImageOps.exif_transpose(image).convert('RGBA')
    except (Image.DecompressionBombError, Image.DecompressionBombWarning):
        raise InputError('too_many_pixels') from None
    except (UnidentifiedImageError, OSError, ValueError, SyntaxError):
        raise InputError('invalid_image') from None


def encode_native_mesh(mesh):
    """SCN1 is the existing Android viewer's big-endian triangle/color format."""
    import numpy as np
    if not 100 <= len(mesh.faces) <= 100_000:
        raise InputError('invalid_mesh')
    vertices = np.asarray(mesh.vertices, dtype=np.float32)[:, [0, 2, 1]].copy()
    vertices[:, 2] *= -1  # TripoSR Z-up -> Android Y-up.
    if not np.isfinite(vertices).all():
        raise InputError('invalid_mesh')
    low, high = vertices.min(axis=0), vertices.max(axis=0)
    size = float((high - low).max())
    if size < 1e-6:
        raise InputError('invalid_mesh')
    vertices -= (low + high) / 2
    vertices *= .3 / size
    vertices[:, 1] -= vertices[:, 1].min()
    triangles = vertices[np.asarray(mesh.faces)].reshape(-1)
    colors = np.full(triangles.shape, 190, dtype=np.float32)
    data = struct.pack('>II', 0x53434e31, len(triangles))
    data += triangles.astype('>f4').tobytes() + colors.astype('>f4').tobytes()
    if len(data) > MAX_MESH_BYTES:
        raise InputError('invalid_mesh')
    return data


def load_engine():
    os.environ['HF_HOME'] = str(RUNTIME / 'huggingface')
    os.environ['HF_HUB_OFFLINE'] = '1'
    os.environ['U2NET_HOME'] = str(RUNTIME / 'rembg')
    sys.path.insert(0, str(RUNTIME / 'TripoSR'))
    import torch
    import rembg
    from tsr.system import TSR
    torch.set_num_threads(min(4, os.cpu_count() or 1))
    model = TSR.from_pretrained(str(RUNTIME / 'model'), 'config.yaml', 'model.ckpt')
    model.eval().to('cpu')
    model.renderer.set_chunk_size(2048)
    foreground = rembg.new_session('u2netp', providers=['CPUExecutionProvider'])
    return model, foreground


def reconstruct(model, foreground, payload, mime, progress):
    import numpy as np
    import torch
    from tsr.utils import remove_background, resize_foreground
    image = decode_image(payload, mime)
    try:
        progress('preprocessing')
        cutout = remove_background(image, foreground)
        alpha = np.asarray(cutout)[:, :, 3]
        if (alpha > 127).sum() < 100:
            raise InputError('no_foreground')
        cutout = resize_foreground(cutout, .85)
        pixels = np.asarray(cutout, dtype=np.float32) / 255
        rgb = pixels[:, :, :3] * pixels[:, :, 3:4] + (1 - pixels[:, :, 3:4]) * .5
        prepared = Image.fromarray((rgb * 255).astype(np.uint8))
        progress('reconstructing')
        with torch.inference_mode():
            codes = model([prepared], device='cpu')
            progress('extracting')
            mesh = model.extract_mesh(codes, has_vertex_color=False,
                                      resolution=MESH_RESOLUTION)[0]
        progress('exporting')
        return encode_native_mesh(mesh)
    finally:
        image.close()
        gc.collect()


def worker_loop(pipe):
    try:
        model, foreground = load_engine()
        pipe.send({'ready': True})
        while True:
            payload, mime = pipe.recv()
            try:
                mesh = reconstruct(model, foreground, payload, mime,
                                   lambda stage: pipe.send({'stage': stage}))
                pipe.send({'mesh': mesh})
            except InputError as error:
                pipe.send({'error': str(error)})
            except Exception:
                log.exception('TripoSR inference failed')
                pipe.send({'error': 'inference_failed'})
            finally:
                payload = None
                mesh = None
    except (EOFError, BrokenPipeError):
        pass
    except Exception:
        log.exception('TripoSR initialization failed')
        try:
            pipe.send({'error': 'not_ready'})
        except (EOFError, BrokenPipeError):
            pass
    finally:
        pipe.close()
