import 'package:nhom_bar/games/gacha/services/gacha_collection.dart';
import 'package:nhom_bar/games/gacha/services/gacha_wallet.dart';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/gacha/data/gacha_rewards.dart';
import 'package:nhom_bar/games/gacha/models/gacha_reward_pool.dart';
import 'package:nhom_bar/games/gacha/screens/gacha_screen.dart';
import 'package:nhom_bar/games/gacha/widgets/gacha_rates_dialog.dart';
import 'package:nhom_bar/games/gacha/widgets/gacha_scene.dart';
import 'package:nhom_bar/games/gacha/widgets/reward_icon.dart';
import 'package:nhom_bar/games/gacha/widgets/tear_ticket.dart';

class _SlotRandom implements Random {
  int draws = 0;
  final bounds = <int>[];

  @override
  int nextInt(int max) {
    bounds.add(max);
    return draws++ % max;
  }

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  double nextDouble() => throw UnimplementedError();
}

void main() {
  test('probabilities match every equally likely random slot', () {
    final random = _SlotRandom();
    final counts = <Object, int>{};
    for (var i = 0; i < gachaRewards.length; i++) {
      final reward = gachaRewardPool.draw(random);
      expect(reward, same(gachaRewards[i]));
      counts.update(reward, (count) => count + 1, ifAbsent: () => 1);
    }
    expect(random.bounds, everyElement(gachaRewards.length));
    for (final reward in gachaRewards) {
      expect(
        gachaRewardPool.probabilityOf(reward),
        counts[reward]! / random.draws,
      );
      expect(gachaRewardPool.probabilityOf(reward), closeTo(1 / 6, 1e-12));
    }
    // Derivation also follows a different pool size, rather than a fixed percent.
    final smallerPool = GachaRewardPool(gachaRewards.take(2).toList());
    expect(smallerPool.probabilityOf(gachaRewards.first), .5);
    expect(smallerPool.probabilityOf(gachaRewards.last), 0);
  });

  testWidgets(
    'rates button shows six source rewards with correct icons and rates',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final random = _SlotRandom();
      await tester.pumpWidget(
        MaterialApp(
          home: GachaScreen(
            wallet: GachaWallet(persist: false),
            collection: GachaCollection(),
            random: random,
          ),
        ),
      );
      final before = tester.widget<GachaScene>(find.byType(GachaScene));
      await tester.tap(find.byKey(const ValueKey('gacha-rates-button')));
      await tester.pumpAndSettle();
      final dialog = find.byType(GachaRatesDialog);
      expect(dialog, findsOneWidget);
      expect(
        tester.widget<GachaRatesDialog>(dialog).pool,
        same(gachaRewardPool),
      );
      expect(
        find.descendant(of: dialog, matching: find.byType(RewardIcon)),
        findsNWidgets(6),
      );
      for (final reward in gachaRewards) {
        final row = find.byKey(ValueKey('gacha-rate-${reward.number}'));
        expect(row, findsOneWidget);
        expect(
          find.descendant(of: row, matching: find.text(reward.name)),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: row,
            matching: find.text(
              '${(gachaRewardPool.probabilityOf(reward) * 100).toStringAsFixed(2)}%',
            ),
          ),
          findsOneWidget,
        );
        final icon = tester.widget<Image>(
          find.descendant(of: row, matching: find.byType(Image)),
        );
        expect((icon.image as AssetImage).assetName, reward.iconAssetPath);
      }
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(dialog, findsNothing);
      final after = tester.widget<GachaScene>(find.byType(GachaScene));
      expect(after.state, before.state);
      expect(after.reward, before.reward);
      expect(after.result, before.result);
      expect(random.draws, 0);
    },
  );

  testWidgets('closing rates preserves sealed and partially torn ticket', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final random = _SlotRandom();
    await tester.pumpWidget(
      MaterialApp(
        home: GachaScreen(
          wallet: GachaWallet(persist: false),
          collection: GachaCollection(),
          random: random,
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('gacha-draw-button')));
    await tester.pumpAndSettle();
    for (final progress in [0.0, -.3]) {
      if (progress != 0) {
        tester.widget<TearTicket>(find.byType(TearTicket)).onDrag(progress);
        await tester.pump();
      }
      final before = tester.widget<GachaScene>(find.byType(GachaScene));
      final ticketElement = tester.element(find.byType(TearTicket));
      await tester.tap(find.byKey(const ValueKey('gacha-rates-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('gacha-rates-close')));
      await tester.pumpAndSettle();
      final after = tester.widget<GachaScene>(find.byType(GachaScene));
      expect(after.state, before.state);
      expect(after.reward, same(before.reward));
      expect(after.result, before.result);
      expect(after.progress, before.progress);
      expect(after.tearFromLeft, before.tearFromLeft);
      expect(after.canTear, before.canTear);
      expect(after.canDraw, before.canDraw);
      expect(tester.element(find.byType(TearTicket)), same(ticketElement));
      expect(random.draws, 1);
    }
    // Continue the same leftward tear after dismissing the dialog.
    tester.widget<TearTicket>(find.byType(TearTicket)).onDrag(-.4);
    await tester.pump();
    expect(tester.widget<TearTicket>(find.byType(TearTicket)).revealed, isTrue);
    expect(
      tester.widget<GachaScene>(find.byType(GachaScene)).result,
      same(gachaRewards.first),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(320, 568), const Size(844, 390)]) {
    testWidgets('rates dialog fits $size with large text', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.6)),
            child: child!,
          ),
          home: GachaScreen(
            wallet: GachaWallet(persist: false),
            collection: GachaCollection(),
          ),
        ),
      );
      final ratesButton = find.byKey(const ValueKey('gacha-rates-button'));
      await tester.ensureVisible(ratesButton);
      await tester.tap(ratesButton);
      await tester.pumpAndSettle();
      expect(find.byType(GachaRatesDialog), findsOneWidget);
      await tester.ensureVisible(
        find.byKey(ValueKey('gacha-rate-${gachaRewards.last.number}')),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
