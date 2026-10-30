import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/bartender/models/game_item.dart';
import 'package:nhom_bar/games/bartender/models/station.dart';
import 'package:nhom_bar/games/bartender/services/bartender_haptics.dart';
import 'package:nhom_bar/games/bartender/services/shake_detector.dart';
import 'package:nhom_bar/games/bartender/widgets/station_widget.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  group('ShakeDetector (lớp thuần)', () {
    late ShakeDetector detector;

    setUp(() {
      detector = ShakeDetector(
        threshold: 12.0,
        minShakes: 3,
        windowMs: 1500,
        shakeCooldownMs: 200,
        triggerCooldownMs: 1000,
      );
    });

    test('gia tốc dưới ngưỡng không kích hoạt', () {
      // Gia tốc thông thường (ví dụ cầm tay nhẹ 3-5 m/s^2)
      expect(detector.addSample(2.0, 3.0, 1.0, 100), isFalse);
      expect(detector.addSample(4.0, 1.0, 2.0, 400), isFalse);
      expect(detector.addSample(3.0, 3.0, 3.0, 700), isFalse);
    });

    test('chưa đủ số lần lắc (minShakes = 3) thì chưa kích hoạt', () {
      // 2 đỉnh lắc mạnh (magnitude > 12)
      expect(detector.addSample(15.0, 0, 0, 100), isFalse);
      expect(detector.addSample(0, 15.0, 0, 400), isFalse);
    });

    test('các mẫu quá sát nhau (< shakeCooldownMs) bị lọc chống nhận nhầm', () {
      // Đỉnh 1 lúc 100ms
      expect(detector.addSample(15.0, 0, 0, 100), isFalse);
      // Đỉnh kế lúc 150ms (< 200ms cooldown) -> bị bỏ qua
      expect(detector.addSample(15.0, 0, 0, 150), isFalse);
      // Đỉnh kế lúc 250ms (< 200ms so với đỉnh 1) -> bị bỏ qua
      expect(detector.addSample(15.0, 0, 0, 250), isFalse);
      // Đỉnh 2 hợp lệ lúc 350ms (cách đỉnh 1 là 250ms >= 200ms)
      expect(detector.addSample(15.0, 0, 0, 350), isFalse);
      // Chưa đủ 3 đỉnh hợp lệ
    });

    test('các lần lắc quá xa nhau (> windowMs) bị xoá khỏi cửa sổ', () {
      // Đỉnh 1 lúc 100ms
      expect(detector.addSample(15.0, 0, 0, 100), isFalse);
      // Đỉnh 2 lúc 400ms
      expect(detector.addSample(15.0, 0, 0, 400), isFalse);
      // Đỉnh 3 lúc 2000ms (> 100ms + 1500ms -> đỉnh 1 bị loại, chỉ còn đỉnh 2 & 3)
      expect(detector.addSample(15.0, 0, 0, 2000), isFalse);
    });

    test('đủ 3 lần lắc hợp lệ trong windowMs trả về true ("đã lắc đủ")', () {
      expect(detector.addSample(15.0, 0, 0, 100), isFalse);
      expect(detector.addSample(0, 15.0, 0, 350), isFalse);
      // Đỉnh 3 hợp lệ: kích hoạt thành công!
      expect(detector.addSample(0, 0, 15.0, 600), isTrue);
    });

    test('trong triggerCooldownMs sau khi kích hoạt thì không nhận lắc tiếp', () {
      // 3 lần lắc đạt chuẩn
      expect(detector.addSample(15.0, 0, 0, 100), isFalse);
      expect(detector.addSample(15.0, 0, 0, 350), isFalse);
      expect(detector.addSample(15.0, 0, 0, 600), isTrue);

      // Thử lắc tiếp trong vòng 1000ms sau trigger (lúc 800ms, 1100ms, 1400ms)
      expect(detector.addSample(15.0, 0, 0, 850), isFalse);
      expect(detector.addSample(15.0, 0, 0, 1100), isFalse);
      expect(detector.addSample(15.0, 0, 0, 1400), isFalse);

      // Sau khi hết triggerCooldownMs (sau 1600ms), bắt đầu tích luỹ đợt mới
      expect(detector.addSample(15.0, 0, 0, 1700), isFalse);
      expect(detector.addSample(15.0, 0, 0, 1950), isFalse);
      expect(detector.addSample(15.0, 0, 0, 2200), isTrue);
    });

    test('evaluateSamples đánh giá danh sách mẫu', () {
      final samples = [
        const ShakeSample(x: 1, y: 1, z: 1, timestampMs: 100),
        const ShakeSample(x: 15, y: 0, z: 0, timestampMs: 200),
        const ShakeSample(x: 0, y: 16, z: 0, timestampMs: 450),
        const ShakeSample(x: 0, y: 0, z: 14, timestampMs: 700),
      ];
      expect(detector.evaluateSamples(samples), isTrue);
    });
  });

  group('BartenderHaptics', () {
    tearDown(() {
      BartenderHaptics.reset();
    });

    test('ghi nhận sự kiện khi rung được bật', () async {
      final events = <String>[];
      BartenderHaptics.onHaptic = events.add;

      await BartenderHaptics.orderSubmitted();
      await BartenderHaptics.itemTrashed();
      await BartenderHaptics.timeExpired();

      expect(events, equals(['orderSubmitted', 'itemTrashed', 'timeExpired']));
    });

    test('không gọi rung khi enabled = false', () async {
      final events = <String>[];
      BartenderHaptics.onHaptic = events.add;
      BartenderHaptics.enabled = false;

      await BartenderHaptics.orderSubmitted();
      await BartenderHaptics.itemTrashed();
      await BartenderHaptics.timeExpired();

      expect(events, isEmpty);
    });
  });

  group('StationWidget (Shaker & Fallback)', () {
    tearDown(() {
      ShakeSensorConfig.reset();
    });

    final testItem = const GameItem(
      id: 'item_1',
      type: GameItemType.product,
      itemId: 'orange_juice',
      fromRingIndex: 0,
    );

    testWidgets(
        'khi station là shaker và cảm biến không khả dụng: hiện nút "Lắc giả lập"',
        (tester) async {
      var processed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StationWidget(
              station: StationType.shaker,
              items: [testItem],
              onProcessItem: (_) => processed = true,
              isBusy: false,
              isSensorAvailable: false,
            ),
          ),
        ),
      );

      // Phải có nút "Lắc giả lập"
      expect(find.text('Lắc giả lập'), findsOneWidget);
      expect(find.byKey(const Key('simulate-shake-button')), findsOneWidget);

      // Bấm nút "Lắc giả lập"
      await tester.tap(find.text('Lắc giả lập'));
      await tester.pump();

      expect(processed, isTrue);
    });

    testWidgets(
        'khi station là shaker và cảm biến khả dụng: KHÔNG hiện nút "Lắc giả lập", hiện hướng dẫn lắc',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StationWidget(
              station: StationType.shaker,
              items: [testItem],
              onProcessItem: (_) {},
              isBusy: false,
              isSensorAvailable: true,
              accelerometerStream: const Stream.empty(),
            ),
          ),
        ),
      );

      // Không được hiện nút "Lắc giả lập"
      expect(find.text('Lắc giả lập'), findsNothing);
      expect(find.byKey(const Key('simulate-shake-button')), findsNothing);

      // Có thông báo hướng dẫn lắc điện thoại
      expect(find.textContaining('Lắc điện thoại'), findsOneWidget);
    });

    testWidgets(
        'khi nhận chuỗi lắc từ stream gia tốc tại trạm shaker: tự động gọi onProcessItem',
        (tester) async {
      var processed = false;
      final controller = StreamController<UserAccelerometerEvent>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StationWidget(
              station: StationType.shaker,
              items: [testItem],
              onProcessItem: (_) => processed = true,
              isBusy: false,
              isSensorAvailable: true,
              accelerometerStream: controller.stream,
            ),
          ),
        ),
      );

      // Gửi 3 sự kiện lắc mạnh cách nhau > 200ms
      final base = DateTime(2026, 1, 1, 12, 0, 0);
      controller.add(UserAccelerometerEvent(15.0, 0, 0, base));
      await tester.pump(const Duration(milliseconds: 50));

      controller.add(UserAccelerometerEvent(
        0,
        16.0,
        0,
        base.add(const Duration(milliseconds: 250)),
      ));
      await tester.pump(const Duration(milliseconds: 50));

      controller.add(UserAccelerometerEvent(
        0,
        0,
        15.0,
        base.add(const Duration(milliseconds: 500)),
      ));
      await tester.pump(const Duration(milliseconds: 50));

      expect(processed, isTrue);
      await controller.close();
    });

    testWidgets(
        'khi station là juicer/blender: hiện nút thao tác thông thường, không hiện "Lắc giả lập"',
        (tester) async {
      final rawOrange = const GameItem(
        id: 'item_2',
        type: GameItemType.ingredient,
        itemId: 'orange',
        fromRingIndex: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StationWidget(
              station: StationType.juicer,
              items: [rawOrange],
              onProcessItem: (_) {},
              isBusy: false,
            ),
          ),
        ),
      );

      expect(find.text('Lắc giả lập'), findsNothing);
      expect(find.text('Ép nước orange'), findsOneWidget);
    });
  });
}
