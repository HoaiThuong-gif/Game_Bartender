// ignore_for_file: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import '../models/match_timer.dart';
import '../controllers/bartender_controller.dart';
import '../services/fake_room_repository.dart';
import '../services/bartender_scene_bridge.dart';
import '../widgets/bartender_match_start_gate.dart';

import 'dart:convert';

void main() {
  testWidgets(
    'loading gate shows shared 3-2-1 then enables the full 60 seconds',
    (tester) async {
      var now = 1000000;
      final repo = FakeRoomRepository(nowMs: () => now);
      final ctrl = BartenderController(repository: repo, nowMs: () => now);
      await ctrl.createRoom(totalPlayers: 2);
      await tester.pump();
      await ctrl.startMatch(waitForScene: true);
      await tester.pump();
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListenableBuilder(
              listenable: ctrl,
              builder: (_, _) => BartenderMatchStartGate(
                controller: ctrl,
                fallbackReady: true,
                child: Center(
                  child: TextButton(
                    onPressed: () => taps++,
                    child: const Text('play'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('3'), findsOneWidget);
      expect(ctrl.remainingSeconds, 60);
      for (final count in [2, 1]) {
        now += 1000;
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('$count'), findsOneWidget);
        expect(ctrl.remainingSeconds, 60);
        expect(ctrl.isGameplayActive, isFalse);
      }
      now += 1000;
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const Key('match-countdown')), findsNothing);
      expect(ctrl.remainingSeconds, 60);
      await tester.tap(find.text('play'));
      expect(taps, 1);
      await tester.pumpWidget(const SizedBox());
      ctrl.dispose();
    },
  );

  test('preparation pauses time, serializes readiness, and schedules one shared countdown', () {
    const now = 100000;
    var timer = MatchTimer.prepare(nowMs: now);
    expect(timer.remainingMs(nowMs: now + 120000), 60000);
    expect(timer.isExpired(nowMs: now + 120000), isFalse);
    expect(timer.totalSurvivalSeconds(nowMs: now + 120000), 0);
    timer = timer.markSceneReady(
      playerId: 'one',
      connectedPlayerIds: {'one', 'two'},
      nowMs: now + 120000,
    );
    expect(timer.isPreparing, isTrue);
    expect(MatchTimer.fromJson(timer.toJson()), timer);
    final started = timer.markSceneReady(
      playerId: 'two',
      connectedPlayerIds: {'one', 'two'},
      nowMs: now + 130000,
    );
    expect(started.isPreparing, isFalse);
    expect(started.startedAt, now + 133000);
    expect(started.endTime, now + 193000);
    expect(started.startsInSeconds(nowMs: now + 130000), 3);
    expect(started.startsInSeconds(nowMs: now + 131000), 2);
    expect(started.startsInSeconds(nowMs: now + 132000), 1);
    expect(started.hasStarted(nowMs: now + 132999), isFalse);
    expect(started.hasStarted(nowMs: now + 133000), isTrue);
    expect(started.remainingMs(nowMs: now + 130000), 60000);
    expect(started.remainingMs(nowMs: now + 134000), 59000);
    expect(
      started.markSceneReady(
        playerId: 'two',
        connectedPlayerIds: {'one', 'two'},
        nowMs: now + 140000,
      ),
      same(started),
    );
  });

  test('slow peer cannot consume time; actions stay blocked through 3-2-1 and stale ready is ignored', () async {
    var now = 1000000;
    final repo = FakeRoomRepository(nowMs: () => now);
    final ctrl = BartenderController(repository: repo, nowMs: () => now);
    addTearDown(ctrl.dispose);
    await ctrl.createRoom(totalPlayers: 1);
    final code = ctrl.room!.code;
    await repo.joinRoom(code: code, playerName: 'Peer');
    await Future<void>.delayed(Duration.zero);
    await ctrl.startMatch(waitForScene: true);
    await Future<void>.delayed(Duration.zero);
    final prep = ctrl.room!.timer!.startedAt;
    expect(ctrl.isMatchPreparing, isTrue);
    final bridge = BartenderSceneBridge(ctrl);
    final item = ctrl.myItems.single;
    final action = jsonEncode({'action': 'trash', 'id': item.id, 'round': 1});
    await ctrl.reportSceneReady(preparationId: prep);
    now += 90000;
    await Future<void>.delayed(Duration.zero);
    expect(ctrl.remainingSeconds, 60);
    expect(ctrl.isGameplayActive, isFalse);
    expect(await bridge.handle(action), isFalse);
    await repo.markSceneReady(
      code: code,
      playerId: 'p_1',
      preparationId: prep - 1,
    );
    await Future<void>.delayed(Duration.zero);
    expect(ctrl.isMatchPreparing, isTrue);
    await repo.markSceneReady(code: code, playerId: 'p_1', preparationId: prep);
    await Future<void>.delayed(Duration.zero);
    expect(ctrl.startCountdownSeconds, 3);
    expect(ctrl.remainingSeconds, 60);
    expect(await bridge.handle(action), isFalse);
    final end = ctrl.room!.timer!.endTime;
    now += 3000;
    expect(ctrl.isGameplayActive, isTrue);
    expect(ctrl.remainingSeconds, 60);
    await repo.markSceneReady(code: code, playerId: 'p_1', preparationId: prep);
    await Future<void>.delayed(Duration.zero);
    expect(
      ctrl.room!.timer!.endTime,
      end,
      reason: 'duplicate ready cannot reset time',
    );
    expect(await bridge.handle(action), isTrue);
    now += 1000;
    expect(ctrl.remainingSeconds, 59);
  });
}
