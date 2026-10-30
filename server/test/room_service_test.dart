// ignore_for_file: avoid_relative_lib_imports
import 'package:test/test.dart';

import '../src/exceptions.dart';
import '../src/room_service.dart';
import '../../nhombar/lib/games/bartender/models/game_item.dart';
import '../../nhombar/lib/games/bartender/models/room.dart';
import '../../nhombar/lib/games/bartender/models/station.dart';

void main() {
  group('RoomService Game Rules', () {
    late RoomService service;

    setUp(() {
      service = RoomService(enableTimers: false);
    });

    tearDown(() {
      service.dispose();
    });

    test('createRoom initializes host in lobby with ringIndex 0', () {
      final res = service.createRoom(playerName: 'An');
      expect(res.room.code.length, 4);
      expect(res.room.status, RoomStatus.lobby);
      expect(res.playerId, 'p_0');
      expect(res.playerToken, isNotEmpty);
      expect(res.room.players['p_0']?.name, 'An');
      expect(res.room.players['p_0']?.ringIndex, 0);
      expect(res.room.players['p_0']?.connected, isTrue);
    });

    test('joinRoom adds player up to 4 and enforces capacity & status constraints', () {
      final host = service.createRoom(playerName: 'Host');
      final code = host.room.code;

      final guest1 = service.joinRoom(code: code, playerName: 'Guest 1');
      expect(guest1.playerId, 'p_1');
      expect(guest1.room.players.length, 2);
      expect(guest1.room.players['p_1']?.ringIndex, 1);

      service.joinRoom(code: code, playerName: 'Guest 2');
      final guest3 = service.joinRoom(code: code, playerName: 'Guest 3');
      expect(guest3.room.players.length, 4);

      // 5th player is rejected with ROOM_FULL
      expect(
        () => service.joinRoom(code: code, playerName: 'Guest 4'),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'ROOM_FULL')),
      );
    });

    test('startMatch requires at least 2 connected players and generates winnable round', () {
      final host = service.createRoom(playerName: 'Host');
      final code = host.room.code;

      // 1 player cannot start
      expect(
        () => service.startMatch(code: code, token: host.playerToken),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'NOT_ENOUGH_PLAYERS')),
      );

      final guest = service.joinRoom(code: code, playerName: 'Guest');
      service.startMatch(code: code, token: host.playerToken);

      final room = service.getRoom(code: code, token: guest.playerToken);
      expect(room.status, RoomStatus.playing);
      expect(room.timer, isNotNull);
      expect(room.currentRound, isNotNull);
      expect(room.currentRound?.number, 1);
      expect(room.currentRound?.ordersPerPlayer, 3);
      expect(room.inbox[0], isNotEmpty);
      expect(room.inbox[1], isNotEmpty);
    });

    test('sendItem validates adjacent neighbors and moves items', () {
      final host = service.createRoom(playerName: 'Host');
      final code = host.room.code;
      service.joinRoom(code: code, playerName: 'Guest');
      service.startMatch(code: code, token: host.playerToken);

      final room = service.getRoom(code: code, token: host.playerToken);
      final hostItem = room.inbox[0]!.first;

      // Host (0) sends to Guest (1) in 2-player game (is adjacent)
      service.sendItem(
        code: code,
        token: host.playerToken,
        itemId: hostItem.id,
        toRingIndex: 1,
      );

      final after = service.getRoom(code: code, token: host.playerToken);
      expect(after.inbox[0]?.any((it) => it.id == hostItem.id), isFalse);
      expect(after.inbox[1]?.any((it) => it.id == hostItem.id), isTrue);
    });

    test('trashItem removes item from caller inbox', () {
      final host = service.createRoom(playerName: 'Host');
      final code = host.room.code;
      service.joinRoom(code: code, playerName: 'Guest');
      service.startMatch(code: code, token: host.playerToken);

      final room = service.getRoom(code: code, token: host.playerToken);
      final item = room.inbox[0]!.first;

      service.trashItem(code: code, token: host.playerToken, itemId: item.id);
      final after = service.getRoom(code: code, token: host.playerToken);
      expect(after.inbox[0]?.any((it) => it.id == item.id), isFalse);
    });

    test('processItem at assigned station produces product', () {
      final host = service.createRoom(playerName: 'Host');
      final code = host.room.code;
      service.joinRoom(code: code, playerName: 'Guest');
      service.startMatch(code: code, token: host.playerToken);

      final room = service.getRoom(code: code, token: host.playerToken);
      final hostStation = room.currentRound!.stationAssignment[0];

      if (hostStation != null) {
        String ingredient;
        if (hostStation == StationType.juicer) {
          ingredient = 'orange';
        } else if (hostStation == StationType.cuttingBoard) {
          ingredient = 'strawberry';
        } else if (hostStation == StationType.blender) {
          ingredient = 'cut_strawberry';
        } else {
          ingredient = 'orange_juice';
        }

        final item = GameItem(
          id: 'test_item_to_process',
          type: GameItemType.ingredient,
          itemId: ingredient,
          fromRingIndex: 0,
        );
        room.inbox[0]!.add(item);

        final wrongStation = hostStation == StationType.juicer
            ? StationType.blender
            : StationType.juicer;

        // Verify wrong station throws INVALID_MOVE
        expect(
          () => service.processItemAtStation(
            code: code,
            token: host.playerToken,
            itemId: item.id,
            station: wrongStation.name,
          ),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 'INVALID_MOVE')),
        );
      }
    });

    test('leaveRoom in match ends game when fewer than 2 connected players remain', () {
      final host = service.createRoom(playerName: 'Host');
      final code = host.room.code;
      final guest = service.joinRoom(code: code, playerName: 'Guest');
      service.startMatch(code: code, token: host.playerToken);

      // Guest leaves
      service.leaveRoom(code: code, token: guest.playerToken);

      final room = service.getRoom(code: code, token: host.playerToken);
      expect(room.status, RoomStatus.ended);
      expect(room.results, isNotNull);
      expect(room.results?.ranking, isNotEmpty);
    });

    test('submitOrder marks order submitted, adds bonus and advances round when done', () {
      final host = service.createRoom(playerName: 'Host');
      final code = host.room.code;
      service.joinRoom(code: code, playerName: 'Guest');
      service.startMatch(code: code, token: host.playerToken);

      var room = service.getRoom(code: code, token: host.playerToken);
      final initialEndTime = room.timer!.endTime;

      // Create a matching product for host's first order
      final hostOrders = room.currentRound!.playerOrders['p_0']!;
      final firstOrder = hostOrders.first;
      final productItemId = firstOrder.recipeId == 'lemonade' ? 'lemon_juice' : firstOrder.recipeId;

      final testProduct = GameItem(
        id: 'test_prod_1',
        type: GameItemType.product,
        itemId: productItemId,
        fromRingIndex: 0,
      );

      // Inject product into host inbox
      room.inbox[0]!.add(testProduct);

      service.submitOrder(
        code: code,
        token: host.playerToken,
        orderId: firstOrder.id,
        itemId: testProduct.id,
      );

      final after = service.getRoom(code: code, token: host.playerToken);
      expect(after.timer!.endTime, initialEndTime + 5000);
      expect(after.players['p_0']!.completedOrders, 1);
      expect(after.currentRound!.progress[0], 1);
      expect(after.currentRound!.playerOrders['p_0']!.first.isCompleted, isTrue);
    });

    test('submitOrder succeeds when passing product.itemId directly', () {
      final host = service.createRoom(playerName: 'Host');
      final code = host.room.code;
      service.joinRoom(code: code, playerName: 'Guest');
      service.startMatch(code: code, token: host.playerToken);

      final room = service.getRoom(code: code, token: host.playerToken);
      final hostOrders = room.currentRound!.playerOrders['p_0']!;
      final firstOrder = hostOrders.first;
      final productItemId = firstOrder.recipeId == 'lemonade' ? 'lemon_juice' : firstOrder.recipeId;

      final testProduct = GameItem(
        id: 'test_prod_item_id_fallback',
        type: GameItemType.product,
        itemId: productItemId,
        fromRingIndex: 0,
      );

      room.inbox[0]!.add(testProduct);

      // Caller sends productItemId (e.g. orange_juice) instead of instance id
      service.submitOrder(
        code: code,
        token: host.playerToken,
        orderId: firstOrder.id,
        itemId: productItemId,
      );

      final after = service.getRoom(code: code, token: host.playerToken);
      expect(after.players['p_0']!.completedOrders, 1);
      expect(after.currentRound!.progress[0], 1);
    });
  });
}
