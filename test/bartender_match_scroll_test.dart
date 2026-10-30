import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/bartender/controllers/bartender_controller.dart';
import 'package:nhom_bar/games/bartender/screens/bartender_match_screen.dart';
import 'package:nhom_bar/games/bartender/services/fake_room_repository.dart';

void main() {
  testWidgets(
    'BartenderMatchScreen scrolls smoothly without overflow on small screens',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final repo = FakeRoomRepository(rng: Random(42));
      final created = await repo.createRoom(hostPlayerName: 'Host', totalPlayers: 2);

      final ctrl = BartenderController(repository: repo);
      await ctrl.joinRoom(code: created.code, playerName: 'Host');

      // Bắt đầu trận đấu để ctrl.room chuyển sang status playing và có currentRound
      await repo.startMatch(code: created.code);
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BartenderMatchScreen(controller: ctrl),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      final verticalScrollFinder = find.byWidgetPredicate(
        (w) => w is SingleChildScrollView && w.scrollDirection == Axis.vertical,
      );
      expect(verticalScrollFinder, findsOneWidget);

      // Cuộn xuống để xem các vật phẩm và thùng rác
      await tester.drag(verticalScrollFinder, const Offset(0, -300));
      await tester.pump();

      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
      ctrl.dispose();
      repo.dispose();
    },
  );
}
