"""Download only the official YOLO26n asset; do not run inference or training."""
import hashlib
import json
import urllib.request
from .settings import MODEL_URL, WEIGHTS


def download():
    metadata = 'https://api.github.com/repos/ultralytics/assets/releases/tags/v8.4.0'
    request = urllib.request.Request(metadata, headers={'User-Agent': 'Nhombar-Vision-MVP'})
    with urllib.request.urlopen(request, timeout=30) as response:
        release = json.load(response)
    asset = next(item for item in release['assets'] if item['name'] == 'yolo26n.pt')
    if asset['browser_download_url'] != MODEL_URL:
        raise RuntimeError('Unexpected model download source')
    digest = asset.get('digest')
    if not isinstance(digest, str) or not digest.startswith('sha256:'):
        raise RuntimeError('Official model checksum unavailable; download not performed')
    expected = digest.removeprefix('sha256:')
    if WEIGHTS.exists() and hashlib.sha256(WEIGHTS.read_bytes()).hexdigest() == expected:
        print(f'Model verified: {WEIGHTS}')
        return
    WEIGHTS.parent.mkdir(parents=True, exist_ok=True)
    partial = WEIGHTS.with_suffix('.pt.partial')
    try:
        checksum = hashlib.sha256()
        total = 0
        with urllib.request.urlopen(MODEL_URL, timeout=60) as response, partial.open('wb') as output:
            while chunk := response.read(1024 * 1024):
                total += len(chunk)
                if total > 32 * 1024 * 1024:
                    raise RuntimeError('Model download exceeds expected size')
                checksum.update(chunk)
                output.write(chunk)
        if checksum.hexdigest() != expected:
            raise RuntimeError('Model checksum mismatch')
        partial.replace(WEIGHTS)
        print(f'Official YOLO26n verified: {WEIGHTS}')
    finally:
        partial.unlink(missing_ok=True)


if __name__ == '__main__':
    download()
