import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/bartender/controllers/bartender_controller.dart';
import 'package:nhom_bar/games/bartender/screens/bartender_match_screen.dart';
import 'package:nhom_bar/games/bartender/services/fake_room_repository.dart';

void main() {
  testWidgets(
    'BartenderMatchScreen displays reconnecting banner when connectionState is reconnecting',
    (tester) async {
      final repo = FakeRoomRepository(rng: Random(42));
      final created = await repo.createRoom(hostPlayerName: 'Host', totalPlayers: 2);

      final ctrl = BartenderController(repository: repo);
      await ctrl.joinRoom(code: created.code, playerName: 'Host');
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

      // Lúc bình thường (connected), không có banner
      expect(find.text('Đang nối lại...'), findsNothing);
      expect(find.text('Mất kết nối máy chủ'), findsNothing);

      // Chuyển sang reconnecting
      repo.testConnectionState = RoomConnectionState.reconnecting;
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Đang nối lại...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // Chuyển sang lost
      repo.testConnectionState = RoomConnectionState.lost;
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Đang nối lại...'), findsNothing);
      expect(find.text('Mất kết nối máy chủ'), findsOneWidget);

      // Chuyển lại về connected
      repo.testConnectionState = RoomConnectionState.connected;
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Đang nối lại...'), findsNothing);
      expect(find.text('Mất kết nối máy chủ'), findsNothing);

      await tester.pumpWidget(const SizedBox());
      ctrl.dispose();
      repo.dispose();
    },
  );
}
