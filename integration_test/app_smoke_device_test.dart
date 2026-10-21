import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nhom_bar/main.dart';
import 'package:nhom_bar/games/artifact/screens/artifact_screen.dart';
import 'package:nhom_bar/games/bartender/screens/bartender_screen.dart';
import 'package:nhom_bar/games/bartender/screens/bartender_match_screen.dart';
import 'package:nhom_bar/screens/home/lobby_cats.dart';
import 'package:nhom_bar/screens/home/lobby_screen.dart';
import 'package:nhom_bar/screens/home/widgets/lobby_object.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('packaged resources, offline Bartender and arcade navigation', (
    tester,
  ) async {
    final assets = (await AssetManifest.loadFromAssetBundle(rootBundle))
        .listAssets();
    for (final asset in assets.where((path) => path.startsWith('assets/'))) {
      expect(
        (await rootBundle.load(asset)).lengthInBytes,
        greaterThan(0),
        reason: asset,
      );
    }
    expect(assets, contains('assets/images/lobby/tv.png'));
    expect(assets, isNot(contains('assets/rubik/three.module.js')));
    expect(assets, isNot(contains('assets/rubik/interactive-src.js')));
    for (final cat in ['Nam', 'Cam', 'Cho']) {
      for (final pose in ['dung', 'ngoi', 'nam', 'vo']) {
        expect(
          assets,
          contains('assets/images/character/$cat/${cat}_$pose.png'),
        );
      }
    }
    await tester.pumpWidget(const NhomBarApp());
    await tester.pump(const Duration(seconds: 2));
    Finder object(LobbyGame game) =>
        find.byWidgetPredicate((w) => w is LobbyObject && w.game == game);
    Future<void> waitForScreen(Finder screen) async {
      for (var i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (screen.evaluate().isNotEmpty) {
          await tester.pump(const Duration(milliseconds: 600));
          return;
        }
      }
      fail('Screen did not open: $screen');
    }

    // Touch the authored menu, away from the cats sitting over the stall.
    final stall = tester.getRect(object(LobbyGame.bartender));
    await tester.tapAt(
      stall.topLeft + Offset(stall.width * 70 / 400, stall.height * 290 / 480),
    );
    await waitForScreen(find.byType(BartenderScreen));
    expect(find.byType(BartenderScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Kiểm tra offline');
    await tester.tap(find.text('TẠO PHÒNG'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('MÃ PHÒNG'), findsOneWidget);
    await tester.tap(find.text('BẮT ĐẦU TRẬN ĐẤU!'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(BartenderMatchScreen), findsOneWidget);
    expect(find.text('ROUND 1'), findsOneWidget);
    Navigator.of(tester.element(find.byType(BartenderScreen))).pop();
    await waitForScreen(find.byType(LobbyScreen));
    await tester.tap(object(LobbyGame.arcade));
    await waitForScreen(find.byType(ArtifactScreen));
    expect(find.byType(ArtifactScreen), findsOneWidget);
    final web = find.byType(WebViewWidget);
    expect(web, findsOneWidget);
    final controller = tester
        .widget<WebViewWidget>(web)
        .platform
        .params
        .controller;
    var loaded = false;
    for (var i = 0; i < 100 && !loaded; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      final result = await controller.runJavaScriptReturningResult(
        "!!document.querySelector('canvas')?.getContext('webgl2')",
      );
      loaded = result == true || result == 'true';
    }
    expect(
      loaded,
      true,
      reason: 'The packaged arcade bundle must create its WebGL canvas',
    );
    final rect = tester.getRect(web);
    await tester.dragFrom(
      rect.topLeft + const Offset(20, 30),
      const Offset(60, 30),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pageBack();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(LobbyScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    debugPrint(
      '[AppSmoke] runtime assets, Bartender room/match, arcade WebGL/drag/back passed',
    );
    await tester.pumpWidget(const SizedBox());
  });
}
