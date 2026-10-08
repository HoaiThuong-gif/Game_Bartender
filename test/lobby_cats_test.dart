import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/screens/home/lobby_cats.dart';
import 'package:nhom_bar/screens/home/lobby_layout.dart';
import 'package:nhom_bar/screens/home/lobby_screen.dart';
import 'package:nhom_bar/screens/home/widgets/lobby_cat_layer.dart';

class _ScriptedPopulation extends CatPopulation {
  _ScriptedPopulation() : super(Random(1)) {
    for (final cat in characters.values) {
      cat.spawnIndex = null;
    }
    characters[CatType.black]!
      ..spawnIndex = 0
      ..pose = CatPose.sitting;
  }
  final steps = Queue<CatChange>();
  @override
  Duration nextInterval() => const Duration(seconds: 12);
  @override
  CatChange? planChange() => steps.isEmpty ? null : steps.removeFirst();
}

List<String> identities(WidgetTester tester) => tester
    .widgetList<CatSprite>(find.byType(CatSprite))
    .map((sprite) => sprite.cat.identity)
    .toList();

Future<void> _load(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 350)),
  );
  await tester.pump();
}

void main() {
  test(
    'identity, occupancy, pose rules and steady 1-3 count survive many updates',
    () {
      final seenCounts = <int>{};
      final seenPoses = <CatPose>{};
      final seenSlots = <int>{};
      for (var seed = 0; seed < 40; seed++) {
        final population = CatPopulation(Random(seed));
        final originalCharacters = Map.of(population.characters);
        for (var step = 0; step < 100; step++) {
          final cats = population.visible.toList();
          seenCounts.add(cats.length);
          seenPoses.addAll(cats.map((cat) => cat.pose));
          seenSlots.addAll(cats.map((cat) => cat.spawnIndex!));
          expect(cats.length, inInclusiveRange(1, 3));
          expect(cats.map((cat) => cat.spawnIndex).toSet().length, cats.length);
          for (var i = 0; i < cats.length; i++) {
            final spawn = LobbyCats.spawns[cats[i].spawnIndex!];
            expect(spawn.allowedPoses, contains(cats[i].pose));
            for (var j = i + 1; j < cats.length; j++) {
              expect(
                spawn.visualRect.overlaps(
                  LobbyCats.spawns[cats[j].spawnIndex!].visualRect,
                ),
                isFalse,
              );
            }
          }
          final interval = population.nextInterval();
          expect(interval, greaterThanOrEqualTo(LobbyCats.minInterval));
          expect(interval, lessThanOrEqualTo(LobbyCats.maxInterval));
          final change = population.planChange();
          if (change == null) continue;
          final before = {
            for (final cat in cats) cat.type: (cat.spawnIndex, cat.pose),
          };
          population.begin(change);
          expect({
            for (final cat in population.visible)
              cat.type: (cat.spawnIndex, cat.pose),
          }, before);
          population.commit();
          population.finish();
          for (final type in CatType.values) {
            expect(population.characters[type], same(originalCharacters[type]));
            expect(population.characters[type]!.type, type);
          }
        }
        population.dispose();
      }
      expect(seenCounts, {1, 2, 3});
      expect(seenPoses, CatPose.values.toSet());
      expect(seenSlots.length, LobbyCats.spawns.length);
    },
  );

  test(
    'ground cats avoid game objects; elevated positions allow suitable poses',
    () {
      final objects = [
        LobbyLayout.arcade.visualRect,
        LobbyLayout.bartender.visualRect,
        LobbyLayout.rubik.visualRect,
      ];
      for (final spawn in LobbyCats.spawns.take(4)) {
        if (spawn.depth == CatDepth.behindGames) continue;
        for (final object in objects) {
          expect(spawn.visualRect.overlaps(object), isFalse);
        }
      }
      for (final spawn in LobbyCats.spawns.skip(4)) {
        expect(spawn.allowedPoses, isNot(contains(CatPose.standing)));
      }
      for (final spawn in LobbyCats.spawns) {
        expect(
          spawn.visualRect.overlaps(LobbyLayout.rubik.visualRect.inflate(12)),
          isFalse,
          reason: '${spawn.name} must leave space around the tabletop cube',
        );
      }
      for (final type in CatType.values) {
        for (final pose in CatPose.values) {
          expect(
            LobbyCat(type, pose).quarterTurns,
            pose == CatPose.sleeping ? 1 : 0,
          );
        }
      }
    },
  );

  for (final move in [false, true]) {
    testWidgets(
      move ? 'movement waits for full disappearance before changing surface' : 'replacement fades old identity out, waits, then fades new identity in',
      (tester) async {
        final population = _ScriptedPopulation();
        final oldCharacter = population.characters[CatType.black];
        population.steps.add(
          CatChange(
            outgoing: CatType.black,
            incoming: move ? CatType.black : CatType.orange,
            spawnIndex: move ? 4 : 0,
            pose: CatPose.sleeping,
          ),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: SizedBox.expand(
              child: LobbyCatHost(
                population: population,
                child: Stack(
                  children: [
                    for (final depth in CatDepth.values)
                      Positioned.fill(child: LobbyCatLayer(depth: depth)),
                  ],
                ),
              ),
            ),
          ),
        );
        await _load(tester);
        double opacity() => tester
            .widget<FadeTransition>(find.byType(FadeTransition).last)
            .opacity
            .value;
        expect(identities(tester), ['black']);
        await tester.pump(const Duration(seconds: 12));
        expect(population.pending, isNotNull);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 225));
        expect(opacity(), inExclusiveRange(0, 1));
        expect(population.characters[CatType.black]!.spawnIndex, 0);
        expect(population.characters[CatType.black]!.pose, CatPose.sitting);
        await tester.pump(const Duration(milliseconds: 226));
        expect(opacity(), 0);
        await tester.pump(const Duration(milliseconds: 899));
        expect(identities(tester), ['black']);
        expect(opacity(), 0);
        await tester.pump(const Duration(milliseconds: 1));
        expect(identities(tester), [move ? 'black' : 'orange']);
        expect(opacity(), 0);
        await tester.pump(const Duration(milliseconds: 451));
        expect(opacity(), 1);
        expect(population.pending, isNull);
        expect(population.characters[CatType.black], same(oldCharacter));
        await tester.pumpWidget(const SizedBox());
        population.dispose();
      },
    );
  }

  testWidgets(
    'timers and active fades pause offscreen/background and dispose safely',
    (tester) async {
      final population = _ScriptedPopulation();
      population.steps.add(
        const CatChange(
          outgoing: CatType.black,
          incoming: CatType.black,
          spawnIndex: 4,
          pose: CatPose.sleeping,
        ),
      );
      var enabled = true;
      late StateSetter setHostState;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              setHostState = setState;
              return TickerMode(
                enabled: enabled,
                child: LobbyCatHost(
                  population: population,
                  child: Stack(
                    children: [
                      for (final depth in CatDepth.values)
                        Positioned.fill(child: LobbyCatLayer(depth: depth)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
      await _load(tester);
      await tester.pump(const Duration(seconds: 11));
      expect(population.pending, isNull);
      setHostState(() => enabled = false);
      await tester.pump();
      await tester.pump(const Duration(seconds: 60));
      expect(population.pending, isNull);
      setHostState(() => enabled = true);
      await tester.pump();
      await tester.pump(const Duration(seconds: 12));
      await tester.pump(const Duration(milliseconds: 100));
      final fade = tester
          .widget<FadeTransition>(find.byType(FadeTransition).last)
          .opacity
          .value;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 60));
      expect(
        tester
            .widget<FadeTransition>(find.byType(FadeTransition).last)
            .opacity
            .value,
        fade,
      );
      expect(population.characters[CatType.black]!.spawnIndex, 0);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pump(LobbyCats.emptyDuration);
      await tester.pump(LobbyCats.fadeDuration);
      expect(population.characters[CatType.black]!.spawnIndex, 4);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 60));
      expect(tester.takeException(), isNull);
      population.dispose();
    },
  );

  testWidgets('each spawn renders on its configured surface and depth', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final population = _ScriptedPopulation();
    for (var i = 0; i < LobbyCats.spawns.length; i++) {
      final spawn = LobbyCats.spawns[i];
      population.characters[CatType.black]!
        ..spawnIndex = i
        ..pose = spawn.allowedPoses.contains(CatPose.sleeping) && i >= 4
            ? CatPose.sleeping
            : CatPose.sitting;
      await tester.pumpWidget(
        MaterialApp(
          home: LobbyScreen(catPopulation: population),
        ),
      );
      population.notifyListeners();
      await _load(tester);
      expect(find.byType(CatSprite), findsOneWidget);
      final layer = find.byWidgetPredicate(
        (widget) => widget is LobbyCatLayer && widget.depth == spawn.depth,
      );
      expect(
        find.descendant(of: layer, matching: find.byType(CatSprite)),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
    population.dispose();
  });
}
