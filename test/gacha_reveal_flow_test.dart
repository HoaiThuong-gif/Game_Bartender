import 'package:nhom_bar/games/gacha/services/gacha_collection.dart';
import 'package:nhom_bar/games/gacha/services/gacha_wallet.dart';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/gacha/screens/gacha_screen.dart';
import 'package:nhom_bar/games/gacha/widgets/reward_board.dart';
import 'package:nhom_bar/games/gacha/widgets/tear_ticket.dart';
import 'package:nhom_bar/games/gacha/widgets/paper_tear_mask.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  for (final direction in [1.0, -1.0]) {
    testWidgets(
      'stationary mask tears then number, highlight and panel $direction',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final haptics = <String>[];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'HapticFeedback.vibrate') {
              haptics.add(call.arguments as String);
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: GachaScreen(
              wallet: GachaWallet(persist: false),
              collection: GachaCollection(),
              random: Random(7),
            ),
          ),
        );
        await tester.tap(find.byKey(const ValueKey('gacha-draw-button')));
        await tester.pumpAndSettle();
        final largePaper = tester.getRect(find.byType(TearTicket));
        tester
            .widget<TearTicket>(find.byType(TearTicket))
            .onDrag(direction * .3);
        await tester.pump();
        final cover = tester.widget<ClipPath>(
          find.byKey(const ValueKey('gacha-paper-cover')),
        );
        final mask = cover.clipper! as PaperTearClipper;
        expect(mask.geometry.progress, closeTo(.3, .001));
        expect(mask.geometry.fromLeft, direction > 0);
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('gacha-paper-cover')),
            matching: find.byType(Transform),
          ),
          findsNothing,
        );
        expect(haptics, ['HapticFeedbackType.selectionClick']);
        tester
            .widget<TearTicket>(find.byType(TearTicket))
            .onDrag(direction * .4);
        await tester.pump();
        expect(haptics, [
          'HapticFeedbackType.selectionClick',
          'HapticFeedbackType.lightImpact',
        ]);
        expect(
          tester.widget<RewardBoard>(find.byType(RewardBoard)).selectedNumber,
          isNull,
        );
        expect(
          tester
              .widget<Opacity>(
                find.byKey(const ValueKey('gacha-number-reveal')),
              )
              .opacity,
          .85,
        );
        for (var i = 0; i < 4; i++) {
          expect(find.byKey(ValueKey('gacha-paper-scrap-$i')), findsOneWidget);
        }
        await tester.pump(const Duration(milliseconds: 250));
        expect(find.byKey(const ValueKey('gacha-paper-cover')), findsNothing);
        await tester.pump(const Duration(milliseconds: 150));
        expect(
          tester
              .widget<Opacity>(
                find.byKey(const ValueKey('gacha-number-reveal')),
              )
              .opacity,
          1,
        );
        await tester.pump(const Duration(milliseconds: 99));
        expect(
          tester.getRect(find.byType(TearTicket)),
          largePaper,
          reason: 'keep the number on the large centered paper for 500 ms',
        );
        expect(
          tester.widget<RewardBoard>(find.byType(RewardBoard)).selectedNumber,
          isNull,
        );
        expect(find.byKey(const ValueKey('gacha-result')), findsNothing);
        await tester.pump(const Duration(milliseconds: 1));
        final board = tester.widget<RewardBoard>(find.byType(RewardBoard));
        expect(board.emphasizeSelection, isTrue);
        expect(board.selectedNumber, isNotNull);
        expect(
          tester
              .widgetList<AnimatedOpacity>(
                find.descendant(
                  of: find.byType(RewardBoard),
                  matching: find.byType(AnimatedOpacity),
                ),
              )
              .where((w) => w.opacity == .4),
          hasLength(5),
        );
        await tester.pump(const Duration(milliseconds: 599));
        final loweredPaper = tester.getRect(find.byType(TearTicket));
        expect(loweredPaper.width, closeTo(largePaper.width * .82, .01));
        expect(loweredPaper.center.dy, greaterThan(largePaper.center.dy));
        expect(find.byKey(const ValueKey('gacha-result')), findsNothing);
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('gacha-result')), findsOneWidget);
        expect(haptics.last, 'HapticFeedbackType.lightImpact');
        await tester.tap(find.byKey(const ValueKey('gacha-result-close')));
        await tester.pumpAndSettle();
        final hapticCount = haptics.length;
        for (var i = 0; i < 30; i++) {
          await tester.tap(find.byKey(const ValueKey('gacha-show-result')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('gacha-result-close')));
          await tester.pumpAndSettle();
        }
        expect(
          haptics.length,
          hapticCount,
          reason:
              'reviewing an existing reward does not repeat success haptics',
        );
        expect(tester.binding.transientCallbackCount, 0);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('leaving during highlight cancels pending completion safely', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GachaScreen(
          wallet: GachaWallet(persist: false),
          collection: GachaCollection(),
          random: Random(7),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('gacha-draw-button')));
    await tester.pumpAndSettle();
    tester.widget<TearTicket>(find.byType(TearTicket)).onDrag(.8);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      tester.widget<RewardBoard>(find.byType(RewardBoard)).emphasizeSelection,
      isTrue,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });
}
