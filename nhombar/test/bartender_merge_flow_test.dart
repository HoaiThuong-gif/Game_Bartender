// Integration checks for the UI/logic merge; Flutter test is a dev dependency.
// ignore_for_file: depend_on_referenced_packages, invalid_use_of_visible_for_testing_member
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nhom_bar/main.dart';
import 'package:nhom_bar/games/bartender/screens/bartender_screen.dart';
import 'package:nhom_bar/games/bartender/bartender_config.dart';
import 'package:nhom_bar/games/bartender/models/room.dart';
import 'package:nhom_bar/games/bartender/screens/bartender_lobby_screen.dart';
import 'package:nhom_bar/games/bartender/screens/bartender_match_screen.dart';
import 'package:nhom_bar/games/bartender/screens/bartender_results_screen.dart';
import 'package:nhom_bar/games/bartender/services/fake_room_repository.dart';

void main() {
  for (final size in [const Size(900, 400), const Size(390, 844)]) {
    testWidgets(
      'merged entry returns to same lobby and host restarts at $size',
      (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final previous = BartenderConfig.backend;
        BartenderConfig.backend = BartenderBackend.fake;
        addTearDown(() => BartenderConfig.backend = previous);
        await tester.pumpWidget(const NhomBarApp(home: BartenderScreen()));
        await tester.pumpAndSettle();
        final controller = tester
            .widget<BartenderLobbyScreen>(find.byType(BartenderLobbyScreen))
            .controller;
        await tester.enterText(find.byType(TextField), 'Host');
        await tester.tap(find.text('TẠO PHÒNG MỚI'));
        await tester.pumpAndSettle();
        final code = controller.room!.code;
        expect(controller.myRingIndex, 0);
        expect(controller.room!.canStart, isTrue);
        await tester.tap(find.text('SẴN SÀNG'));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(BartenderMatchScreen), findsOneWidget);
        final repository = controller.repository as FakeRoomRepository;
        await repository.endMatch(code);
        await tester.pumpAndSettle();
        expect(find.byType(BartenderResultsScreen), findsOneWidget);
        await tester.tap(find.text('QUAY LẠI PHÒNG'));
        await tester.pumpAndSettle();
        expect(find.byType(BartenderLobbyScreen), findsOneWidget);
        expect(controller.room!.code, code);
        expect(controller.me!.readyInLobby, isTrue);
        expect(controller.room!.canStart, isFalse);
        await tester.tap(find.text('SẴN SÀNG'));
        await tester.pump();
        expect(
          controller.room!.status,
          RoomStatus.ended,
          reason: 'host must wait for peers',
        );
        // Simulate peers pressing Return to lobby on their own devices.
        for (final player in controller.room!.players.values.toList()) {
          if (player.id != controller.myPlayerId) {
            await repository.returnToLobby(code: code, playerId: player.id);
          }
        }
        await tester.pumpAndSettle();
        expect(controller.room!.canStart, isTrue);
        await tester.tap(find.text('SẴN SÀNG'));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(BartenderMatchScreen), findsOneWidget);
        expect(controller.room!.code, code);
        expect(controller.room!.currentRound!.number, 1);
        await repository.endMatch(code);
        await tester.pumpAndSettle();
        await tester.tap(find.text('THOÁT'));
        await tester.pumpAndSettle();
        expect(controller.room, isNull);
        expect(find.text('TẠO PHÒNG MỚI'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
      },
    );
  }
}
