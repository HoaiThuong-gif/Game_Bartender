import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/main.dart';
import 'package:nhom_bar/games/bartender/models/room.dart';
import 'package:nhom_bar/games/bartender/screens/bartender_screen.dart';
import 'package:nhom_bar/games/bartender/services/fake_room_repository.dart';
import 'package:nhom_bar/shared/widgets/cozy_loading.dart';

class PendingRoomRepository extends FakeRoomRepository {
  final request = Completer<void>();
  @override
  Future<Room> createRoom({
    required String hostPlayerName,
    int totalPlayers = 3,
  }) async {
    await request.future;
    return super.createRoom(
      hostPlayerName: hostPlayerName,
      totalPlayers: totalPlayers,
    );
  }
}

class PendingLeaveRepository extends FakeRoomRepository {
  final leaveRequest = Completer<void>();
  @override
  Future<void> leaveRoom({
    required String code,
    required String playerId,
  }) async {
    await leaveRequest.future;
    await super.leaveRoom(code: code, playerId: playerId);
  }
}

void main() {
  testWidgets('Back waits for the real leave operation and then returns', (
    tester,
  ) async {
    final repository = PendingLeaveRepository();
    await tester.pumpWidget(
      NhomBarApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => BartenderScreen(repository: repository),
                ),
              ),
              child: const Text('Mở game'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Mở game'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TẠO PHÒNG MỚI'));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(BartenderScreen));
    await Navigator.of(context).maybePop();
    await tester.pump();
    expect(find.byType(CozyLoading), findsOneWidget);
    expect(find.byType(BartenderScreen), findsOneWidget);
    repository.leaveRequest.complete();
    await tester.pumpAndSettle();
    expect(find.byType(CozyLoading), findsNothing);
    expect(find.byType(BartenderScreen), findsNothing);
    expect(find.text('Mở game'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  for (final fails in [false, true]) {
    testWidgets(
      'Cat loading follows the pending request and clears on ${fails ? 'failure' : 'success'}',
      (tester) async {
        final repository = PendingRoomRepository();
        await tester.pumpWidget(
          NhomBarApp(home: BartenderScreen(repository: repository)),
        );
        await tester.pumpAndSettle();
        expect(find.byType(CozyLoading), findsNothing);
        await tester.tap(find.text('TẠO PHÒNG MỚI'));
        await tester.pump();
        expect(find.byType(CozyLoading), findsOneWidget);
        await tester.pump(const Duration(seconds: 8));
        expect(find.byType(CozyLoading), findsOneWidget);
        if (fails) {
          repository.request.completeError(StateError('request failed'));
        } else {
          repository.request.complete();
        }
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.byType(CozyLoading), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
