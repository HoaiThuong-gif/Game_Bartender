import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:nhom_bar/detection/detection_api.dart';
import 'package:nhom_bar/detection/detection_image.dart';
import 'package:nhom_bar/detection/detection_models.dart';
import 'package:nhom_bar/detection/detection_preview.dart';
import 'package:nhom_bar/detection/detection_screen.dart';

Map<String, dynamic> response({List<Map<String, dynamic>>? objects}) => {
  'model': 'yolo26n',
  'image': {'width': 24, 'height': 16},
  'bbox_format': 'xyxy',
  'detections':
      objects ??
      [
        {
          'class_id': 47,
          'name_en': 'apple',
          'name_vi': 'Táo',
          'confidence': .92,
          'bbox': [2, 3, 20, 14],
        },
      ],
};

DetectionImage photo() =>
    prepareDetectionImage(img.encodeJpg(img.Image(width: 24, height: 16)));

class TestDetector implements ObjectDetector {
  int calls = 0;
  final Future<DetectionResult> Function() action;
  TestDetector(this.action);
  @override
  Future<DetectionResult> detect(DetectionImage image) {
    calls++;
    return action();
  }

  @override
  void close() {}
}

// The default override creates a real dart:io client, scoped to loopback tests.
// Widget tests retain Flutter's normal network isolation.
class RealHttpOverrides extends HttpOverrides {}

void main() {
  test(
    'boxes follow the actual contained image, including letterbox offsets',
    () {
      expect(
        projectDetectionBox(
          const Rect.fromLTRB(100, 50, 300, 150),
          const Size(400, 200),
          const Size(300, 300),
        ),
        const Rect.fromLTRB(75, 112.5, 225, 187.5),
      );
      expect(
        projectDetectionBox(
          const Rect.fromLTRB(50, 100, 150, 300),
          const Size(200, 400),
          const Size(400, 200),
        ),
        const Rect.fromLTRB(175, 50, 225, 150),
      );
    },
  );

  test(
    'photo orientation is baked into the same JPEG used by preview and API',
    () {
      final source = img.Image(width: 24, height: 16);
      source.exif.imageIfd.orientation = 6;
      final prepared = prepareDetectionImage(img.encodeJpg(source));
      final decoded = img.decodeJpg(prepared.bytes)!;
      expect(prepared.width, 16);
      expect(prepared.height, 24);
      expect(decoded.width, prepared.width);
      expect(decoded.height, prepared.height);
      expect(
        () => prepareDetectionImage(Uint8List.fromList([1, 2, 3])),
        throwsA(isA<DetectionException>()),
      );
    },
  );

  test('invalid confidence, class and box data cannot become a result', () {
    for (final replacement in [
      {'confidence': 1.1},
      {'class_id': 80},
      {
        'bbox': [0, 0, 100, 100],
      },
      {
        'bbox': [20, 0, 2, 10],
      },
    ]) {
      final json = response();
      final object = (json['detections'] as List).first as Map<String, dynamic>;
      object.addAll(replacement);
      expect(() => DetectionResult.fromJson(json), throwsFormatException);
    }
  });

  test(
    'real HTTP client uploads JPEG bytes and validates API coordinates',
    () => HttpOverrides.runWithHttpOverrides(() async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final image = photo();
      final received = Completer<List<int>>();
      server.listen((request) async {
        expect(request.uri.path, '/api/v1/detect');
        expect(request.headers.contentType!.mimeType, 'image/jpeg');
        received.complete(
          await request.fold<List<int>>(
            [],
            (bytes, chunk) => bytes..addAll(chunk),
          ),
        );
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(response()));
        await request.response.close();
      });
      final api = DetectionApi(baseUrl: 'http://127.0.0.1:${server.port}');
      addTearDown(api.close);
      final result = await api.detect(image);
      expect(await received.future, image.bytes);
      expect(result.objects.single.english, 'apple');
      expect(result.objects.single.vietnamese, 'Táo');
      expect(result.objects.single.confidence, .92);
    }, RealHttpOverrides()),
  );

  test(
    'HTTP failures and missing connection never produce empty fake results',
    () => HttpOverrides.runWithHttpOverrides(() async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        await request.drain<void>();
        request.response.statusCode = 503;
        await request.response.close();
      });
      final api = DetectionApi(baseUrl: 'http://127.0.0.1:${server.port}');
      addTearDown(api.close);
      await expectLater(
        api.detect(photo()),
        throwsA(isA<DetectionException>()),
      );
      await server.close(force: true);
      await expectLater(
        api.detect(photo()),
        throwsA(isA<DetectionException>()),
      );
    }, RealHttpOverrides()),
  );

  testWidgets(
    'shows processing, Vietnamese, English and confidence for multiple objects',
    (tester) async {
      final pending = Completer<DetectionResult>();
      final detector = TestDetector(() => pending.future);
      await tester.pumpWidget(
        MaterialApp(
          home: DetectionScreen(
            detector: detector,
            pickImage: () async => photo(),
          ),
        ),
      );
      await tester.tap(find.text('Chọn ảnh'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      final json = response();
      (json['detections'] as List).add({
        'class_id': 41,
        'name_en': 'cup',
        'name_vi': 'Cốc',
        'confidence': .8,
        'bbox': [1, 1, 10, 10],
      });
      pending.complete(DetectionResult.fromJson(json));
      await tester.pumpAndSettle();
      expect(find.text('Táo'), findsOneWidget);
      expect(find.text('apple'), findsOneWidget);
      expect(find.text('Cốc'), findsOneWidget);
      expect(find.text('cup'), findsOneWidget);
      expect(find.text('92%'), findsOneWidget);
      expect(find.byType(DetectionPreview), findsOneWidget);
      expect(detector.calls, 1);
    },
  );

  testWidgets('no detections shows a friendly empty state', (tester) async {
    final detector = TestDetector(
      () async => DetectionResult.fromJson(response(objects: [])),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: DetectionScreen(
          detector: detector,
          pickImage: () async => photo(),
        ),
      ),
    );
    await tester.tap(find.text('Chọn ảnh'));
    await tester.pumpAndSettle();
    expect(
      find.text('Chưa tìm thấy đồ vật quen thuộc. Thử chụp rõ hơn nhé!'),
      findsOneWidget,
    );
    expect(find.text('Táo'), findsNothing);
  });

  testWidgets('retry retains the selected image and sends a fresh request', (
    tester,
  ) async {
    var fail = true;
    final detector = TestDetector(() async {
      if (fail) {
        throw const DetectionException('Chưa kết nối được máy nhận diện.');
      }
      return DetectionResult.fromJson(response());
    });
    await tester.pumpWidget(
      MaterialApp(
        home: DetectionScreen(
          detector: detector,
          pickImage: () async => photo(),
        ),
      ),
    );
    await tester.tap(find.text('Chọn ảnh'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa kết nối được máy nhận diện.'), findsOneWidget);
    fail = false;
    await tester.ensureVisible(find.text('Thử lại'));
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(detector.calls, 2);
    expect(find.text('Táo'), findsOneWidget);
  });
}
