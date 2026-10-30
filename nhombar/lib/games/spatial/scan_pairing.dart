import 'dart:convert';

class ScanPairing {
  const ScanPairing(this.address, this.code);
  final String address, code;
  static ScanPairing parse(String value) {
    if (value.length > 1024) throw const FormatException('QR too large');
    final json = jsonDecode(value);
    if (json is! Map ||
        json['kind'] != 'meomeo-scan' ||
        json['version'] != 1 ||
        json['address'] is! String ||
        json['code'] is! String) {
      throw const FormatException('Not a scan pairing QR');
    }
    final uri = Uri.parse(json['address'] as String);
    final octets = uri.host.split('.').map(int.tryParse).toList();
    final private =
        octets.length == 4 &&
        octets.every((v) => v != null && v >= 0 && v <= 255) &&
        (octets[0] == 10 ||
            octets[0] == 172 && octets[1]! >= 16 && octets[1]! <= 31 ||
            octets[0] == 192 && octets[1] == 168);
    final code = json['code'] as String;
    if (uri.scheme != 'https' ||
        !private ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.path.isNotEmpty && uri.path != '/') ||
        uri.port < 1 ||
        uri.port > 65535 ||
        !RegExp(r'^[a-f0-9]{64}\.[A-Za-z0-9_-]{32}$').hasMatch(code)) {
      throw const FormatException('Unsafe pairing address or code');
    }
    return ScanPairing(uri.toString(), code);
  }
}
