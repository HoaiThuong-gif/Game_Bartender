"""Transport regression tests; no reconstruction libraries or phone required."""
from http.client import HTTPSConnection
from http.server import BaseHTTPRequestHandler
import ipaddress
from pathlib import Path
import ssl
import tempfile
import threading
import unittest
from unittest.mock import patch
from types import SimpleNamespace

import scan_network
from scan_network import LanIdentity, LanHTTPServer, private_address
from scan_usb import usb_devices, watch_usb


class HealthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'usb-ready')

    def log_message(self, *args):
        pass


class TransportTests(unittest.TestCase):
    def test_usb_provisioning_carries_wifi_settings_only_when_available(self):
        for lan_address in ('', 'https://192.168.1.2:8765'):
            with self.subTest(lan_address=lan_address):
                responses = [
                    SimpleNamespace(returncode=0, stdout='wired device product:test\n'),
                    SimpleNamespace(returncode=0, stdout='wired\n'),
                    SimpleNamespace(returncode=0, stdout=''),
                    SimpleNamespace(returncode=0, stdout=''),
                    SimpleNamespace(returncode=0, stdout='Broadcast completed: result=1'),
                ]
                with patch('scan_usb.find_adb', return_value='adb'), \
                     patch('scan_usb.subprocess.run', side_effect=responses) as run, \
                     patch('scan_usb.time.sleep', side_effect=RuntimeError('iteration complete')), \
                     patch('builtins.print'):
                    with self.assertRaisesRegex(RuntimeError, 'iteration complete'):
                        watch_usb(8765, 'test-pairing-code', lan_address)
                arguments = run.call_args.args[0]
                self.assertIn('test-pairing-code', arguments)
                self.assertNotIn('', arguments)
                if lan_address:
                    self.assertEqual(arguments[-3:], ['--es', 'lanAddress', lan_address])
                else:
                    self.assertNotIn('lanAddress', arguments)

    def test_bind_addresses_stay_local(self):
        self.assertEqual(str(private_address('127.0.0.1')), '127.0.0.1')
        self.assertEqual(str(private_address('192.168.1.2')), '192.168.1.2')
        for address in ('0.0.0.0', '8.8.8.8', '127.0.0.2'):
            with self.assertRaises(ValueError):
                private_address(address)

    def test_adb_selection_excludes_wireless_and_unauthorized(self):
        output = ('List of devices attached\n'
                  'wired device usb:1-2 product:test transport_id:1\n'
                  '192.168.1.2:5555 device product:test transport_id:2\n'
                  'denied unauthorized usb:1-3\n')
        self.assertEqual(usb_devices(output), ['wired'])

    def test_usb_tls_validates_loopback_and_keeps_lan_identity(self):
        # A LAN server and its USB listener use the same certificate and device tokens.
        with tempfile.TemporaryDirectory() as directory:
            fake_module = str(Path(directory) / 'tools/scan_network.py')
            with patch.object(scan_network, '__file__', fake_module):
                identity = LanIdentity('192.168.1.2', '192.168.1.0/24')
            cert = Path(directory) / '.scan-runtime/network/192.168.1.2-usb.pem'
            context = ssl.create_default_context(cafile=str(cert))
            server = LanHTTPServer(('127.0.0.1', 0), HealthHandler, identity)
            thread = threading.Thread(target=server.serve_forever, daemon=True)
            thread.start()
            try:
                connection = HTTPSConnection('127.0.0.1', server.server_port, context=context)
                try:
                    connection.request('GET', '/health')
                    self.assertEqual(connection.getresponse().read(), b'usb-ready')
                finally:
                    connection.close()
                self.assertTrue(server.verify_request(None, ('127.0.0.1', 1234)))
                self.assertFalse(server.verify_request(None, ('8.8.8.8', 1234)))
                self.assertNotEqual(identity.device_token('phone-a'), identity.device_token('phone-b'))
            finally:
                server.shutdown()
                server.server_close()
                thread.join()

    def test_usb_only_identity_needs_no_lan_and_rejects_broad_subnets(self):
        with tempfile.TemporaryDirectory() as directory:
            with patch.object(scan_network, '__file__', str(Path(directory) / 'tools/scan_network.py')):
                identity = LanIdentity('127.0.0.1', '127.0.0.1/32')
                self.assertEqual(identity.subnet, ipaddress.ip_network('127.0.0.1/32'))
                for subnet in ('0.0.0.0/0', '127.0.0.0/8', '192.168.1.0/24'):
                    with self.assertRaises(ValueError):
                        LanIdentity('127.0.0.1', subnet)


if __name__ == '__main__':
    unittest.main()
