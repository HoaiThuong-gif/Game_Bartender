import 'package:nhom_bar/games/gacha/services/gacha_collection.dart';
import 'package:nhom_bar/games/gacha/services/gacha_wallet.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/gacha/screens/gacha_screen.dart';
import 'package:nhom_bar/games/gacha/widgets/reward_board.dart';
import 'package:nhom_bar/games/gacha/widgets/reward_icon.dart';
import 'package:nhom_bar/games/gacha/widgets/tear_ticket.dart';

void main() {
  for (final size in [
    const Size(360, 800),
    const Size(393, 873),
    const Size(412, 915),
    const Size(320, 568),
    const Size(844, 390),
  ]) {
    testWidgets('shop scale and spacing above navigation at $size', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: const EdgeInsets.only(top: 24, bottom: 20),
              textScaler: const TextScaler.linear(1.6),
            ),
            child: child!,
          ),
          home: Scaffold(
            body: GachaScreen(
              wallet: GachaWallet(persist: false),
              collection: GachaCollection(),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.store),
                  label: 'Lobby',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.confirmation_number),
                  label: 'Gacha',
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      Rect rect(String key) => tester.getRect(find.byKey(ValueKey(key)));
      final background = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName.endsWith('/background.png'),
      );
      final backdrop = tester.getRect(background);
      expect(backdrop.width, size.width);
      final scene = rect('gacha-content-bounds');
      final fit = applyBoxFit(
        BoxFit.cover,
        const Size(941, 1672),
        backdrop.size,
      );
      final source = Alignment.center.inscribe(
        fit.source,
        const Rect.fromLTWH(0, 0, 941, 1672),
      );
      final scale = backdrop.width / source.width;
      final lamp = Rect.fromLTWH(
        backdrop.left + (580 - source.left) * scale,
        backdrop.top - source.top * scale,
        204 * scale,
        275 * scale,
      );
      final board = tester.getRect(find.byType(RewardBoard));
      expect(scene.width, lessThanOrEqualTo(size.width));
      expect(
        scene.bottom,
        lessThanOrEqualTo(tester.getRect(find.byType(BottomNavigationBar)).top),
      );
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(board.width / scene.width, closeTo(.60, .001));
      expect(board.width / board.height, closeTo(1122 / 1402, .001));
      expect(board.left - scene.left, closeTo(scene.width * .25, .01));
      expect(board.top - scene.top, greaterThanOrEqualTo(scene.height * .145));
      expect(board.top - scene.top, lessThan(scene.height * .17));
      expect(board.overlaps(lamp), isFalse);
      for (final key in ['gacha-rates', 'gacha-inventory', 'gacha-price']) {
        expect(rect(key).overlaps(lamp), isFalse);
      }
      expect(rect('gacha-rates').width / scene.width, closeTo(.16, .001));
      expect(
        rect('gacha-inventory').top - rect('gacha-rates').bottom,
        closeTo(scene.width * .034, .01),
      );
      // The board PNG has a transparent right margin (roughly 5.5%).
      final boardPaper = Rect.fromLTRB(
        board.left,
        board.top,
        board.right - board.width * .055,
        board.bottom,
      );
      // Side-button artwork begins inside its transparent/glowing left margin.
      for (final key in ['gacha-rates', 'gacha-inventory']) {
        final button = rect(key);
        final buttonFace = Rect.fromLTRB(
          button.left + button.width * .18,
          button.top,
          button.right,
          button.bottom,
        );
        expect(buttonFace.overlaps(boardPaper), isFalse);
      }
      expect(rect('gacha-ticket-box').width / scene.width, closeTo(.42, .001));
      expect(
        rect('gacha-ticket-box').width / rect('gacha-ticket-box').height,
        closeTo(1536 / 1024, .001),
      );
      expect(rect('gacha-price').width / scene.width, closeTo(.30, .001));
      final draw = find.byKey(const ValueKey('gacha-draw-button'));
      expect(tester.getRect(draw), rect('gacha-ticket-box'));
      expect(find.byKey(const ValueKey('gacha-sign')), findsNothing);
      expect(find.byKey(const ValueKey('gacha-primary-action')), findsNothing);
      expect(find.text('Chạm vào hộp để bốc giấy'), findsOneWidget);
      expect(tester.getRect(draw).bottom, lessThanOrEqualTo(scene.bottom));
      expect(find.byType(TearTicket), findsNothing);
      await tester.tap(draw);
      await tester.pumpAndSettle();
      final ticket = find.byType(TearTicket);
      expect(ticket, findsOneWidget);
      final ticketRect = tester.getRect(ticket);
      final viewport = rect('gacha-scene-canvas');
      expect(
        ticketRect.width,
        closeTo(
          (viewport.width * .82).clamp(0, viewport.height * .72 * 1.4),
          .01,
        ),
      );
      expect(ticketRect.width / ticketRect.height, closeTo(1.4, .001));
      expect(ticketRect.center.dx, closeTo(viewport.center.dx, .01));
      expect(ticketRect.center.dy, closeTo(viewport.center.dy, .01));
      expect(viewport.contains(ticketRect.topLeft), isTrue);
      expect(viewport.contains(ticketRect.bottomRight), isTrue);
      expect(
        tester.getRect(find.byKey(const ValueKey('gacha-ticket-drag'))),
        ticketRect,
      );
      expect(rect('gacha-guidance').overlaps(tester.getRect(draw)), isFalse);
      final rewardIcons = find.descendant(
        of: find.byType(RewardBoard),
        matching: find.byType(RewardIcon),
      );
      expect(
        tester.widget<RewardIcon>(rewardIcons.first).size,
        closeTo(board.width * .18, .001),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
