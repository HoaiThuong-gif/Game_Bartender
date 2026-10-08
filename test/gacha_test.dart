import 'package:nhom_bar/games/gacha/services/gacha_collection.dart';
import 'package:nhom_bar/games/gacha/services/gacha_wallet.dart';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/gacha/screens/gacha_screen.dart';
import 'package:nhom_bar/games/gacha/widgets/tear_ticket.dart';

void main() {
  for (final direction in [1.0, -1.0]) {
    testWidgets('one session, cancelled swipe, reveal and cleanup $direction', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: GachaScreen(
            wallet: GachaWallet(persist: false),
            collection: GachaCollection(),
            random: Random(7),
          ),
        ),
      );
      final draw = find.byKey(const ValueKey('gacha-draw-button'));
      final drag = find.byKey(const ValueKey('gacha-ticket-drag'));
      expect(find.byType(TearTicket), findsNothing);
      await tester.tap(draw);
      await tester.pumpAndSettle();
      final original = tester
          .widget<TearTicket>(find.byType(TearTicket))
          .reward;
      await tester.tap(draw);
      await tester.pumpAndSettle();
      expect(find.byType(TearTicket), findsOneWidget);
      expect(
        tester.widget<TearTicket>(find.byType(TearTicket)).reward,
        same(original),
      );
      final width = tester.getSize(drag).width;
      await tester.drag(drag, Offset(direction * width * .3, 0));
      await tester.pump();
      final reset = tester.widget<TearTicket>(find.byType(TearTicket));
      expect(reset.progress, greaterThan(0));
      expect(reset.revealed, isFalse);
      expect(reset.reward, same(original));
      await tester.drag(drag, Offset(direction * width * .9, 0));
      await tester.pump();
      expect(
        tester.widget<TearTicket>(find.byType(TearTicket)).revealed,
        isTrue,
      );
      expect(find.byKey(const ValueKey('gacha-revealed-icon')), findsNothing);
      await tester.tap(draw);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(TearTicket), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        tester.widget<TearTicket>(find.byType(TearTicket)).enabled,
        isFalse,
      );
      await tester.tap(draw);
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(find.byType(TearTicket), findsNothing);
      expect(find.byKey(const ValueKey('gacha-result')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('gacha-result-next')));
      await tester.pumpAndSettle();
      final fresh = tester.widget<TearTicket>(find.byType(TearTicket));
      expect(fresh.progress, 0);
      expect(fresh.revealed, isFalse);
      expect(find.byKey(const ValueKey('gacha-revealed-icon')), findsNothing);
      expect(tester.takeException(), isNull);
      // Leaving while a reveal timer is pending must be safe.
      fresh.onDrag(direction * .8);
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    });
  }
}
