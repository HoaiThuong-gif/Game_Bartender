import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nhom_bar/games/rubik/widgets/rubik_interactive_preview.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'lobby_interaction_device_test.dart' show snapshot, waitFor;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native camera roll 45 to 90, inversion recovery and gesture ownership',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: RubikInteractivePreview())),
      );
      await waitFor(tester, 'window.rubikToySnapshot?.() ?? {}');
      await tester.pump(const Duration(seconds: 1));
      Future<Map<String, dynamic>> state() =>
          snapshot(tester, 'window.rubikToySnapshot()');
      final initial = await state();
      final rect = tester.getRect(find.byType(WebViewWidget));

      Future<void> twist(double angle) async {
        final center = rect.center,
            radius = math.min(rect.width, rect.height) * .18;
        final a = await tester.startGesture(
          center - Offset(radius, 0),
          pointer: 1,
        );
        final b = await tester.startGesture(
          center + Offset(radius, 0),
          pointer: 2,
        );
        for (var step = 1; step <= 36; step++) {
          final theta = angle * step / 36;
          final offset = Offset(math.cos(theta), math.sin(theta)) * radius;
          await a.moveTo(center - offset);
          await b.moveTo(center + offset);
          await tester.pump(const Duration(milliseconds: 20));
        }
        await b.up();
        // A remaining finger must not turn a layer.
        await a.moveBy(const Offset(60, 40));
        await a.up();
        await tester.pump(const Duration(milliseconds: 200));
      }

      double dot(List a, List b) => List.generate(
        3,
        (i) => (a[i] as num) * (b[i] as num),
      ).fold(0.0, (sum, value) => sum + value);
      var previous = initial;
      for (final angle in [math.pi / 4, math.pi / 4, math.pi, -math.pi]) {
        await twist(angle);
        final current = await state();
        expect(current['cube'], initial['cube']);
        expect(current['moves'], initial['moves']);
        expect(current['zoom'], initial['zoom']);
        expect(
          dot(current['up'] as List, previous['up'] as List),
          closeTo(math.cos(angle), .08),
          reason: 'Actual camera roll must follow the two contacts',
        );
        final camera = List.of(current['camera'] as List),
            up = List.of(current['up'] as List);
        await tester.pump(const Duration(milliseconds: 300));
        final released = await state();
        expect(released['camera'], camera);
        expect(released['up'], up);
        previous = current;
      }
      debugPrint('[RubikTouch] native roll 45/90/180 and recovery verified');

      final targets = await snapshot(
        tester,
        '({items:window.rubikToyTouchTargets()})',
      );
      final target = (targets['items'] as List).first as Map;
      final start = Offset(
        rect.left + rect.width * (target['x'] as num),
        rect.top + rect.height * (target['y'] as num),
      );
      final finger = await tester.startGesture(start, pointer: 1);
      await finger.moveBy(const Offset(60, 0));
      await tester.pump(const Duration(milliseconds: 300));
      expect((await state())['moves'], initial['moves']);
      final second = await tester.startGesture(
        rect.center + const Offset(80, 0),
        pointer: 2,
      );
      await second.moveBy(const Offset(20, 25));
      await second.up();
      await finger.moveBy(const Offset(0, 70));
      await finger.up();
      await tester.pump(const Duration(milliseconds: 400));
      expect((await state())['cube'], initial['cube']);
      expect((await state())['moves'], initial['moves']);
      final fresh = await tester.startGesture(start, pointer: 3);
      await fresh.moveBy(const Offset(65, 0));
      await fresh.up();
      await tester.pump(const Duration(seconds: 1));
      expect((await state())['moves'], (initial['moves'] as int) + 1);
      expect(tester.takeException(), isNull);
      debugPrint(
        '[RubikTouch] pending-layer cancellation and fresh one-finger swipe verified',
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
}
