import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:nhom_bar/photo_scan/photo_model_api.dart';
import 'package:nhom_bar/photo_scan/photo_scan_image.dart';
import 'package:nhom_bar/photo_scan/photo_scan_screen.dart';

Uint8List transportFixture() {
  final bytes = Uint8List(7208);
  final data = ByteData.sublistView(bytes);
  data.setUint32(0, 0x53434e31);
  data.setUint32(4, 900);
  return bytes;
}

class ControlledService implements PhotoModelService {
  final complete = Completer<Uint8List>();
  bool closed = false;
  @override
  Future<Uint8List> generate(Uint8List image, void Function(String) stage) {
    stage('reconstructing');
    return complete.future;
  }

  @override
  void close() {
    closed = true;
  }
}

class RealHttpOverrides extends HttpOverrides {}

void main() {
  test(
    'rejects truncated/oversized meshes instead of displaying invalid data',
    () {
      validatePhotoMesh(transportFixture());
      expect(() => validatePhotoMesh(Uint8List(4)), throwsFormatException);
      final bad = transportFixture();
      ByteData.sublistView(bad).setUint32(4, 9000000);
      expect(() => validatePhotoMesh(bad), throwsFormatException);
    },
  );

  test(
    'photo preparation rejects corrupt images and keeps image aspect ratio',
    () {
      expect(
        () => preparePhotoScanImage(Uint8List.fromList([1, 2, 3])),
        throwsA(isA<PhotoModelException>()),
      );
      final photo = preparePhotoScanImage(
        img.encodePng(img.Image(width: 2000, height: 1000)),
      );
      expect(photo.width, 1600);
      expect(photo.height, 800);
    },
  );

  test(
    'HTTP client uploads, polls reported stages, downloads the bounded mesh',
    () async {
      await HttpOverrides.runWithHttpOverrides(() async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        const id = '12345678-1234-1234-1234-123456789abc';
        var polls = 0;
        var uploads = 0;
        server.listen((request) async {
          request.response.headers.contentType = ContentType.json;
          if (request.method == 'POST') {
            uploads++;
            expect(await request.fold<int>(0, (sum, c) => sum + c.length), 3);
            request.response.statusCode = 202;
            request.response.write(
              jsonEncode({'id': id, 'model': 'TripoSR', 'state': 'queued'}),
            );
          } else if (request.uri.path.endsWith('/mesh')) {
            request.response.add(transportFixture());
          } else {
            request.response.write(
              jsonEncode({
                'id': id,
                'model': 'TripoSR',
                'state': ++polls == 1 ? 'extracting' : 'done',
              }),
            );
          }
          await request.response.close();
        });
        final api = PhotoModelApi(baseUrl: 'http://127.0.0.1:${server.port}');
        final stages = <String>[];
        try {
          final result = await api.generate(
            Uint8List.fromList([1, 2, 3]),
            stages.add,
          );
          expect(result, transportFixture());
          expect(uploads, 1);
          expect(
            stages,
            containsAllInOrder(['uploading', 'extracting', 'downloading']),
          );
        } finally {
          api.close();
          await server.close(force: true);
        }
      }, RealHttpOverrides());
    },
  );

  testWidgets(
    'processing blocks duplicate requests, opens native viewer, releases on exit',
    (tester) async {
      final service = ControlledService();
      final image = preparePhotoScanImage(
        img.encodeJpg(img.Image(width: 32, height: 32)),
      );
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('meomeo/spatial'),
        (call) async {
          calls.add(call);
          return null;
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          home: PhotoScanScreen(service: service, pickImage: () async => image),
        ),
      );
      await tester.tap(find.text('Chọn ảnh'));
      await tester.pump();
      expect(find.text('Đang tạo hình 3D…'), findsOneWidget);
      service.complete.complete(transportFixture());
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Xem mô hình 3D'));
      await tester.tap(find.text('Xem mô hình 3D'));
      await tester.pumpAndSettle();
      expect(calls.single.method, 'openPhotoModel');
      await tester.pumpWidget(const SizedBox());
      expect(service.closed, isTrue);
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('meomeo/spatial'),
        null,
      );
    },
  );

  testWidgets('failed inference shows retry without a fake model', (
    tester,
  ) async {
    final service = ControlledService();
    final image = preparePhotoScanImage(
      img.encodeJpg(img.Image(width: 32, height: 32)),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: PhotoScanScreen(service: service, pickImage: () async => image),
      ),
    );
    await tester.tap(find.text('Chọn ảnh'));
    await tester.pump();
    service.complete.completeError(
      const PhotoModelException('Máy chưa sẵn sàng.'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Máy chưa sẵn sàng.'), findsOneWidget);
    expect(find.text('Thử lại'), findsOneWidget);
    expect(find.text('Xem mô hình 3D'), findsNothing);
  });
}
