import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'detection_image.dart';
import 'detection_models.dart';

abstract class ObjectDetector {
  Future<DetectionResult> detect(DetectionImage image);
  void close();
}

class DetectionApi implements ObjectDetector {
  DetectionApi({String? baseUrl, this.timeout = const Duration(seconds: 35)})
    : _base = Uri.parse(
        baseUrl ??
            const String.fromEnvironment(
              'DETECTION_API_URL',
              defaultValue: 'http://127.0.0.1:8766',
            ),
      );
  final Uri _base;
  final Duration timeout;
  final _clients = <HttpClient>{};
  bool _closed = false;

  @override
  Future<DetectionResult> detect(DetectionImage image) async {
    if (_closed) throw const DetectionException('Màn hình đã đóng.');
    if (!(_base.scheme == 'https' ||
            _base.scheme == 'http' &&
                ['127.0.0.1', 'localhost'].contains(_base.host)) ||
        _base.userInfo.isNotEmpty) {
      throw const DetectionException(
        'Địa chỉ máy nhận diện chưa được thiết lập an toàn.',
      );
    }
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
    _clients.add(client);
    try {
      return await _send(client, image).timeout(timeout);
    } on TimeoutException {
      throw const DetectionException('Nhận diện mất quá lâu. Hãy thử lại.');
    } on SocketException {
      throw const DetectionException(
        'Chưa kết nối được máy nhận diện. Hãy kiểm tra kết nối rồi thử lại.',
      );
    } on HandshakeException {
      throw const DetectionException(
        'Chưa xác minh được máy nhận diện. Hãy kiểm tra kết nối an toàn.',
      );
    } on HttpException {
      throw const DetectionException('Kết nối bị gián đoạn. Hãy thử lại.');
    } on FormatException {
      throw const DetectionException('Chưa đọc được kết quả. Hãy thử lại.');
    } finally {
      _clients.remove(client);
      client.close(force: true);
    }
  }

  Future<DetectionResult> _send(HttpClient client, DetectionImage image) async {
    if (image.bytes.length > 8 * 1024 * 1024) {
      throw const DetectionException('Hãy chọn ảnh nhỏ hơn 8 MB.');
    }
    final request = await client.postUrl(_base.resolve('/api/v1/detect'));
    request.followRedirects = false;
    request.headers.contentType = ContentType('image', 'jpeg');
    request.contentLength = image.bytes.length;
    request.add(image.bytes);
    final response = await request.close();
    final body = BytesBuilder(copy: false);
    await for (final chunk in response) {
      if (body.length + chunk.length > 256 * 1024) {
        throw const FormatException('Response too large');
      }
      body.add(chunk);
    }
    if (response.statusCode != 200) {
      throw DetectionException(switch (response.statusCode) {
        413 => 'Ảnh quá lớn. Hãy chọn ảnh nhỏ hơn.',
        415 || 422 => 'Ảnh chưa đọc được. Hãy thử ảnh JPEG hoặc PNG khác.',
        429 => 'Máy đang nhận diện ảnh khác. Hãy thử lại sau một chút.',
        503 => 'Máy nhận diện chưa sẵn sàng. Hãy thử lại sau một chút.',
        408 || 504 => 'Nhận diện mất quá lâu. Hãy thử lại.',
        _ => 'Chưa nhận diện được ảnh này. Hãy thử lại.',
      });
    }
    final json = jsonDecode(utf8.decode(body.takeBytes()));
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Not a JSON object');
    }
    final result = DetectionResult.fromJson(json);
    if (result.imageSize.width != image.width ||
        result.imageSize.height != image.height) {
      throw const FormatException('Image coordinates do not match the preview');
    }
    return result;
  }

  @override
  void close() {
    _closed = true;
    for (final client in _clients) {
      client.close(force: true);
    }
    _clients.clear();
  }
}
