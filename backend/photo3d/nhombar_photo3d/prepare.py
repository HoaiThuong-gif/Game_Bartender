"""Download official sources/weights once, outside version control."""
import io
import json
import os
from pathlib import Path
import urllib.request
import zipfile
from .settings import RUNTIME, SOURCE_REVISION, MCUBES_REVISION


def source(repo, revision, folder):
    marker = folder / 'revision.json'
    if marker.exists() and json.loads(marker.read_text()) == revision:
        return
    url = f'https://api.github.com/repos/{repo}/zipball/{revision}'
    with urllib.request.urlopen(url, timeout=120) as response:
        archive = zipfile.ZipFile(io.BytesIO(response.read()))
    prefix = archive.namelist()[0].split('/')[0] + '/'
    for item in archive.infolist():
        relative = item.filename[len(prefix):]
        if not relative or item.is_dir():
            continue
        path = Path(relative)
        if '..' in path.parts or path.is_absolute():
            raise ValueError('Unsafe upstream archive')
        destination = folder / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(archive.read(item))
    marker.write_text(json.dumps(revision))


def main():
    RUNTIME.mkdir(parents=True, exist_ok=True)
    os.environ['HF_HOME'] = str(RUNTIME / 'huggingface')
    os.environ['U2NET_HOME'] = str(RUNTIME / 'rembg')
    source('VAST-AI-Research/TripoSR', SOURCE_REVISION, RUNTIME / 'TripoSR')
    source('tatsy/torchmcubes', MCUBES_REVISION, RUNTIME / 'torchmcubes')
    from huggingface_hub import hf_hub_download
    for name in ('config.yaml', 'model.ckpt'):
        hf_hub_download('stabilityai/TripoSR', name, revision=MODEL_REVISION,
                        local_dir=str(RUNTIME / 'model'), local_dir_use_symlinks=False)
    hf_hub_download('facebook/dino-vitb16', 'config.json', revision=DINO_REVISION)
    refs = RUNTIME / 'huggingface/hub/models--facebook--dino-vitb16/refs'
    refs.mkdir(parents=True, exist_ok=True)
    (refs / 'main').write_text(DINO_REVISION)
    # rembg downloads its public pretrained segmentation model and checks its hash.
    import rembg
    rembg.new_session('u2netp', providers=['CPUExecutionProvider'])
    print('Official TripoSR, DINO config and foreground model are ready.')


MODEL_REVISION = '5b521936b01fbe1890f6f9baed0254ab6351c04a'
DINO_REVISION = 'f205d5d8e640a89a2b8ef0369670dfc37cc07fc2'

if __name__ == '__main__':
    main()
