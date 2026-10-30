import io
import logging
import math
import os
import warnings
from PIL import Image, ImageOps, UnidentifiedImageError
from .labels import LABELS
from .settings import MAX_PIXELS, RUNTIME, WEIGHTS

log = logging.getLogger(__name__)


class ImageInputError(Exception):
    def __init__(self, code):
        self.code = code


def decode_image(payload, mime):
    Image.MAX_IMAGE_PIXELS = MAX_PIXELS
    try:
        with warnings.catch_warnings():
            warnings.simplefilter('error', Image.DecompressionBombWarning)
            with Image.open(io.BytesIO(payload)) as original:
                expected = {'image/jpeg': 'JPEG', 'image/png': 'PNG'}.get(mime)
                if expected is None or original.format != expected or getattr(original, 'is_animated', False):
                    raise ImageInputError('unsupported_image')
                if original.width * original.height > MAX_PIXELS:
                    raise ImageInputError('too_many_pixels')
                original.verify()
            with Image.open(io.BytesIO(payload)) as original:
                return ImageOps.exif_transpose(original).convert('RGB')
    except (Image.DecompressionBombError, Image.DecompressionBombWarning):
        raise ImageInputError('too_many_pixels') from None
    except (UnidentifiedImageError, OSError, ValueError, SyntaxError):
        raise ImageInputError('invalid_image') from None


def load_model():
    if not WEIGHTS.is_file():
        raise RuntimeError('Run python -m nhombar_vision.download_model first')
    os.environ['YOLO_CONFIG_DIR'] = str(RUNTIME / 'config')
    os.environ['YOLO_AUTOINSTALL'] = 'false'
    os.environ['YOLO_OFFLINE'] = 'true'
    import torch
    from ultralytics import YOLO, settings
    settings.update({'sync': False})
    torch.set_num_threads(min(4, os.cpu_count() or 1))
    model = YOLO(str(WEIGHTS), task='detect')
    if [model.names[i] for i in range(len(model.names))] != [name for name, _ in LABELS]:
        raise RuntimeError('Model classes do not match the supported label table')
    # Warm up once, without a user image or a saved prediction.
    predict(model, Image.new('RGB', (640, 640)))
    release_image_cache(model)
    return model


def release_image_cache(model):
    # Ultralytics keeps its latest source/results on the reusable predictor.
    # Release those image references between requests; keep model weights loaded.
    predictor = model.predictor
    if predictor is not None:
        for attribute in ('results', 'batch', 'dataset', 'plotted_img'):
            setattr(predictor, attribute, None)


def predict(model, image):
    width, height = image.size
    result = model.predict(image, imgsz=640, conf=0.25, max_det=50,
                           device='cpu', verbose=False, save=False)[0]
    detections = []
    for coordinates, score, class_id in zip(result.boxes.xyxy.cpu().tolist(),
                                             result.boxes.conf.cpu().tolist(),
                                             result.boxes.cls.cpu().tolist()):
        class_id = int(class_id)
        if not 0 <= class_id < len(LABELS) or not math.isfinite(score) or not 0 <= score <= 1:
            raise RuntimeError('Invalid model output')
        if not all(math.isfinite(value) for value in coordinates):
            raise RuntimeError('Invalid model coordinates')
        x1, y1, x2, y2 = coordinates
        box = [max(0, min(width, x1)), max(0, min(height, y1)),
               max(0, min(width, x2)), max(0, min(height, y2))]
        if box[2] <= box[0] or box[3] <= box[1]:
            continue
        english, vietnamese = LABELS[class_id]
        detections.append({'class_id': class_id, 'name_en': english, 'name_vi': vietnamese,
                           'confidence': score, 'bbox': box})
    detections.sort(key=lambda item: item['confidence'], reverse=True)
    return {'model': 'yolo26n', 'image': {'width': width, 'height': height},
            'bbox_format': 'xyxy', 'detections': detections}


def worker_loop(connection):
    """Only this process owns the model; terminating it enforces a hard timeout."""
    try:
        model = load_model()
        connection.send({'ready': True})
        while True:
            payload, mime = connection.recv()
            try:
                image = decode_image(payload, mime)
                try:
                    connection.send({'result': predict(model, image)})
                finally:
                    image.close()
                    image = None
            except ImageInputError as error:
                connection.send({'error': error.code})
            except Exception:
                log.exception('YOLO inference failed')
                connection.send({'error': 'inference_failed'})
            finally:
                release_image_cache(model)
                payload = b''
    except EOFError:
        pass
    except Exception:
        log.exception('YOLO worker stopped')
    finally:
        connection.close()
