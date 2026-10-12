import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/gacha/data/gacha_rewards.dart';
import 'package:nhom_bar/games/gacha/screens/gacha_screen.dart';
import 'package:nhom_bar/games/gacha/services/gacha_collection.dart';
import 'package:nhom_bar/games/gacha/services/gacha_wallet.dart';
import 'package:nhom_bar/games/gacha/widgets/gacha_scene.dart';
import 'package:nhom_bar/games/gacha/widgets/paper_tear_mask.dart';
import 'package:nhom_bar/games/gacha/widgets/tear_ticket.dart';

void main() {
  const size = Size(240, 160);
  test('fixed jagged frontier is stable, mirrored and bounded', () {
    const left = PaperTearGeometry(progress: .35, fromLeft: true, fingerY: .3);
    const right = PaperTearGeometry(
      progress: .35,
      fromLeft: false,
      fingerY: .3,
    );
    final edge = left.edge(size);
    expect(edge, left.edge(size));
    expect(edge, hasLength(25));
    expect(edge.map((p) => p.dx).toSet().length, greaterThan(10));
    final mirrored = right.edge(size);
    for (var i = 0; i < edge.length; i++) {
      expect(edge[i].dx + mirrored[i].dx, closeTo(size.width, .001));
      expect(edge[i].dy, mirrored[i].dy);
      expect(edge[i].dx, inInclusiveRange(0, size.width));
    }
    expect(left.cover(size).contains(const Offset(10, 80)), false);
    expect(left.cover(size).contains(const Offset(220, 80)), true);
    expect(right.cover(size).contains(const Offset(10, 80)), true);
    expect(right.cover(size).contains(const Offset(220, 80)), false);
  });
  test(
    'cover endpoints and simple fallback reveal without moving the paper',
    () {
      for (final direction in [true, false]) {
        expect(
          PaperTearGeometry(
            progress: 0,
            fromLeft: direction,
          ).cover(size).contains(size.center(Offset.zero)),
          true,
        );
        expect(
          PaperTearGeometry(
            progress: 1,
            fromLeft: direction,
          ).cover(size).computeMetrics().isEmpty,
          true,
        );
        final fallback = PaperTearGeometry(
          progress: .3,
          fromLeft: direction,
          simple: true,
        );
        expect(fallback.edge(size), hasLength(25));
        expect(fallback.edge(size), fallback.edge(size));
      }
    },
  );
  test(
    'finger curvature is local and clipper repaints only changed geometry',
    () {
      const a = PaperTearGeometry(progress: .3, fromLeft: true, fingerY: .2);
      const b = PaperTearGeometry(progress: .3, fromLeft: true, fingerY: .8);
      expect(
        PaperTearClipper(a).shouldReclip(const PaperTearClipper(a)),
        false,
      );
      expect(PaperTearClipper(a).shouldReclip(const PaperTearClipper(b)), true);
      expect(a.edge(size)[5].dx, greaterThan(b.edge(size)[5].dx));
      expect(a.edge(size)[19].dx, lessThan(b.edge(size)[19].dx));
    },
  );
  testWidgets('many progress samples only rebuild paper and retain scene', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GachaScreen(
          wallet: GachaWallet(persist: false),
          collection: GachaCollection(),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('gacha-draw-button')));
    await tester.pumpAndSettle();
    tester.widget<TearTicket>(find.byType(TearTicket)).onDrag(.1);
    await tester.pump();
    final scene = tester.widget<GachaScene>(find.byType(GachaScene));
    final ticket = tester.element(find.byType(TearTicket));
    for (var i = 0; i < 80; i++) {
      tester.widget<TearTicket>(find.byType(TearTicket)).onDrag(.002);
      await tester.pump();
      expect(tester.widget<GachaScene>(find.byType(GachaScene)), same(scene));
      expect(tester.element(find.byType(TearTicket)), same(ticket));
    }
    final torn = tester.widget<TearTicket>(find.byType(TearTicket)).progress;
    expect(torn, closeTo(.26, .001));
    tester.widget<TearTicket>(find.byType(TearTicket)).onDrag(-.4);
    await tester.pump();
    expect(tester.widget<TearTicket>(find.byType(TearTicket)).progress, torn);
    tester.widget<TearTicket>(find.byType(TearTicket)).onDragEnd();
    await tester.pump();
    expect(tester.widget<TearTicket>(find.byType(TearTicket)).progress, torn);
    expect(find.byKey(const ValueKey('gacha-result')), findsNothing);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), null);
  });
  testWidgets(
    'fallback cover is clipped, stationary and disposed after completion',
    (tester) async {
      Widget app(bool revealed) => MaterialApp(
        home: Center(
          child: SizedBox(
            width: 240,
            child: TearTicket(
              reward: gachaRewards.first,
              progress: revealed ? 1 : .4,
              revealed: revealed,
              tearFromLeft: true,
              simpleMask: true,
              onDrag: (_) {},
              onDragEnd: () {},
            ),
          ),
        ),
      );
      await tester.pumpWidget(app(false));
      final cover = find.byKey(const ValueKey('gacha-paper-cover'));
      expect(tester.widget<ClipPath>(cover).clipper, isA<PaperTearClipper>());
      expect(
        find.descendant(of: cover, matching: find.byType(Transform)),
        findsNothing,
      );
      final position = tester.getTopLeft(cover);
      await tester.pumpWidget(app(true));
      await tester.pump(const Duration(milliseconds: 125));
      expect(tester.getTopLeft(cover), position);
      await tester.pump(const Duration(milliseconds: 125));
      expect(cover, findsNothing);
      await tester.pump(const Duration(milliseconds: 250));
      for (var i = 0; i < 4; i++) {
        expect(find.byKey(ValueKey('gacha-paper-scrap-$i')), findsNothing);
      }
      await tester.pumpWidget(const SizedBox());
      expect(tester.binding.transientCallbackCount, 0);
    },
  );
  testWidgets('moving finger vertically never covers an already torn row', (
    tester,
  ) async {
    final progress = ValueNotifier<double>(.3);
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 240,
            child: TearTicket(
              reward: gachaRewards.first,
              progress: .3,
              progressListenable: progress,
              revealed: false,
              tearFromLeft: true,
              onDrag: (_) {},
              onDragEnd: () {},
            ),
          ),
        ),
      ),
    );
    final drag = tester.widget<GestureDetector>(
      find.byKey(const ValueKey('gacha-ticket-drag')),
    );
    final before =
        (tester
                    .widget<ClipPath>(
                      find.byKey(const ValueKey('gacha-paper-cover')),
                    )
                    .clipper!
                as PaperTearClipper)
            .geometry
            .edge(const Size(240, 160));
    drag.onHorizontalDragUpdate!(
      DragUpdateDetails(
        delta: Offset.zero,
        primaryDelta: 0,
        globalPosition: const Offset(100, 140),
        localPosition: const Offset(100, 140),
      ),
    );
    await tester.pump();
    final after =
        (tester
                    .widget<ClipPath>(
                      find.byKey(const ValueKey('gacha-paper-cover')),
                    )
                    .clipper!
                as PaperTearClipper)
            .geometry
            .edge(const Size(240, 160));
    for (var i = 0; i < 25; i++) {
      expect(after[i].dx, greaterThanOrEqualTo(before[i].dx));
    }
    await tester.pumpWidget(const SizedBox());
    progress.dispose();
  });
}
