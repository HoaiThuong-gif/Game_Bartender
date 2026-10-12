import 'package:nhom_bar/games/gacha/services/gacha_wallet.dart';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/gacha/data/gacha_rewards.dart';
import 'package:nhom_bar/games/gacha/models/gacha_ticket_state.dart';
import 'package:nhom_bar/games/gacha/screens/gacha_screen.dart';
import 'package:nhom_bar/games/gacha/services/gacha_collection.dart';
import 'package:nhom_bar/games/gacha/widgets/gacha_inventory_dialog.dart';
import 'package:nhom_bar/games/gacha/widgets/gacha_scene.dart';
import 'package:nhom_bar/games/gacha/widgets/reward_board.dart';
import 'package:nhom_bar/games/gacha/widgets/reward_icon.dart';
import 'package:nhom_bar/games/gacha/widgets/tear_ticket.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _SameRewardRandom implements Random {
  int draws = 0;

  @override
  int nextInt(int max) {
    draws++;
    return 2;
  }

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  double nextDouble() => throw UnimplementedError();
}

Future<void> _open(WidgetTester tester) async {
  final button = find.byKey(const ValueKey('gacha-inventory-button'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
  expect(find.byType(GachaInventoryDialog), findsOneWidget);
}

Future<void> _close(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('gacha-inventory-close')));
  await tester.pumpAndSettle();
  expect(find.byType(GachaInventoryDialog), findsNothing);
}

