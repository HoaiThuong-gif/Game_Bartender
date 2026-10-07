/// Widget tests cho vòng lặp gameplay Bartender (Phase 3).
///
/// Kiểm tra BartenderController + FakeRoomRepository hoạt động đúng:
/// - Tạo phòng, bắt đầu trận, nhận item, chuyền item, nộp đơn, kết thúc trận.
///
/// Không test UI chi tiết (đó là công việc của integration test).
/// Test ở mức controller + repository, tương tự rubik unit tests.
///
/// Chạy: flutter test test/bartender_controller_test.dart
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:nhom_bar/games/bartender/bartender_config.dart';
import 'package:nhom_bar/games/bartender/controllers/bartender_controller.dart';
import 'package:nhom_bar/games/bartender/models/game_item.dart';
import 'package:nhom_bar/games/bartender/models/room.dart';
import 'package:nhom_bar/games/bartender/services/fake_room_repository.dart';

void main() {
  group('FakeRoomRepository', () {
    test('createRoom produces room with correct player count', () async {
      final repo = FakeRoomRepository();
      final room = await repo.createRoom(
        hostPlayerName: 'Alice',
        totalPlayers: 3,
      );

      expect(room.totalPlayerCount, 3);
      expect(room.status, RoomStatus.lobby);
      expect(room.players.values.first.name, 'Alice');
      expect(room.players.values.first.ringIndex, 0);

      repo.dispose();
    });

    test('createRoom assigns sequential ringIndex values', () async {
      final repo = FakeRoomRepository();
      final room = await repo.createRoom(
        hostPlayerName: 'Host',
        totalPlayers: 4,
      );

      final ringIndices = room.players.values.map((p) => p.ringIndex).toList()
        ..sort();
      expect(ringIndices, [0, 1, 2, 3]);

      repo.dispose();
    });

    test('startMatch transitions room to playing status', () async {
      final repo = FakeRoomRepository();
      final roomCreated = await repo.createRoom(
        hostPlayerName: 'Host',
        totalPlayers: 2,
      );
      expect(roomCreated.status, RoomStatus.lobby);

      final completer = Completer<Room>();
      repo.watchRoom(roomCreated.code).listen((r) {
        if (r.status == RoomStatus.playing && !completer.isCompleted) {
          completer.complete(r);
        }
      });

      await repo.startMatch(code: roomCreated.code);
      final playing = await completer.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => throw Exception('Timeout: room did not start'),
      );

      expect(playing.status, RoomStatus.playing);
      expect(playing.timer, isNotNull);
      expect(playing.currentRound, isNotNull);
      expect(playing.currentRound!.number, 1);

      repo.dispose();
    });

    test('startMatch assigns stations to all players', () async {
      final repo = FakeRoomRepository(rng: Random(42));
      final created = await repo.createRoom(
        hostPlayerName: 'Host',
        totalPlayers: 3,
      );

      final completer = Completer<Room>();
      repo.watchRoom(created.code).listen((r) {
        if (r.status == RoomStatus.playing && !completer.isCompleted) {
          completer.complete(r);
        }
      });

      await repo.startMatch(code: created.code);
      final playing = await completer.future.timeout(
        const Duration(seconds: 2),
      );

      final assignment = playing.currentRound!.stationAssignment;
      // 3 người chơi → 3 entries trong map
      expect(assignment.length, 3);
      for (var i = 0; i < 3; i++) {
        expect(assignment.containsKey(i), isTrue);
      }

      repo.dispose();
    });

    test('startMatch gives initial items to players', () async {
      final repo = FakeRoomRepository(rng: Random(1));
      final created = await repo.createRoom(
        hostPlayerName: 'Host',
        totalPlayers: 2,
      );

      final completer = Completer<Room>();
      repo.watchRoom(created.code).listen((r) {
        if (r.status == RoomStatus.playing && !completer.isCompleted) {
          completer.complete(r);
        }
      });

      await repo.startMatch(code: created.code);
      final playing = await completer.future.timeout(
        const Duration(seconds: 2),
      );

      // Mỗi người chơi có ít nhất 1 item ban đầu
      expect(playing.inbox.length, 2);
      expect(playing.inbox[0]!.isNotEmpty, isTrue);
      expect(playing.inbox[1]!.isNotEmpty, isTrue);

      repo.dispose();
    });

    test('sendItem moves item from sender to receiver', () async {
      final repo = FakeRoomRepository(rng: Random(0));
      final created = await repo.createRoom(
        hostPlayerName: 'Host',
        totalPlayers: 2,
      );

      // Chờ đang chơi
      final playingCompleter = Completer<Room>();
      repo.watchRoom(created.code).listen((r) {
        if (r.status == RoomStatus.playing && !playingCompleter.isCompleted) {
          playingCompleter.complete(r);
        }
      });
      await repo.startMatch(code: created.code);
      final playing = await playingCompleter.future.timeout(
        const Duration(seconds: 2),
      );

      final item = playing.inbox[0]!.first;

      // Chờ room update sau sendItem
      final sentCompleter = Completer<Room>();
      repo.watchRoom(created.code).listen((r) {
        if (!sentCompleter.isCompleted) sentCompleter.complete(r);
      });

      await repo.sendItem(
        code: created.code,
        fromRingIndex: 0,
        toRingIndex: 1,
        item: item,
      );

      final updated = await sentCompleter.future.timeout(
        const Duration(seconds: 2),
      );

      // Item phải không còn ở ring 0, và phải có ở ring 1
      final ring0Items = updated.inbox[0] ?? [];
      final ring1Items = updated.inbox[1] ?? [];

      expect(ring0Items.any((i) => i.id == item.id), isFalse);
      expect(ring1Items.any((i) => i.id == item.id), isTrue);

      repo.dispose();
    });

    test('trashItem removes item from inbox', () async {
      final repo = FakeRoomRepository(rng: Random(0));
      final created = await repo.createRoom(
        hostPlayerName: 'Host',
        totalPlayers: 2,
      );

      final playingCompleter = Completer<Room>();
      repo.watchRoom(created.code).listen((r) {
        if (r.status == RoomStatus.playing && !playingCompleter.isCompleted) {
          playingCompleter.complete(r);
        }
      });
      await repo.startMatch(code: created.code);
      final playing = await playingCompleter.future.timeout(
        const Duration(seconds: 2),
      );

      final item = playing.inbox[0]!.first;

      final trashedCompleter = Completer<Room>();
      repo.watchRoom(created.code).listen((r) {
        if (!trashedCompleter.isCompleted) trashedCompleter.complete(r);
      });

      await repo.trashItem(code: created.code, ringIndex: 0, itemId: item.id);

      final updated = await trashedCompleter.future.timeout(
        const Duration(seconds: 2),
      );
      final ring0After = updated.inbox[0] ?? [];
      expect(ring0After.any((i) => i.id == item.id), isFalse);

      repo.dispose();
    });

    test(
      'submitOrder increments completedOrders and adds bonus time',
      () async {
        final repo = FakeRoomRepository(rng: Random(99));
        final created = await repo.createRoom(
          hostPlayerName: 'Host',
          totalPlayers: 2,
        );

        Room? playingRoom;
        final playingCompleter = Completer<Room>();
        repo.watchRoom(created.code).listen((r) {
          if (r.status == RoomStatus.playing && !playingCompleter.isCompleted) {
            playingRoom = r;
            playingCompleter.complete(r);
          }
        });
        await repo.startMatch(code: created.code);
        await playingCompleter.future.timeout(const Duration(seconds: 2));

        final round = playingRoom!.currentRound!;
        final hostId = playingRoom!.players.entries
            .firstWhere((e) => e.value.ringIndex == 0)
            .key;
        final order = round.playerOrders[hostId]!.first;

        // Thêm một product vào inbox để simulate đã chế biến xong
        final product = GameItem(
          id: 'fake_product',
          type: GameItemType.product,
          itemId: order.recipeId, // đơn giản dùng recipeId để match
          fromRingIndex: 0,
        );

        // Chèn product vào inbox giả bằng sendItem từ ring 0 → 0
        // (Thực tế sẽ dùng processItemAtStation, nhưng ở đây test submitOrder)

        final submitCompleter = Completer<Room>();
        repo.watchRoom(created.code).listen((r) {
          if (!submitCompleter.isCompleted &&
              r.players[hostId]!.completedOrders > 0) {
            submitCompleter.complete(r);
          }
        });

        await repo.submitOrder(
          code: created.code,
          playerId: hostId,
          orderId: order.id,
          productId: product.itemId,
        );

        final submitted = await submitCompleter.future.timeout(
          const Duration(seconds: 2),
        );

        expect(submitted.players[hostId]!.completedOrders, 1);
        // Timer phải được cộng thêm bonus
        final originalEnd = playingRoom!.timer!.endTime;
        expect(
          submitted.timer!.endTime,
          greaterThanOrEqualTo(
            originalEnd + BartenderConfig.orderCompletionBonusSeconds * 1000,
          ),
        );

        repo.dispose();
      },
    );
  });

  group('BartenderController', () {
    test('initial state is null room, not busy', () {
      final ctrl = BartenderController();
      expect(ctrl.room, isNull);
      expect(ctrl.isBusy, isFalse);
      // localPlayerId từ FakeRoomRepository luôn có giá trị mặc định 'p_0'
      // (khác với Firebase sẽ throw khi chưa auth)
      expect(ctrl.myPlayerId, isNotNull);
      ctrl.dispose();
    });

    test('createRoom sets room and myPlayerId', () async {
      final ctrl = BartenderController(
        repository: FakeRoomRepository(rng: Random(1)),
      );

      await ctrl.createRoom(playerName: 'Tester', totalPlayers: 2);

      expect(ctrl.room, isNotNull);
      // localPlayerId từ FakeRoomRepository là 'p_0' cho host
      expect(ctrl.myPlayerId, 'p_0');
      expect(ctrl.room!.status, RoomStatus.lobby);
      expect(ctrl.isInLobby, isTrue);

      ctrl.dispose();
    });

    test('myRingIndex is 0 for host', () async {
      final ctrl = BartenderController(
        repository: FakeRoomRepository(rng: Random(2)),
      );

      await ctrl.createRoom(playerName: 'Host', totalPlayers: 3);
      expect(ctrl.myRingIndex, 0);

      ctrl.dispose();
    });

    test('leftNeighbor and rightNeighbor are correct for 3 players', () async {
      final ctrl = BartenderController(
        repository: FakeRoomRepository(rng: Random(3)),
      );

      await ctrl.createRoom(playerName: 'Host', totalPlayers: 3);

      // Host at ring 0:
      // left = (0-1) mod 3 = 2
      // right = (0+1) mod 3 = 1
      expect(ctrl.leftNeighbor?.ringIndex, 2);
      expect(ctrl.rightNeighbor?.ringIndex, 1);

      ctrl.dispose();
    });

    test('startMatch transitions to playing and gives items', () async {
      final ctrl = BartenderController(
        repository: FakeRoomRepository(rng: Random(5)),
      );

      await ctrl.createRoom(playerName: 'Host', totalPlayers: 2);

      // Chờ trạng thái chuyển sang playing
      final completer = Completer<void>();
      ctrl.addListener(() {
        if (ctrl.isMatchPlaying && !completer.isCompleted) {
          completer.complete();
        }
      });

      await ctrl.startMatch();
      await completer.future.timeout(const Duration(seconds: 3));

      expect(ctrl.isMatchPlaying, isTrue);
      expect(ctrl.remainingSeconds, greaterThan(0));
      expect(ctrl.myItems.isNotEmpty, isTrue);

      ctrl.dispose();
    });

    test('remainingSeconds counts down correctly', () async {
      final ctrl = BartenderController(
        repository: FakeRoomRepository(rng: Random(7)),
      );

      await ctrl.createRoom(playerName: 'Host', totalPlayers: 2);

      final completer = Completer<void>();
      ctrl.addListener(() {
        if (ctrl.isMatchPlaying && !completer.isCompleted) {
          completer.complete();
        }
      });

      await ctrl.startMatch();
      await completer.future.timeout(const Duration(seconds: 3));

      expect(
        ctrl.remainingSeconds,
        lessThanOrEqualTo(BartenderConfig.initialTimerSeconds),
      );
      expect(ctrl.remainingSeconds, greaterThan(0));

      ctrl.dispose();
    });

    test('playAgain creates a new room', () async {
      final ctrl = BartenderController(
        repository: FakeRoomRepository(rng: Random(10)),
      );

      await ctrl.createRoom(playerName: 'Host', totalPlayers: 2);
      final firstCode = ctrl.room!.code;

      await ctrl.playAgain();

      // Phòng mới phải được tạo (code có thể khác)
      expect(ctrl.room, isNotNull);
      expect(ctrl.isInLobby, isTrue);

      ctrl.dispose();
    });

    test('leaveRoom clears room state', () async {
      final ctrl = BartenderController(
        repository: FakeRoomRepository(rng: Random(11)),
      );

      await ctrl.createRoom(playerName: 'Host', totalPlayers: 2);
      expect(ctrl.room, isNotNull);

      await ctrl.leaveRoom();
      expect(ctrl.room, isNull);
      // localPlayerId vẫn là 'p_0' vì đó là property của repo, không reset khi rời phòng
      expect(ctrl.myPlayerId, 'p_0');

      ctrl.dispose();
    });

    test('myOrders returns orders for current player', () async {
      final ctrl = BartenderController(
        repository: FakeRoomRepository(rng: Random(13)),
      );

      await ctrl.createRoom(playerName: 'Host', totalPlayers: 2);

      final completer = Completer<void>();
      ctrl.addListener(() {
        if (ctrl.isMatchPlaying && !completer.isCompleted) {
          completer.complete();
        }
      });

      await ctrl.startMatch();
      await completer.future.timeout(const Duration(seconds: 3));

      // Mỗi người chơi có BartenderConfig.ordersPerPlayer đơn
      expect(ctrl.myOrders.length, BartenderConfig.ordersPerPlayer);

      ctrl.dispose();
    });

    test('localPlayerId is set after createRoom', () async {
      final repo = FakeRoomRepository(rng: Random(20));
      final ctrl = BartenderController(repository: repo);

      // Trước createRoom, myPlayerId có thể là 'p_0' (default)
      // Sau createRoom, chắc chắn là 'p_0'
      await ctrl.createRoom(playerName: 'Test', totalPlayers: 2);
      expect(ctrl.myPlayerId, 'p_0');
      expect(repo.localPlayerId, 'p_0');

      ctrl.dispose();
    });

    test('endMatch via repository ends the match', () async {
      final repo = FakeRoomRepository(rng: Random(21));
      final created = await repo.createRoom(
        hostPlayerName: 'Host',
        totalPlayers: 2,
      );

      final playingCompleter = Completer<Room>();
      repo.watchRoom(created.code).listen((r) {
        if (r.status == RoomStatus.playing && !playingCompleter.isCompleted) {
          playingCompleter.complete(r);
        }
      });
      await repo.startMatch(code: created.code);
      await playingCompleter.future.timeout(const Duration(seconds: 2));

      // Gọi endMatch qua interface
      await repo.endMatch(created.code);

      // Đợi stream phát room ended
      final endedCompleter = Completer<Room>();
      repo.watchRoom(created.code).listen((r) {
        if (r.status == RoomStatus.ended && !endedCompleter.isCompleted) {
          endedCompleter.complete(r);
        }
      });

      final ended = await endedCompleter.future.timeout(
        const Duration(seconds: 2),
      );
      expect(ended.status, RoomStatus.ended);
      expect(ended.results, isNotNull);

      repo.dispose();
    });
  });
}
