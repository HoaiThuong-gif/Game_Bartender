import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/rubik/screens/rubik_screen.dart';
import 'package:nhom_bar/main.dart';
import 'package:nhom_bar/screens/home/lobby_screen.dart';
import 'package:nhom_bar/screens/home/lobby_layout.dart';
import 'package:nhom_bar/screens/home/widgets/animated_flag.dart';
import 'package:nhom_bar/screens/home/widgets/lobby_object.dart';

class _Routes extends NavigatorObserver {
  Route<dynamic>? last;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    last = route;
  }
}

Future<void> _load(WidgetTester tester) async {
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Widget _app({
  VoidCallback? bartender,
  VoidCallback? arcade,
  NavigatorObserver? observer,
  Key? previewKey,
}) => MaterialApp(
  navigatorObservers: [?observer],
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child!,
  ),
  home: RepaintBoundary(
    key: previewKey,
    child: LobbyScreen(onBartenderTap: bartender, onArcadeTap: arcade),
  ),
);

Finder _object(String label) => find.byWidgetPredicate(
  (widget) => widget is LobbyObject && widget.label == label,
);

void main() {
  testWidgets('home renders scene objects without game title cards', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const NhomBarApp());
    await _load(tester);
    expect(find.byType(LobbyObject), findsNWidgets(3));
    expect(find.byType(AnimatedFlag), findsOneWidget);
    for (final title in ['BARTENDER', 'RUBIK', 'GAME 3', 'GAME 4']) {
      expect(find.text(title), findsNothing);
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('portrait layouts preserve surface contacts without drift', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final previewKey = GlobalKey();
    for (final size in [
      const Size(360, 640),
      const Size(390, 844),
      const Size(430, 932),
      const Size(768, 1024),
    ]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(_app(previewKey: previewKey));
      await _load(tester);
      final sceneScale =
          size.width / LobbyLayout.designSize.width >
              size.height / LobbyLayout.designSize.height
          ? size.width / LobbyLayout.designSize.width
          : size.height / LobbyLayout.designSize.height;
      final sceneOffset = Offset(
        (size.width - LobbyLayout.designSize.width * sceneScale) / 2,
        (size.height - LobbyLayout.designSize.height * sceneScale) / 2,
      );
      for (final entry in {
        'Chơi Rubik': LobbyLayout.rubik,
        'Máy arcade': LobbyLayout.arcade,
        'Quầy Bartender': LobbyLayout.bartender,
      }.entries) {
        final rect = tester.getRect(_object(entry.key));
        final config = entry.value;
        final contact = Offset(
          rect.left +
              config.sourceAnchor.dx / config.imageSize.width * rect.width,
          rect.top +
              config.sourceAnchor.dy / config.imageSize.height * rect.height,
        );
        final expected = sceneOffset + Offset(config.x, config.y) * sceneScale;
        expect(contact.dx, closeTo(expected.dx, 0.001));
        expect(contact.dy, closeTo(expected.dy, 0.001));
        expect((Offset.zero & size).contains(contact), isTrue);
      }
      expect(tester.takeException(), isNull);
      {
        final boundary =
            previewKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory('build/lobby-preview').create(recursive: true);
          await File(
            'build/lobby-preview/${size.width.toInt()}x${size.height.toInt()}.png',
          ).writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }
    }
  });

  testWidgets('opaque objects respond; transparent pixels and flag do not', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var bartender = 0;
    var arcade = 0;
    final routes = _Routes();
    await tester.pumpWidget(
      _app(
        bartender: () => bartender++,
        arcade: () => arcade++,
        observer: routes,
      ),
    );
    await _load(tester);
    final arcadeRect = tester.getRect(_object('Máy arcade'));
    await tester.tapAt(arcadeRect.topLeft + const Offset(2, 2));
    await tester.pump(const Duration(milliseconds: 100));
    expect(arcade, 0);
    await tester.tap(_object('Máy arcade'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(arcade, 1);
    await tester.tap(_object('Quầy Bartender'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(bartender, 1);
    await tester.tap(find.byType(AnimatedFlag), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));
    expect(arcade, 1);
    expect(bartender, 1);
    await tester.tap(_object('Chơi Rubik'));
    final route = routes.last! as MaterialPageRoute<void>;
    expect(
      route.builder(tester.element(find.byType(LobbyScreen))),
      isA<RubikScreen>(),
    );
    // Rubik embeds a native WebView, so verify the destination before rendering it.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('unfinished games show a clear placeholder', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app());
    await _load(tester);
    await tester.tap(_object('Máy arcade'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Arcade đang được phát triển.'), findsOneWidget);
    await tester.tap(_object('Quầy Bartender'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Bartender đang được phát triển.'), findsOneWidget);
  });

  testWidgets('press feedback keeps the object contact point fixed', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(arcade: () {}));
    await _load(tester);
    final image = find.descendant(
      of: _object('Máy arcade'),
      matching: find.byType(Image),
    );
    Offset contact() {
      final box = tester.renderObject<RenderBox>(image);
      final config = LobbyLayout.arcade;
      return box.localToGlobal(
        Offset(
          config.sourceAnchor.dx / config.imageSize.width * box.size.width,
          config.sourceAnchor.dy / config.imageSize.height * box.size.height,
        ),
      );
    }

    final before = contact();
    final gesture = await tester.startGesture(
      tester.getCenter(_object('Máy arcade')),
    );
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 100));
    expect(contact().dx, closeTo(before.dx, 0.001));
    expect(contact().dy, closeTo(before.dy, 0.001));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 100));
  });
}
