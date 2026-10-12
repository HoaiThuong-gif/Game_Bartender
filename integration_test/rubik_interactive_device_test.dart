import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nhom_bar/games/rubik/screens/rubik_screen.dart';
import 'package:nhom_bar/games/rubik/widgets/rubik_interactive_preview.dart';
import 'package:webview_flutter/webview_flutter.dart';

const moves = int.fromEnvironment('RUBIK_TOY_MOVES', defaultValue: 100);
final view = find.byKey(const ValueKey('rubik-interactive-webview'));

Future<dynamic> js(WidgetTester tester, String expression) async {
  final controller = tester
      .widget<WebViewWidget>(view)
      .platform
      .params
      .controller;
  dynamic value = await controller.runJavaScriptReturningResult(
    'JSON.stringify($expression)',
  );
  if (value is String) value = jsonDecode(value);
  if (value is String) value = jsonDecode(value);
  return value;
}

Future<Map<String, dynamic>> state(WidgetTester tester) async =>
    Map<String, dynamic>.from(
      await js(tester, 'window.rubikToySnapshot?.() ?? {}') as Map,
    );

Future<void> ready(WidgetTester tester) async {
  for (var i = 0; i < 100; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (view.evaluate().isNotEmpty &&
        (await state(tester))['renders'] != null) {
      await tester.pumpAndSettle();
      return;
    }
  }
  fail('Interactive Rubik did not load');
}

Future<void> settled(WidgetTester tester, {int? historyDepth}) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    final value = await state(tester);
    if (value['busy'] == false &&
        value['raf'] == 0 &&
        (historyDepth == null || value['historyDepth'] == historyDepth)) {
      return;
    }
  }
  fail('Layer animation stuck');
}

Future<void> tapControl(WidgetTester tester, String key) async {
  final button = find.byKey(ValueKey(key));
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (tester.widget<FilledButton>(button).onPressed != null) {
      await tester.tap(button);
      return;
    }
  }
  fail('$key did not become enabled');
}

