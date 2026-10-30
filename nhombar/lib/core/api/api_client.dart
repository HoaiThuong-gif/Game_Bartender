import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Mobile/desktop HTTP transport. No Firebase credentials or database writes.
class ApiClient {
  ApiClient({String? baseUrl, HttpClient? httpClient})
    : baseUrl =
          baseUrl ??
          const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'http://127.0.0.1:3000/api/v1',
          ),
      _http = httpClient ?? HttpClient();

  final String baseUrl;
  final HttpClient _http;
  String? _token;
  String? _uid;
  int serverOffsetMs = 0;
  bool _closed = false;
  String get uid => _uid ?? (throw StateError('Chưa tạo phiên người chơi.'));

  Future<Map<String, dynamic>> request(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    if (_closed) throw StateError('Kết nối API đã đóng.');
    try {
      return await _request(
        method,
        path,
        body,
      ).timeout(const Duration(seconds: 12));
    } on SocketException {
      throw StateError(
        'Không kết nối được máy chủ. Kiểm tra API_BASE_URL và mạng.',
      );
    } on TimeoutException {
      throw StateError('Máy chủ phản hồi quá lâu. Hãy thử lại.');
    }
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path,
    Map<String, dynamic>? body,
  ) async {
    final sentAt = DateTime.now().millisecondsSinceEpoch;
    final request = await _http.openUrl(
      method,
      Uri.parse('${baseUrl.replaceAll(RegExp(r'/$'), '')}$path'),
    );
    if (_token != null) request.headers.set('Authorization', 'Bearer $_token');
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
    }
    final response = await request.close();
    final text = await utf8.decoder.bind(response).join();
    final data = jsonDecode(text) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw StateError(
        (data['error'] as Map?)?['message'] as String? ??
            'Lỗi API ${response.statusCode}',
      );
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    if (data['serverTime'] is num) {
      serverOffsetMs =
          (data['serverTime'] as num).toInt() - ((sentAt + now) ~/ 2);
    }
    return data;
  }

  Future<void> session(String name) async {
    if (_token != null) return;
    final data = await request('POST', '/sessions', {'name': name});
    _token = data['token'] as String;
    _uid = data['uid'] as String;
  }

  /// Sequential polling: slow requests never overlap. Cancellation stops polling.
  Stream<Map<String, dynamic>> watch(String path) {
    late StreamController<Map<String, dynamic>> controller;
    Timer? timer;
    bool active = true;
    Future<void> poll() async {
      try {
        final data = await request('GET', path);
        if (active) controller.add(data);
      } catch (error, stack) {
        if (active) controller.addError(error, stack);
      } finally {
        if (active && !_closed) timer = Timer(const Duration(seconds: 1), poll);
      }
    }

    controller = StreamController<Map<String, dynamic>>(
      onListen: poll,
      onCancel: () {
        active = false;
        timer?.cancel();
      },
    );
    return controller.stream;
  }

  void close() {
    _closed = true;
    _http.close(force: true);
  }
}