void _expectSameScene(GachaScene before, GachaScene after) {
  expect(after.state, before.state);
  expect(after.reward, same(before.reward));
  expect(after.result, same(before.result));
  expect(after.progress, before.progress);
  expect(after.tearFromLeft, before.tearFromLeft);
  expect(after.canDraw, before.canDraw);
  expect(after.canTear, before.canTear);
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets(
    'initial inventory shows all six source icons locked and zero count',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final collection = GachaCollection();
      final random = _SameRewardRandom();
      await tester.pumpWidget(
        MaterialApp(
          home: GachaScreen(
            wallet: GachaWallet(persist: false),
            collection: collection,
            random: random,
          ),
        ),
      );
      final before = tester.widget<GachaScene>(find.byType(GachaScene));
      await _open(tester);
      expect(find.text('Đã sưu tập 0/6'), findsOneWidget);
      for (final reward in gachaRewards) {
        final cell = find.byKey(
          ValueKey('gacha-collection-item-${reward.number}'),
        );
        expect(cell, findsOneWidget);
        expect(
          find.descendant(of: cell, matching: find.text(reward.name)),
          findsOneWidget,
        );
        expect(
          find.byKey(ValueKey('gacha-collection-locked-${reward.number}')),
          findsOneWidget,
        );
        final image = tester.widget<Image>(
          find.descendant(of: cell, matching: find.byType(Image)),
        );
        expect((image.image as AssetImage).assetName, reward.iconAssetPath);
      }
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.byType(GachaInventoryDialog), findsNothing);
      _expectSameScene(
        before,
        tester.widget<GachaScene>(find.byType(GachaScene)),
      );
      expect(random.draws, 0);
    },
  );

  testWidgets(
    'complete reveal saves winner once and inventory preserves result/highlight',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final collection = GachaCollection();
      final random = _SameRewardRandom();
      await tester.pumpWidget(
        MaterialApp(
          home: GachaScreen(
            wallet: GachaWallet(persist: false),
            collection: collection,
            random: random,
            viewerBuilder: (_) => const SizedBox(),
          ),
        ),
      );
      await collection.load();
      final draw = find.byKey(const ValueKey('gacha-draw-button'));
      for (var turn = 0; turn < 2; turn++) {
        await tester.ensureVisible(draw);
        await tester.tap(draw);
        await tester.pumpAndSettle();
        tester.widget<TearTicket>(find.byType(TearTicket)).onDrag(.3);
        await tester.pump();
        expect(collection.unlockedCount, turn == 0 ? 0 : 1);
        tester.widget<TearTicket>(find.byType(TearTicket)).onDrag(.4);
        await tester.pump();
        expect(
          tester.widget<GachaScene>(find.byType(GachaScene)).state,
          GachaTicketState.revealed,
        );
        expect(collection.unlockedCount, turn == 0 ? 0 : 1);
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump(const Duration(milliseconds: 16));
        expect(collection.unlockedCount, turn == 0 ? 0 : 1);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
        final before = tester.widget<GachaScene>(find.byType(GachaScene));
        expect(before.state, GachaTicketState.completed);
        expect(collection.ownedNumbers, {gachaRewards[2].number});
        expect(collection.unlockedCount, 1);
        await tester.tap(find.byKey(const ValueKey('gacha-result-close')));
        await tester.pumpAndSettle();
        await _open(tester);
        expect(find.text('Đã sưu tập 1/6'), findsOneWidget);
        expect(
          find.byKey(
            ValueKey('gacha-collection-locked-${gachaRewards[2].number}'),
          ),
          findsNothing,
        );
        expect(find.text('Đã sở hữu'), findsOneWidget);
        await _close(tester);
        _expectSameScene(
          before,
          tester.widget<GachaScene>(find.byType(GachaScene)),
        );
        expect(
          tester.widget<RewardBoard>(find.byType(RewardBoard)).selectedNumber,
          gachaRewards[2].number,
        );
        expect(
          tester
              .widget<RewardIcon>(
                find.byKey(const ValueKey('gacha-revealed-icon')),
              )
              .reward,
          same(gachaRewards[2]),
        );
        expect(random.draws, turn + 1);
      }
      await tester.pumpWidget(const SizedBox());
      final restarted = GachaCollection();
      await restarted.load();
      expect(restarted.ownedNumbers, {gachaRewards[2].number});
      expect(restarted.unlockedCount, 1);
      await tester.pumpWidget(
        MaterialApp(
          home: GachaScreen(
            wallet: GachaWallet(persist: false),
            collection: restarted,
          ),
        ),
      );
      await _open(tester);
      expect(find.text('Đã sưu tập 1/6'), findsOneWidget);
      expect(
        find.byKey(
          ValueKey('gacha-collection-locked-${gachaRewards[2].number}'),
        ),
        findsNothing,
      );
      await _close(tester);
    },
  );

  testWidgets(
    'inventory preserves sealed and partial left tear and can continue reveal',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final collection = GachaCollection();
      final random = _SameRewardRandom();
      await tester.pumpWidget(
        MaterialApp(
          home: GachaScreen(
            wallet: GachaWallet(persist: false),
            collection: collection,
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
        final ticket = tester.element(find.byType(TearTicket));
        await _open(tester);
        await _close(tester);
        _expectSameScene(
          before,
          tester.widget<GachaScene>(find.byType(GachaScene)),
        );
        expect(tester.element(find.byType(TearTicket)), same(ticket));
        expect(collection.unlockedCount, 0);
        expect(random.draws, 1);
      }
      tester.widget<TearTicket>(find.byType(TearTicket)).onDrag(-.4);
      await tester.pump();
      expect(
        tester.widget<TearTicket>(find.byType(TearTicket)).revealed,
        isTrue,
      );
      // Remove screen before completion: this unfinished turn is not collected.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
      expect(collection.unlockedCount, 0);
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [const Size(320, 568), const Size(844, 390)]) {
    testWidgets('inventory grid fits $size with large text', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final collection = GachaCollection();
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.6)),
            child: child!,
          ),
          home: GachaScreen(
            wallet: GachaWallet(persist: false),
            collection: collection,
          ),
        ),
      );
      await _open(tester);
      final first = tester.getRect(
        find.byKey(const ValueKey('gacha-collection-item-1')),
      );
      final third = tester.getRect(
        find.byKey(const ValueKey('gacha-collection-item-3')),
      );
      if (size.width < 440) {
        expect(third.top, greaterThan(first.top));
      } else {
        expect(third.top, first.top);
      }
      await tester.ensureVisible(
        find.byKey(const ValueKey('gacha-collection-item-6')),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _close(tester);
    });
  }
}
