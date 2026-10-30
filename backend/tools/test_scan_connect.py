"""Connection UX tests, without starting a reconstruction service."""
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch, MagicMock

from scan_connect import advertise, pairing_payload, write_pairing_card


class ConnectionTests(unittest.TestCase):
    def test_pairing_card_is_local_and_has_no_remote_scripts(self):
        code = 'a' * 64 + '.' + 'b' * 32
        address = 'https://192.168.1.2:8765'
        self.assertEqual(json.loads(pairing_payload(address, code)), {
            'kind': 'meomeo-scan', 'version': 1, 'address': address, 'code': code,
        })
        with tempfile.TemporaryDirectory() as directory:
            card = write_pairing_card(address, code, Path(directory) / 'pair.html')
            text = card.read_text(encoding='utf-8')
            self.assertIn('<svg', text)
            self.assertIn(code, text)
            self.assertNotIn('<script', text)
            self.assertNotIn('src="http', text)

    def test_discovery_never_announces_pairing_secret_or_token(self):
        import zeroconf
        instance = MagicMock()
        with patch.object(zeroconf, 'Zeroconf', return_value=instance):
            self.assertIs(advertise('192.168.1.2', 8765, 'server-id'), instance)
        service = instance.register_service.call_args.args[0]
        self.assertEqual(service.properties, {b'id': b'server-id', b'protocol': b'6'})
        self.assertEqual(service.port, 8765)
        self.assertEqual(service.parsed_addresses(), ['192.168.1.2'])

    def test_failed_discovery_closes_socket_owner(self):
        import zeroconf
        instance = MagicMock()
        instance.register_service.side_effect = OSError('blocked multicast')
        with patch.object(zeroconf, 'Zeroconf', return_value=instance):
            with self.assertRaises(OSError):
                advertise('192.168.1.2', 8765, 'server-id')
        instance.close.assert_called_once()


if __name__ == '__main__':
    unittest.main()
