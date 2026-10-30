"""Local pairing card and address discovery; never broadcasts credentials."""
import html
import io
import json
from pathlib import Path
import socket


def pairing_payload(address, code):
    return json.dumps({'kind': 'meomeo-scan', 'version': 1, 'address': address,
                       'code': code}, separators=(',', ':'))


def write_pairing_card(address, code, output):
    import qrcode
    import qrcode.image.svg
    image = qrcode.make(pairing_payload(address, code), image_factory=qrcode.image.svg.SvgPathImage,
                        box_size=10, border=4)
    svg = io.BytesIO()
    image.save(svg)
    card = ('<!doctype html><html lang="vi"><meta charset="utf-8">'
            '<meta name="viewport" content="width=device-width,initial-scale=1">'
            '<title>Kết nối máy quét 3D</title>'
            '<style>body{font:20px system-ui;max-width:600px;margin:32px auto;text-align:center;padding:16px}'
            'svg{width:min(90vw,440px);height:auto}summary{cursor:pointer}code{overflow-wrap:anywhere}</style>'
            '<h1>Kết nối máy quét 3D</h1><p>📱 Mở Quét 3D → Hướng dẫn kết nối → Quét mã kết nối.</p>'
            '<p>Điện thoại và máy tính cần cùng Wi-Fi. Giữ cửa sổ máy quét mở.</p>'
            + svg.getvalue().decode('utf-8') +
            '<p>Chỉ quét mã này bằng điện thoại của bạn. Không chia sẻ mã hoặc tệp này.</p>'
            '<details><summary>Cấu hình nâng cao</summary><p>' + html.escape(address) + '</p><code>'
            + html.escape(code) + '</code></details></html>')
    output = Path(output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(card, encoding='utf-8')
    output.chmod(0o600)
    return output


def advertise(host, port, server_id):
    from zeroconf import IPVersion, ServiceInfo, Zeroconf
    # The TXT record is public. Only a non-secret identifier goes here.
    service = ServiceInfo('_meomeo-scan._tcp.local.',
                          f'MeoMeo-{server_id[:8]}._meomeo-scan._tcp.local.',
                          addresses=[socket.inet_aton(host)], port=port,
                          properties={'id': server_id, 'protocol': '6'},
                          server=f'meomeo-{server_id[:8]}.local.')
    discovery = Zeroconf(interfaces=[host], ip_version=IPVersion.V4Only)
    try:
        discovery.register_service(service, allow_name_change=True)
    except Exception:
        discovery.close()
        raise
    return discovery
