import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/gacha/services/gacha_cinematic_server.dart';

class _Assets extends CachingAssetBundle {
  final requests = <String>[];
  @override
  Future<ByteData> load(String key) async {
    requests.add(key);
    if (key.endsWith('missing.glb')) throw StateError('missing');
    return ByteData.sublistView(Uint8List.fromList(key.codeUnits));
  }
}

void main() {
  test(
    'cinematic server serves only this result assets without caching',
    () async {
      final assets = _Assets();
      final server = await GachaCinematicServer.start(
        assets,
        'assets/models/gacha/non_la.glb',
      );
      final client = HttpClient();
      addTearDown(() async {
        client.close(force: true);
        await server.close();
      });
      for (final path in [
        'index.html',
        'cinematic.js',
        'model.glb',
        'model.glb',
      ]) {
        final response = await (await client.getUrl(server.uri.resolve(path)))
            .close();
        expect(response.statusCode, 200);
        expect(response.headers.value('cache-control'), 'no-store');
        expect(
          await response.fold<int>(0, (count, bytes) => count + bytes.length),
          greaterThan(0),
        );
      }
      expect(
        assets.requests.where((path) => path.endsWith('non_la.glb')),
        hasLength(2),
      );
      for (final path in ['other.glb', '../pubspec.yaml', 'cinematic-src.js']) {
        final response = await (await client.getUrl(server.uri.resolve(path)))
            .close();
        expect(response.statusCode, 404);
        await response.drain<void>();
      }
      expect(assets.requests, hasLength(4));
      final request = await client.postUrl(server.uri.resolve('model.glb'));
      final response = await request.close();
      expect(response.statusCode, 404);
      await response.drain<void>();
      await server.close();
      await server.close();
    },
  );

  test('cinematic server rejects nonlocal and traversal model paths', () async {
    for (final path in [
      'https://example.com/model.glb',
      'assets/models/gacha/../secret.glb',
    ]) {
      await expectLater(
        GachaCinematicServer.start(_Assets(), path),
        throwsArgumentError,
      );
    }
  });

  test(
    'failed bundled model responds with an error and releases its server',
    () async {
      final server = await GachaCinematicServer.start(
        _Assets(),
        'assets/models/gacha/missing.glb',
      );
      final client = HttpClient();
      try {
        final response = await (await client.getUrl(
          server.uri.resolve('model.glb'),
        )).close();
        expect(response.statusCode, 500);
        await response.drain<void>();
      } finally {
        client.close(force: true);
        await server.close();
      }
    },
  );
}
