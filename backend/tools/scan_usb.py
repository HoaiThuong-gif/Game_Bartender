"""Provision USB ADB tunnels on authorized, physically attached debug devices."""
import os
from pathlib import Path
import re
import shutil
import subprocess
import time


def find_adb():
    executable = shutil.which('adb')
    if executable:
        return executable
    roots = [os.environ.get('ANDROID_HOME', ''), os.environ.get('ANDROID_SDK_ROOT', '')]
    properties = Path(__file__).resolve().parents[2] / 'nhombar/android/local.properties'
    if properties.exists():
        for line in properties.read_text(encoding='utf-8').splitlines():
            if line.startswith('sdk.dir='):
                roots.append(line.split('=', 1)[1].replace('\\\\', '\\').replace('\\:', ':'))
    for root in filter(None, roots):
        path = Path(root) / 'platform-tools' / ('adb.exe' if os.name == 'nt' else 'adb')
        if path.is_file():
            return str(path)
    return None


def usb_devices(output):
    return [line.split()[0] for line in output.splitlines()
            if re.search(r'^\S+\s+device\s+.*\busb:', line)]


def watch_usb(port, pairing_code, lan_address=''):
    adb = find_adb()
    if not adb:
        print('ADB not found: USB auto-connect unavailable. Install Android platform-tools.', flush=True)
        return

    def run(*args):
        return subprocess.run([adb, *args], capture_output=True, text=True, timeout=12)

    configured = set()
    while True:
        try:
            devices = run('devices', '-l')
            if devices.returncode:
                raise OSError('ADB devices failed')
            attached = set(usb_devices(devices.stdout))
            # Windows adb may omit the usb: field. -d selects a physical USB transport only.
            physical = run('-d', 'get-serialno')
            if physical.returncode == 0 and physical.stdout.strip() not in ('', 'unknown'):
                attached.add(physical.stdout.strip())
            configured.intersection_update(attached)
            for serial in attached:
                # Re-establish the tunnel if adb/Flutter removed it while the cable stayed connected.
                tunnels = run('-s', serial, 'reverse', '--list')
                mapping = f'tcp:{port} tcp:{port}'
                if tunnels.returncode or mapping not in tunnels.stdout:
                    configured.discard(serial)
                    reverse = run('-s', serial, 'reverse', f'tcp:{port}', f'tcp:{port}')
                    if reverse.returncode:
                        continue
                if serial in configured:
                    continue
                provision = run('-s', serial, 'shell', 'am', 'broadcast', '--include-stopped-packages',
                    '-n', 'com.example.nhom_bar/.spatial.ScanUsbReceiver',
                    '-a', 'com.example.nhom_bar.SCAN_USB',
                    '--es', 'address', f'https://127.0.0.1:{port}', '--es', 'code', pairing_code,
                    *(['--es', 'lanAddress', lan_address] if lan_address else []))
                if provision.returncode == 0 and 'result=1' in provision.stdout:
                    configured.add(serial)
                    print(f'USB scanner connected: {serial} (Wi-Fi not required)', flush=True)
        except (OSError, subprocess.TimeoutExpired):
            pass  # Device reconnects and app installations are retried automatically.
        time.sleep(3)
