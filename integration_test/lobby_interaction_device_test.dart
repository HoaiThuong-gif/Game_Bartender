import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nhom_bar/games/rubik/widgets/rubik_interactive_preview.dart';
import 'package:nhom_bar/games/song_cu/controllers/song_cu_controller.dart';
import 'package:nhom_bar/games/song_cu/widgets/song_cu_tv_view.dart';
import 'package:nhom_bar/screens/home/lobby_screen.dart';
import 'package:nhom_bar/screens/home/lobby_layout.dart';
import 'package:nhom_bar/screens/home/lobby_cats.dart';
import 'package:nhom_bar/screens/home/widgets/lobby_object.dart';
import 'package:nhom_bar/screens/home/widgets/lobby_sprite.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<Map<String, dynamic>> snapshot(
  WidgetTester tester,
  String expression,
) async {
  final view = tester.widget<WebViewWidget>(find.byType(WebViewWidget));
  dynamic result = await view.platform.params.controller
      .runJavaScriptReturningResult('JSON.stringify($expression)');
  if (result is String) result = jsonDecode(result);
  if (result is String) result = jsonDecode(result);
  return Map<String, dynamic>.from(result as Map);
}

Future<void> waitFor(WidgetTester tester, String expression) async {
  for (var i = 0; i < 150; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (find.byType(WebViewWidget).evaluate().isNotEmpty) {
      try {
        if ((await snapshot(tester, expression)).isNotEmpty) return;
      } catch (_) {}
    }
  }
  fail('WebView did not become ready');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('updated lobby assets and enlarged bartender on device', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(home: LobbyScreen(onBartenderTap: () => opened = true)),
    );
    await tester.pump(const Duration(seconds: 3));
    final viewport = tester.view.physicalSize / tester.view.devicePixelRatio;
    final bar = LobbyLayout.fitObject(LobbyLayout.bartender, viewport);
    final scene = LobbyLayout.viewportRect(viewport);
    expect(bar.width, 440);
    expect(bar.visualRect.left, greaterThanOrEqualTo(scene.left));
    expect(bar.visualRect.right, lessThanOrEqualTo(scene.right));
    expect(bar.visualRect.overlaps(LobbyLayout.tv.visualRect), false);
    expect(bar.visualRect.overlaps(LobbyLayout.arcade.visualRect), false);
    final rubik = tester.widget<LobbySprite>(
      find.byWidgetPredicate((w) => w is LobbySprite && w.name == 'rubik'),
    );
    expect(rubik.count, 1);
    final object = find.byWidgetPredicate(
      (w) => w is LobbyObject && w.game == LobbyGame.bartender,
    );
    // Tap opaque wood above the stools, away from the seated cats.
    final bounds = tester.getRect(object);
    await tester.tapAt(
      bounds.topLeft + Offset(bounds.width * .45, bounds.height * .5),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(opened, true);
    expect(tester.takeException(), isNull);
    debugPrint(
      '[LobbyAssets] viewport=$viewport bartender=${bar.visualRect}; Rubik=1 frame; bartender tap passed',
    );
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'native Rubik two-finger orbit preserves stickers and one-finger turns',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: RubikInteractivePreview())),
      );
      await waitFor(tester, 'window.rubikToySnapshot?.() ?? {}');
      await tester.pump(const Duration(seconds: 1));
      final before = await snapshot(tester, 'window.rubikToySnapshot()');
      final rect = tester.getRect(find.byType(WebViewWidget));
      final a = await tester.startGesture(
        rect.center - const Offset(25, 0),
        pointer: 1,
      );
      final b = await tester.startGesture(
        rect.center + const Offset(25, 0),
        pointer: 2,
      );
      for (var i = 0; i < 10; i++) {
        await a.moveBy(const Offset(9, 12));
        await b.moveBy(const Offset(9, 12));
        await tester.pump(const Duration(milliseconds: 40));
      }
      await b.up();
      await a.up();
      await tester.pump(const Duration(milliseconds: 500));
      final after = await snapshot(tester, 'window.rubikToySnapshot()');
      expect(after['cube'], before['cube']);
      expect(after['moves'], before['moves']);
      expect(after['camera'], isNot(equals(before['camera'])));
      expect(after['zoom'], before['zoom']);
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        (await snapshot(tester, 'window.rubikToySnapshot()'))['camera'],
        after['camera'],
      );
      final targets = await snapshot(
        tester,
        '({items:window.rubikToyTouchTargets()})',
      );
      final target = (targets['items'] as List).first as Map;
      final start = Offset(
        rect.left + rect.width * (target['x'] as num),
        rect.top + rect.height * (target['y'] as num),
      );
      final finger = await tester.startGesture(start);
      await finger.moveBy(const Offset(70, 0));
      await finger.up();
      await tester.pump(const Duration(seconds: 1));
      expect(
        (await snapshot(tester, 'window.rubikToySnapshot()'))['moves'],
        (after['moves'] as int) + 1,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'native TV circular knobs, antennas, seasons and persistent orbit',
    (tester) async {
      final game = SongCuController();
      await game.load();
      game.settings(reduced: true);
      game.setActive(true);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedBuilder(
              animation: game,
              builder: (context, _) => SongCuTVView(
                snapshot: game.snapshot(systemReducedMotion: false),
                active: true,
                onAction: game.action,
              ),
            ),
          ),
        ),
      );
      await waitFor(tester, 'window.songCuSnapshot?.() ?? {}');
      await tester.pump(const Duration(seconds: 2));
      var data = await snapshot(tester, 'window.songCuSnapshot()');
      expect(data['seasons'], true);
      final rect = tester.getRect(find.byType(WebViewWidget));
      Offset point(Map p) => Offset(
        rect.left + rect.width * (p['x'] as num),
        rect.top + rect.height * (p['y'] as num),
      );
      await tester.tapAt(point((data['targets'] as List)[4] as Map));
      await tester.pump(const Duration(milliseconds: 500));
      data = await snapshot(tester, 'window.songCuSnapshot()');
      final originalYaw = data['yaw'];
      for (final index in [0, 1]) {
        final center = point((data['targets'] as List)[index] as Map);
        final before = List.of(data['controls'] as List);
        final finger = await tester.startGesture(center + const Offset(20, 0));
        for (var i = 1; i <= 12; i++) {
          final angle =
              i * math.pi / 24 * ((before[index + 2] as num) > 0 ? -1 : 1);
          await finger.moveTo(
            center + Offset(math.cos(angle) * 20, math.sin(angle) * 20),
          );
          await tester.pump(const Duration(milliseconds: 40));
        }
        await finger.up();
        await tester.pump(const Duration(milliseconds: 300));
        data = await snapshot(tester, 'window.songCuSnapshot()');
        expect((data['controls'] as List)[index + 2], isNot(before[index + 2]));
        expect(data['yaw'], originalYaw);
        if (index == 1) {
          expect(
            data['volume'],
            closeTo(
              ((data['controls'] as List)[3] as num).toDouble() / 4 + .25,
              .001,
            ),
          );
        }
      }
      for (final index in [2, 3]) {
        final start = point((data['targets'] as List)[index] as Map);
        final before = List.of(data['controls'] as List);
        final picture = data['picture'];
        final finger = await tester.startGesture(start);
        final direction = (before[index - 2] as num) > 0 ? -1.0 : 1.0;
        await finger.moveBy(
          Offset((index == 2 ? -direction : direction) * 65, 30),
        );
        await tester.pump(const Duration(milliseconds: 300));
        data = await snapshot(tester, 'window.songCuSnapshot()');
        expect((data['controls'] as List)[index - 2], isNot(before[index - 2]));
        expect(
          data['picture'],
          isNot(picture),
          reason: 'Antenna must change the rendered screen during the drag',
        );
        await finger.up();
        await tester.pump(const Duration(milliseconds: 200));
      }
      final pictures = <Object?>{};
      for (var i = 0; i < 4; i++) {
        game.remote('channel', 1);
        await tester.pump(const Duration(milliseconds: 500));
        pictures.add(
          (await snapshot(tester, 'window.songCuSnapshot()'))['picture'],
        );
      }
      expect(
        pictures.length,
        4,
        reason: 'All four authored seasons must render distinct pictures',
      );
      final finger = await tester.startGesture(
        rect.topLeft + const Offset(30, 40),
      );
      await finger.moveBy(const Offset(180, 30));
      await finger.up();
      await tester.pump(const Duration(seconds: 2));
      data = await snapshot(tester, 'window.songCuSnapshot()');
      expect(data['yaw'], isNot(originalYaw));
      final yaw = data['yaw'];
      await tester.pump(const Duration(seconds: 1));
      expect((await snapshot(tester, 'window.songCuSnapshot()'))['yaw'], yaw);
      await tester.pumpWidget(const SizedBox());
      game.dispose();
    },
  );
  testWidgets('native lobby tap opens TV and returns to the courtyard', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LobbyScreen()));
    await tester.pump(const Duration(seconds: 2));
    Finder sprite(String name) =>
        find.byWidgetPredicate((w) => w is LobbySprite && w.name == name);
    String frame(String name) =>
        (tester
                    .widget<Image>(
                      find.descendant(
                        of: sprite(name),
                        matching: find.byType(Image),
                      ),
                    )
                    .image
                as AssetImage)
            .assetName;
    Future<int> painted(String name) async {
      RenderObject? render = tester.renderObject(sprite(name));
      while (render is! RenderRepaintBoundary) {
        render = render!.parent;
      }
      final image = await render.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      var hash = 0;
      for (final byte in bytes!.buffer.asUint8List()) {
        hash = (hash * 31 + byte) & 0x7fffffff;
      }
      image.dispose();
      return hash;
    }

    for (final name in ['flag']) {
      final rendered = <String, int>{};
      for (
        var i = 0;
        i < 240 &&
            (rendered.length < 12 || rendered.values.toSet().length < 12);
        i++
      ) {
        final asset = frame(name);
        await tester.pump(const Duration(milliseconds: 30));
        if (asset == frame(name)) {
          rendered[asset] = await painted(name);
        }
      }
      expect(
        rendered.length,
        12,
        reason: '$name must actually paint all 12 frames',
      );
      expect(
        rendered.values.toSet().length,
        12,
        reason: '$name must not paint frame zero repeatedly',
      );
      debugPrint('[LobbyCorrection] $name: 12 different painted frames');
    }
    final firstBar = frame('bartender'),
        firstPicture = await painted('bartender');
    for (var i = 0; i < 40 && frame('bartender') == firstBar; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    await tester.pump(const Duration(milliseconds: 150));
    expect(frame('bartender'), isNot(firstBar));
    expect(await painted('bartender'), isNot(firstPicture));
    debugPrint('[LobbyCorrection] whole bartender frame changes on Android');
    final television = find.byWidgetPredicate(
      (w) => w is LobbyObject && w.game == LobbyGame.television,
    );
    await tester.tap(television);
    await tester.pump(const Duration(seconds: 1));
    await waitFor(tester, 'window.songCuSnapshot?.() ?? {}');
    await tester.pump(const Duration(seconds: 2));
    expect(
      (await snapshot(tester, 'window.songCuSnapshot()'))['seasons'],
      true,
    );
    Navigator.of(tester.element(find.byType(SongCuTVView))).pop();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(LobbyObject), findsNWidgets(4));
    await tester.pumpWidget(const SizedBox());
  });
}
