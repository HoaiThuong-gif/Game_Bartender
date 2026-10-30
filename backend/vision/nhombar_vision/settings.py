from pathlib import Path

RUNTIME = Path(__file__).resolve().parents[2] / '.yolo-runtime'
WEIGHTS = RUNTIME / 'models' / 'yolo26n.pt'
MODEL_URL = 'https://github.com/ultralytics/assets/releases/download/v8.4.0/yolo26n.pt'
MAX_BYTES = 8 * 1024 * 1024
MAX_PIXELS = 16_000_000
INFERENCE_TIMEOUT = 20
UPLOAD_TIMEOUT = 10
