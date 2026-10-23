"""Install project-local MobileSAM sources/weights, retaining upstream Apache license."""
from concurrent.futures import ThreadPoolExecutor
import importlib.util
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import urllib.request

ROOT = Path(__file__).resolve().parents[1] / '.scan-runtime'
REVISION = 'f706ad9c4eb7f219c00d9050e46328518ffb65d2'
WEIGHT_SHA256 = '6dbb90523a35330fedd7f1d3dfc66f995213d81b29a5ca8108dbcdd4e37d6c2f'
REPOSITORY = 'https://api.github.com/repos/ChaoningZhang/MobileSAM'


def setup():
    if not all(importlib.util.find_spec(name) for name in ('torch', 'torchvision', 'cv2')):
        raise RuntimeError('Segmentation requires a Python 3.11 environment with torch, torchvision and OpenCV. Set SPATIAL_SEGMENT_PYTHON to its interpreter.')
    target = ROOT / 'segmentation-deps'
    if not (target / 'timm').is_dir():
        subprocess.run([sys.executable, '-m', 'pip', 'install', '--target', str(target),
                        '--no-deps', 'timm==0.9.16'], check=True)
    source = ROOT / 'mobilesam'
    source.mkdir(exist_ok=True)
    if not (source / 'revision').is_file() or (source / 'revision').read_text() != REVISION:
        request = urllib.request.Request(REPOSITORY + '/git/trees/' + REVISION + '?recursive=1',
                                         headers={'User-Agent': 'local-spatial-scan'})
        with urllib.request.urlopen(request, timeout=60) as response:
            tree = json.load(response)['tree']
        paths = [item['path'] for item in tree if item['path'] == 'LICENSE' or
                 (item['path'].startswith('mobile_sam/') and item['path'].endswith('.py'))]
        def fetch(name):
            destination = source / name
            destination.parent.mkdir(parents=True, exist_ok=True)
            urllib.request.urlretrieve('https://raw.githubusercontent.com/ChaoningZhang/MobileSAM/' +
                                       REVISION + '/' + name, destination)
        with ThreadPoolExecutor(max_workers=4) as pool:
            list(pool.map(fetch, paths))
        (source / 'revision').write_text(REVISION)
    weight = source / 'mobile_sam.pt'
    if not weight.exists() or hashlib.sha256(weight.read_bytes()).hexdigest() != WEIGHT_SHA256:
        partial = weight.with_suffix('.download')
        urllib.request.urlretrieve('https://raw.githubusercontent.com/ChaoningZhang/MobileSAM/' +
                                   REVISION + '/weights/mobile_sam.pt', partial)
        if hashlib.sha256(partial.read_bytes()).hexdigest() != WEIGHT_SHA256:
            raise RuntimeError('Incomplete MobileSAM download')
        partial.replace(weight)
    print('Local segmentation ready. MobileSAM Apache-2.0; LICENSE retained beside source.')


if __name__ == '__main__':
    setup()
