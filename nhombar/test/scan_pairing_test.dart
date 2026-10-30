import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/spatial/scan_pairing.dart';

void main() {
  final code = '${'a' * 64}.${'b' * 32}';
  String payload(String address, {String? secret, int version = 1}) =>
      jsonEncode({
        'kind': 'meomeo-scan',
        'version': version,
        'address': address,
        'code': secret ?? code,
      });
  test(
    'pairing QR accepts only private HTTPS addresses and a complete pin/key',
    () {
      expect(ScanPairing.parse(payload('https://192.168.1.2:8765')).code, code);
      for (final address in [
        'http://192.168.1.2:8765',
        'https://8.8.8.8:8765',
        'https://127.0.0.1:8765',
        'https://192.168.1.2:8765/evil',
        'https://user:password@192.168.1.2:8765',
        'https://192.168.1.2:8765?next=evil',
      ]) {
        expect(
          () => ScanPairing.parse(payload(address)),
          throwsFormatException,
        );
      }
      expect(
        () => ScanPairing.parse(
          payload('https://192.168.1.2:8765', secret: 'short'),
        ),
        throwsFormatException,
      );
      expect(
        () =>
            ScanPairing.parse(payload('https://192.168.1.2:8765', version: 2)),
        throwsFormatException,
      );
      expect(() => ScanPairing.parse('not QR JSON'), throwsFormatException);
    },
  );
}
