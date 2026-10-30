import 'dart:math';

import 'package:nhom_bar/games/bartender/bartender_config.dart';
import 'package:flutter/material.dart';
import 'package:nhom_bar/games/bartender/controllers/bartender_controller.dart';
import 'package:nhom_bar/games/bartender/services/fake_room_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/main.dart';
import 'package:nhom_bar/games/bartender/screens/bartender_lobby_screen.dart';
import 'package:nhom_bar/games/bartender/screens/bartender_match_screen.dart';
import 'package:nhom_bar/games/bartender/screens/bartender_screen.dart';
import 'package:nhom_bar/screens/home/lobby_screen.dart';
import 'package:nhom_bar/screens/home/widgets/lobby_object.dart';

void main() {
  for (final size in [const Size(390, 844), const Size(360, 640)]) {
    testWidgets(
      'lobby opens Bartender, creates a room, plays and returns at $size',
      (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        addTearDown(() => tester.pumpWidget(const SizedBox()));
        final previous = BartenderConfig.backend;
        BartenderConfig.backend = BartenderBackend.fake;
        addTearDown(() => BartenderConfig.backend = previous);
        await tester.pumpWidget(const NhomBarApp(home: LobbyScreen()));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 400)),
        );
        await tester.pump();

        final bartender = find.byWidgetPredicate(
          (widget) => widget is LobbyObject && widget.label == 'Quầy Bartender',
        );
        // Exercise the real route callback; projected object hit areas need a GPU/device.
        tester.widget<LobbyObject>(bartender).onTap!();
        await tester.pumpAndSettle();
        expect(find.byType(BartenderScreen), findsOneWidget);
        expect(find.byType(BartenderLobbyScreen), findsOneWidget);
        expect(find.text('Bartender đang được phát triển.'), findsNothing);
        expect(tester.takeException(), isNull);

        await tester.enterText(find.byType(TextField), 'Người chơi');
        await tester.tap(find.text('TẠO PHÒNG MỚI'));
        await tester.pumpAndSettle();
        expect(find.text('MÃ PHÒNG'), findsOneWidget);
        expect(find.text('Người chơi'), findsOneWidget);

        // Offline players are explicit fixtures; API tests cover real multiplayer.
        final lobbyWidget = tester.widget<BartenderLobbyScreen>(
          find.byType(BartenderLobbyScreen),
        );
        expect(
          lobbyWidget.controller.room!.connectedPlayerCount,
          greaterThanOrEqualTo(2),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('SẴN SÀNG'), findsOneWidget);
        expect(
          find.text('Đã đủ người! Đang chờ chủ phòng bắt đầu...'),
          findsNothing,
        );

        await tester.tap(find.text('SẴN SÀNG'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(BartenderMatchScreen), findsOneWidget);
        expect(find.text('VÒNG'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Popping the game must dispose its repository, timers and controller.
        final context = tester.element(find.byType(BartenderScreen));
        await Navigator.of(context).maybePop();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(BartenderScreen), findsNothing);
        expect(find.byType(LobbyScreen), findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets('guest lobby shows waiting message instead of start button', (
    tester,
  ) async {
    final hostRepo = FakeRoomRepository(rng: Random(100));
    final hostRoom = await hostRepo.createRoom(
      hostPlayerName: 'Host',
      totalPlayers: 1,
    );

    final guestRepo = FakeRoomRepository(rng: Random(101));
    guestRepo.emitRoomForTest(hostRoom);

    final ctrl = BartenderController(repository: guestRepo);
    await ctrl.joinRoom(code: hostRoom.code, playerName: 'Guest');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BartenderLobbyScreen(controller: ctrl)),
      ),
    );
    await tester.pump();

    expect(find.text('CHỜ CHỦ PHÒNG'), findsOneWidget);
    expect(find.text('SẴN SÀNG'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));

    ctrl.dispose();
    hostRepo.dispose();
    guestRepo.dispose();
  });
}