void verify(Map<String, dynamic> value) {
  final cube = value['cube'] as List;
  expect(cube.length, 27);
  expect(cube.map((c) => (c['position'] as List).join(',')).toSet().length, 27);
  final colors = <int, int>{};
  for (final c in cube) {
    for (final n in c['position'] as List) {
      expect([-1, 0, 1], contains(n));
    }
    for (final n in c['colors'] as List) {
      colors[n as int] = (colors[n] ?? 0) + 1;
    }
  }
  expect(colors, {0: 9, 1: 9, 2: 9, 3: 9, 4: 9, 5: 9});
  expect(value['gesture'], isNull);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('$moves native layer swipes, orbit, both buttons and remount', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const RubikScreen()),
                ),
                child: const Text('Open toy'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open toy'));
    await ready(tester);
    await settled(tester);
    final solveRect = tester.getRect(find.text('GIẢI RUBIK'));
    final challengeRect = tester.getRect(find.text('THÁCH ĐẤU'));
    expect(tester.getRect(view).bottom, lessThan(solveRect.top));
    final original = await state(tester);
    // A tap and a tiny drag cannot turn a layer.
    await tester.tap(view);
    await settled(tester);
    await tester.drag(view, const Offset(4, 2));
    await settled(tester);
    expect((await state(tester))['moves'], 0);
    final touchedLayers = <String>{};
    final cubeHistory = <dynamic>[original['cube']];
    for (var i = 0; i < moves; i++) {
      if (i % 10 == 0) {
        final bounds = tester.getRect(view), before = await state(tester);
        final gesture = await tester.startGesture(
          Offset(bounds.left + bounds.width * .06, bounds.center.dy),
        );
        await gesture.moveBy(
          Offset(i % 20 == 0 ? 70 : -70, i % 30 == 0 ? 35 : -15),
        );
        await gesture.up();
        await settled(tester);
        expect((await state(tester))['moves'], before['moves']);
        expect(
          (await state(tester))['camera'],
          isNot(equals(before['camera'])),
        );
      }
      final targets = await js(tester, 'window.rubikToyTouchTargets()') as List;
      expect(targets, isNotEmpty);
      final target = targets[(i * 7) % targets.length] as Map;
      final bounds = tester.getRect(view);
      final start = Offset(
        bounds.left + bounds.width * (target['x'] as num),
        bounds.top + bounds.height * (target['y'] as num),
      );
      final before = await state(tester);
      final gesture = await tester.startGesture(start);
      final delta = i.isEven
          ? Offset(i % 4 == 0 ? 65 : -65, 0)
          : Offset(0, i % 4 == 1 ? 65 : -65);
      final steps = i % 3 == 0 ? 12 : 3;
      for (var step = 0; step < steps; step++) {
        await gesture.moveBy(delta / steps.toDouble());
        await tester.pump(Duration(milliseconds: i % 3 == 0 ? 30 : 12));
      }
      await gesture.up();
      await settled(tester);
      final after = await state(tester);
      expect(
        after['moves'],
        (before['moves'] as int) + 1,
        reason:
            'target=$target, beforeOrbit=${before['orbits']}, afterOrbit=${after['orbits']}, lastMove=${after['lastMove']}',
      );
      final move = after['lastMove'] as Map;
      touchedLayers.add('${move['axis']}/${move['layer']}/${move['sign']}');
      verify(after);
      cubeHistory.add(after['cube']);
      if ((i + 1) % 10 == 0) {
        debugPrint('[RubikToyDevice] completed ${i + 1}/$moves');
      }
    }
    final after = await state(tester);
    debugPrint('[RubikToyDevice] exercised layers: $touchedLayers');
    expect(after['cube'], isNot(equals(original['cube'])));
    await tester.pump(const Duration(milliseconds: 400));
    expect((await state(tester))['renders'], after['renders']);
    expect(tester.getRect(find.text('GIẢI RUBIK')), solveRect);
    expect(tester.getRect(find.text('THÁCH ĐẤU')), challengeRect);
    for (var i = 1; i <= 2; i++) {
      await tapControl(tester, 'rubik-toy-undo');
      await settled(tester, historyDepth: moves - i);
      final undone = await state(tester);
      expect(undone['cube'], equals(cubeHistory[moves - i]));
      expect(undone['historyDepth'], moves - i);
      expect(undone['camera'], equals(after['camera']));
      verify(undone);
    }
    await tapControl(tester, 'rubik-toy-reset');
    await settled(tester, historyDepth: 0);
    final reset = await state(tester);
    expect(reset['cube'], equals(original['cube']));
    expect(reset['camera'], equals(original['camera']));
    expect(reset['historyDepth'], 0);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('rubik-toy-undo')))
          .onPressed,
      isNull,
    );
    verify(reset);
    await tester.tap(find.text('GIẢI RUBIK'));
    await tester.pumpAndSettle();
    expect(find.text('Chọn cách nhập Rubik'), findsOneWidget);
    expect(find.byType(WebViewWidget, skipOffstage: false), findsNothing);
    await tester.pageBack();
    await ready(tester);
    await settled(tester);
    expect((await state(tester))['moves'], 0);
    await tester.tap(find.text('THÁCH ĐẤU'));
    await tester.pumpAndSettle();
    expect(find.text('Thử thách sắp bắt đầu'), findsOneWidget);
    expect(find.byType(WebViewWidget, skipOffstage: false), findsNothing);
    await tester.pageBack();
    await ready(tester);
    expect(find.byType(RubikInteractivePreview), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(WebViewWidget, skipOffstage: false), findsNothing);
    await tester.tap(find.text('Open toy'));
    await ready(tester);
    await settled(tester);
    expect((await state(tester))['moves'], 0);
    verify(await state(tester));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  }, timeout: const Timeout(Duration(minutes: 15)));
}
