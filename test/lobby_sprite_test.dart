import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/screens/home/widgets/lobby_sprite.dart';

void main() {
  testWidgets(
    'frame clock pauses offscreen, on background and with reduced motion',
    (tester) async {
      Widget scene({bool active = true, bool reduced = false}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: TickerMode(
            enabled: active,
            child: const LobbySprite(
              name: 'flag',
              count: 12,
              period: Duration(milliseconds: 1440),
            ),
          ),
        ),
      );
      String asset() =>
          (tester.widget<Image>(find.byType(Image)).image as AssetImage)
              .assetName;
      await tester.pumpWidget(scene());
      await tester.pump(const Duration(milliseconds: 130));
      expect(asset(), endsWith('flag_1.png'));
      await tester.pumpWidget(scene(active: false));
      final paused = asset();
      await tester.pump(const Duration(seconds: 2));
      expect(asset(), paused);
      await tester.pumpWidget(scene(reduced: true));
      await tester.pump(const Duration(seconds: 2));
      expect(asset(), paused);
      await tester.pumpWidget(scene());
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 2));
      expect(asset(), paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 130));
      expect(asset(), isNot(paused));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );
}
