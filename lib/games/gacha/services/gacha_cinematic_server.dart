import 'dart:io';

import 'package:flutter/services.dart';

/// One short-lived loopback server per result, with exactly three asset routes.
/// No network downloads, filesystem access, or model cache.
class GachaCinematicServer {
  GachaCinematicServer._(this._server);
  final HttpServer _server;
  bool _closed = false;
  Uri get uri => Uri.parse('http://127.0.0.1:${_server.port}/index.html');

  static Future<GachaCinematicServer> start(
    AssetBundle bundle,
    String modelPath,
  ) async {
    if (!RegExp(r'^assets/models/gacha/[A-Za-z0-9_-]+\.glb$')
        .hasMatch(modelPath)) {
      throw ArgumentError.value(modelPath, 'modelPath');
    }
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final lease = GachaCinematicServer._(server);
    final routes = <String, (String, String)>{
      '/index.html': ('assets/gacha3d/index.html', 'text/html; charset=utf-8'),
      '/cinematic.js': (
        'assets/gacha3d/cinematic.js',
        'application/javascript',
      ),
      '/model.glb': (modelPath, 'model/gltf-binary'),
    };
    server.listen((request) async {
      try {
        final asset = routes[request.uri.path];
        if (lease._closed || request.method != 'GET' || asset == null) {
          request.response.statusCode = HttpStatus.notFound;
        } else {
          final bytes = await bundle.load(asset.$1);
          if (!lease._closed) {
            request.response.headers.set(
              HttpHeaders.contentTypeHeader,
              asset.$2,
            );
            request.response.headers.set(
              HttpHeaders.cacheControlHeader,
              'no-store',
            );
            request.response.add(
              bytes.buffer.asUint8List(
                bytes.offsetInBytes,
                bytes.lengthInBytes,
              ),
            );
          }
        }
        await request.response.close();
      } catch (_) {
        // The platform view may have disconnected during asset loading.
        try {
          request.response.statusCode = HttpStatus.internalServerError;
          await request.response.close();
        } catch (_) {}
      }
    });
    return lease;
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _server.close(force: true);
  }
}
