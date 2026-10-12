"""ADB PSS samples during the native Gacha integration test (no app writes)."""
import argparse
import datetime
import json
import re
import subprocess
import time
from pathlib import Path

root = Path(__file__).resolve().parents[1]
adb = Path.home() / 'AppData/Local/Android/sdk/platform-tools/adb.exe'
parser = argparse.ArgumentParser()
parser.add_argument('--log', type=Path, default=root / 'gacha-device-test.txt')
parser.add_argument('--output', type=Path, default=root / 'gacha-memory-samples.jsonl')
args = parser.parse_args()
log = args.log
destination = args.output
with destination.open('w', encoding='utf-8') as output:
    for _ in range(100):
        raw = log.read_bytes() if log.exists() else b''
        text = raw.decode('utf-16' if raw.startswith(b'\xff\xfe') else 'utf-8', errors='replace')
        turns = re.findall(r'completed turn (\d+)/\d+', text)
        sample = subprocess.run([str(adb), 'shell', 'dumpsys', 'meminfo', 'com.example.nhom_bar'], capture_output=True, text=True, timeout=20).stdout
        total = re.search(r'TOTAL PSS:\s*(\d+)', sample)
        if total:
            record = dict(utc=datetime.datetime.now(datetime.timezone.utc).isoformat(), turn=int(turns[-1]) if turns else 0, pss_kb=int(total[1]), details=sample)
            output.write(json.dumps(record) + '\n')
            output.flush()
        if 'All tests passed' in text or 'Some tests failed' in text:
            break
        time.sleep(10)
