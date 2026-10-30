import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class PhotoModelException implements Exception {
  const PhotoModelException(this.message);
  final String message;
}

abstract class PhotoModelService {
  Future<Uint8List> generate(Uint8List image, void Function(String) onStage);
  void close();
}

class PhotoModelApi implements PhotoModelService {
  PhotoModelApi({String? baseUrl, this.timeout = const Duration(minutes: 11)})
    : _base = Uri.parse(
        baseUrl ??
            const String.fromEnvironment(
              'PHOTO3D_API_URL',
              defaultValue: 'http://127.0.0.1:8766',
            ),
      );

  final Uri _base;
  final Duration timeout;
  final _clients = <HttpClient>{};
  String? _job;
  Uint8List? _lastImage;
  bool _closed = false;

  Future<Uint8List> _request(
    String path, {
    Uint8List? image,
    bool mesh = false,
  }) async {
    if (_closed) throw const PhotoModelException('Màn hình đã đóng.');
    if (!(_base.scheme == 'https' ||
            _base.scheme == 'http' &&
                ['127.0.0.1', 'localhost'].contains(_base.host)) ||
        _base.userInfo.isNotEmpty) {
      throw const PhotoModelException(
        'Địa chỉ máy tạo mô hình chưa được thiết lập an toàn.',
      );
    }
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
    _clients.add(client);
    try {
      return await (() async {
        final request = await client.openUrl(
          image == null ? 'GET' : 'POST',
          _base.resolve(path),
        );
        request.followRedirects = false;
        if (image != null) {
          request.headers.contentType = ContentType('image', 'jpeg');
          request.contentLength = image.length;
          request.add(image);
        }
        final response = await request.close();
        final bytes = BytesBuilder(copy: false);
        await for (final chunk in response) {
          if (bytes.length + chunk.length >
              (mesh ? 8 * 1024 * 1024 : 256 * 1024)) {
            throw const PhotoModelException(
              'Kết quả quá lớn. Hãy thử ảnh khác.',
            );
          }
          bytes.add(chunk);
        }
        if (response.statusCode != 200 && response.statusCode != 202) {
          if (response.statusCode == 404) _job = null;
          throw PhotoModelException(switch (response.statusCode) {
            404 => 'Phiên đã hết hạn. Hãy gửi lại ảnh.',
            413 => 'Ảnh quá lớn. Hãy chọn ảnh nhỏ hơn.',
            415 || 422 => 'Ảnh không đọc được. Hãy chọn JPEG hoặc PNG khác.',
            429 => 'Máy đang tạo mô hình khác. Hãy thử lại sau nhé.',
            503 => 'Máy tạo mô hình chưa sẵn sàng. Hãy kiểm tra máy tính.',
            _ => 'Chưa tạo được mô hình. Hãy thử lại.',
          });
        }
        return bytes.takeBytes();
      })().timeout(const Duration(seconds: 30));
    } finally {
      _clients.remove(client);
      client.close(force: true);
    }
  }

  Map<String, dynamic> _json(Uint8List bytes) {
    final value = jsonDecode(utf8.decode(bytes));
    if (value is! Map<String, dynamic>) throw const FormatException();
    return value;
  }

  @override
  Future<Uint8List> generate(
    Uint8List image,
    void Function(String) onStage,
  ) async {
    if (image.isEmpty || image.length > 8 * 1024 * 1024) {
      throw const PhotoModelException('Hãy chọn ảnh nhỏ hơn 8 MB.');
    }
    final watch = Stopwatch()..start();
    try {
      if (!identical(_lastImage, image)) _job = null;
      _lastImage = image;
      if (_job == null) {
        onStage('uploading');
        final created = _json(
          await _request('/api/v1/photo-models', image: image),
        );
        final id = created['id'];
        if (created['model'] != 'TripoSR' ||
            id is! String ||
            !RegExp(r'^[a-f0-9]{8}(-[a-f0-9]{4}){3}-[a-f0-9]{12}$')
                .hasMatch(id)) {
          throw const FormatException();
        }
        _job = id;
      }
      while (!_closed && watch.elapsed < timeout) {
        final result = _json(await _request('/api/v1/photo-models/$_job'));
        if (result['model'] != 'TripoSR' || result['id'] != _job) {
          throw const FormatException();
        }
        final stage = result['state'];
        if (stage == 'error') {
          _job = null;
          final error = result['error'];
          final message = error is Map ? error['message'] : null;
          throw PhotoModelException(
            message is String && message.length <= 200
                ? message
                : 'Chưa tạo được mô hình. Hãy thử ảnh khác.',
          );
        }
        if (stage == 'done') {
          onStage('downloading');
          final mesh = await _request(
            '/api/v1/photo-models/$_job/mesh',
            mesh: true,
          );
          validatePhotoMesh(mesh);
          _job = null;
          return mesh;
        }
        if (![
          'queued',
          'preprocessing',
          'reconstructing',
          'extracting',
          'exporting',
        ].contains(stage)) {
          throw const FormatException();
        }
        onStage(stage as String);
        await Future<void>.delayed(const Duration(seconds: 1));
      }
      throw const PhotoModelException('Tạo mô hình mất quá lâu. Hãy thử lại.');
    } on TimeoutException {
      throw const PhotoModelException('Kết nối chờ quá lâu. Hãy thử lại.');
    } on SocketException {
      throw const PhotoModelException(
        'Chưa kết nối được máy tạo mô hình. Hãy kiểm tra kết nối rồi thử lại.',
      );
    } on HandshakeException {
      throw const PhotoModelException('Chưa xác minh được kết nối an toàn.');
    } on HttpException {
      throw const PhotoModelException('Kết nối bị gián đoạn. Hãy thử lại.');
    } on FormatException {
      _job = null;
      throw const PhotoModelException('Chưa đọc được mô hình. Hãy thử lại.');
    }
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

void validatePhotoMesh(Uint8List bytes) {
  if (bytes.length < 8 || bytes.length > 8 * 1024 * 1024) {
    throw const FormatException();
  }
  final view = ByteData.sublistView(bytes);
  final count = view.getUint32(4);
  if (view.getUint32(0) != 0x53434e31 ||
      count < 900 ||
      count > 900000 ||
      count % 9 != 0 ||
      bytes.length != 8 + count * 8) {
    throw const FormatException();
  }
}
