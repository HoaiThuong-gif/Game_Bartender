import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/bartender/models/game_item.dart';
import 'package:nhom_bar/games/bartender/models/match_result.dart';
import 'package:nhom_bar/games/bartender/models/match_timer.dart';
import 'package:nhom_bar/games/bartender/models/order.dart';
import 'package:nhom_bar/games/bartender/models/player.dart';
import 'package:nhom_bar/games/bartender/models/room.dart';
import 'package:nhom_bar/games/bartender/models/round.dart';
import 'package:nhom_bar/games/bartender/models/station.dart';

void main() {
  group('Models purity check', () {
    test('all models in lib/games/bartender/models/ are pure Dart without Flutter imports', () {
      final modelsDir = Directory('lib/games/bartender/models');
      expect(modelsDir.existsSync(), isTrue, reason: 'Models directory must exist');

      final dartFiles = modelsDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();

      expect(dartFiles, isNotEmpty);

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        expect(
          content.contains("package:flutter"),
          isFalse,
          reason: '${file.path} must not import package:flutter',
        );
        expect(
          content.contains("dart:ui"),
          isFalse,
          reason: '${file.path} must not import dart:ui',
        );
      }
    });
  });

  group('GameItem JSON serialization', () {
    test('round-trip for ingredient and product', () {
      const item1 = GameItem(
        id: 'item_1',
        type: GameItemType.ingredient,
        itemId: 'orange',
        fromRingIndex: 1,
      );

      final json1 = item1.toJson();
      expect(json1, {
        'id': 'item_1',
        'type': 'ingredient',
        'itemId': 'orange',
        'fromRingIndex': 1,
      });

      final parsed1 = GameItem.fromJson(json1);
      expect(parsed1, equals(item1));

      const item2 = GameItem(
        id: 'item_2',
        type: GameItemType.product,
        itemId: 'orange_juice',
        fromRingIndex: 0,
      );
      final json2 = item2.toJson();
      expect(json2['type'], 'product');
      final parsed2 = GameItem.fromJson(json2);
      expect(parsed2, equals(item2));
    });
  });

  group('Order JSON serialization', () {
    test('round-trip for pending and submitted', () {
      const order1 = Order(
        id: 'order_1',
        recipeId: 'citrus_cocktail',
        status: OrderStatus.pending,
      );
      final json1 = order1.toJson();
      expect(json1, {
        'id': 'order_1',
        'recipeId': 'citrus_cocktail',
        'status': 'pending',
      });
      expect(Order.fromJson(json1), equals(order1));

      const order2 = Order(
        id: 'order_2',
        recipeId: 'citrus_cocktail',
        status: OrderStatus.submitted,
      );
      final json2 = order2.toJson();
      expect(json2['status'], 'submitted');
      expect(Order.fromJson(json2), equals(order2));
    });
  });

  group('Player JSON serialization', () {
    test('round-trip preserves all fields', () {
      const player = Player(
        id: 'p_host',
        name: 'Alex',
        ringIndex: 0,
        connected: true,
        completedOrders: 5,
        readyInLobby: true,
      );

      final json = player.toJson();
      expect(json, {
        'id': 'p_host',
        'name': 'Alex',
        'ringIndex': 0,
        'connected': true,
        'completedOrders': 5,
        'readyInLobby': true,
      });

      expect(Player.fromJson(json), equals(player));
    });
  });

  group('MatchTimer JSON serialization', () {
    test('round-trip preserves startedAt and endTime, computes offset', () {
      const timer = MatchTimer(
        startedAt: 1760000000000,
        endTime: 1760000060000,
        serverOffsetMs: 500,
      );

      final json = timer.toJson();
      expect(json, {
        'startedAt': 1760000000000,
        'endTime': 1760000060000,
      });

      final parsed = MatchTimer.fromJson(json, serverOffsetMs: 500);
      expect(parsed, equals(timer));
    });
  });

  group('MatchResult JSON serialization', () {
    test('round-trip matches API.md results ranking format with playerId', () {
      const p1 = Player(id: 'p_0', name: 'An', ringIndex: 0, completedOrders: 3);
      const p2 = Player(id: 'p_1', name: 'Binh', ringIndex: 1, completedOrders: 1);
      const result = MatchResult(
        totalSurvivalSeconds: 65,
        totalTeamOrders: 4,
        ranking: [p1, p2],
      );

      final json = result.toJson();
      expect(json, {
        'totalSurvivalSeconds': 65,
        'totalTeamOrders': 4,
        'ranking': [
          {'playerId': 'p_0', 'name': 'An', 'completedOrders': 3, 'ringIndex': 0},
          {'playerId': 'p_1', 'name': 'Binh', 'completedOrders': 1, 'ringIndex': 1},
        ],
      });

      final parsed = MatchResult.fromJson(json);
      expect(parsed, equals(result));
    });
  });

  group('Round JSON serialization', () {
    test('round-trip converts ringIndex keys to string and parses correctly', () {
      const round = Round(
        number: 2,
        ordersPerPlayer: 3,
        stationAssignment: {
          0: StationType.blender,
          1: StationType.juicer,
          2: null,
        },
        progress: {
          0: 2,
          1: 1,
          2: 0,
        },
        playerOrders: {
          'p_0': [
            Order(id: 'o_1', recipeId: 'orange_juice', status: OrderStatus.submitted),
            Order(id: 'o_2', recipeId: 'lemonade', status: OrderStatus.submitted),
          ],
          'p_1': [
            Order(id: 'o_3', recipeId: 'orange_juice', status: OrderStatus.pending),
          ],
        },
      );

      final json = round.toJson();
      expect(json['number'], 2);
      expect(json['ordersPerPlayer'], 3);
      expect(json['stationAssignment'], {
        '0': 'blender',
        '1': 'juicer',
        '2': null,
      });
      expect(json['progress'], {
        '0': 2,
        '1': 1,
        '2': 0,
      });
      expect(json['playerOrders']['p_0'].length, 2);

      final parsed = Round.fromJson(json);
      expect(parsed, equals(round));
    });
  });

  group('Room JSON serialization', () {
    test('round-trip for lobby room with null fields', () {
      const lobbyRoom = Room(
        code: '1234',
        status: RoomStatus.lobby,
        players: {
          'p_0': Player(id: 'p_0', name: 'Host', ringIndex: 0),
        },
      );

      final json = lobbyRoom.toJson(currentServerNowMs: 1760000000000);
      expect(json['code'], '1234');
      expect(json['status'], 'lobby');
      expect(json['serverNowMs'], 1760000000000);
      expect(json['timer'], isNull);
      expect(json['currentRound'], isNull);
      expect(json['results'], isNull);
      expect(json['inbox'], isEmpty);

      final parsed = Room.fromJson(json);
      expect(parsed.code, lobbyRoom.code);
      expect(parsed.status, lobbyRoom.status);
      expect(parsed.players.length, 1);
      expect(parsed.players['p_0']?.name, 'Host');
      expect(parsed.timer, isNull);
      expect(parsed.currentRound, isNull);
      expect(parsed.results, isNull);
    });

    test('round-trip matches API.md snapshot contract exactly', () {
      final contractJsonString = '''
      {
        "code": "4821",
        "status": "playing",
        "serverNowMs": 1760000000000,
        "players": {
          "p_0": { "id": "p_0", "name": "An", "ringIndex": 0, "connected": true, "completedOrders": 0, "readyInLobby": true }
        },
        "timer": { "startedAt": 1760000000000, "endTime": 1760000060000 },
        "currentRound": {
          "number": 1,
          "ordersPerPlayer": 3,
          "stationAssignment": { "0": "blender" },
          "progress": { "0": 0 },
          "playerOrders": {
            "p_0": [ { "id": "o_1", "recipeId": "orange_juice", "status": "pending" } ]
          }
        },
        "inbox": {
          "0": [ { "id": "i_1", "type": "ingredient", "itemId": "orange", "fromRingIndex": 0 } ]
        },
        "results": null
      }
      ''';

      final map = jsonDecode(contractJsonString) as Map<String, dynamic>;
      final room = Room.fromJson(map, localNowMs: 1760000000100);

      expect(room.code, '4821');
      expect(room.status, RoomStatus.playing);
      expect(room.serverNowMs, 1760000000000);
      expect(room.players['p_0']?.name, 'An');
      expect(room.timer?.serverOffsetMs, -100); // 1760000000000 - 1760000000100
      expect(room.currentRound?.number, 1);
      expect(room.currentRound?.stationAssignment[0], StationType.blender);
      expect(room.inbox[0]?.first.itemId, 'orange');

      final serialized = room.toJson();
      expect(serialized['code'], '4821');
      expect(serialized['status'], 'playing');
      expect(serialized['serverNowMs'], 1760000000000);
      expect(serialized['inbox']['0'].first['itemId'], 'orange');
      expect(serialized['currentRound']['stationAssignment']['0'], 'blender');
    });
  });
}
