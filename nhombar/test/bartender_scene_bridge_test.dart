// Tests stay with this isolated feature; flutter_test is a dev dependency.
// ignore_for_file: depend_on_referenced_packages
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:nhom_bar/games/bartender/controllers/bartender_controller.dart';
import 'package:nhom_bar/games/bartender/models/game_item.dart';
import 'package:nhom_bar/games/bartender/models/match_timer.dart';
import 'package:nhom_bar/games/bartender/models/order.dart';
import 'package:nhom_bar/games/bartender/models/player.dart';
import 'package:nhom_bar/games/bartender/models/room.dart';
import 'package:nhom_bar/games/bartender/models/round.dart';
import 'package:nhom_bar/games/bartender/models/station.dart';
import 'package:nhom_bar/games/bartender/services/bartender_scene_bridge.dart';
import 'package:nhom_bar/games/bartender/services/fake_room_repository.dart';

void main() {
  late _RecordingRoomRepository repository;
  late BartenderController controller;
  late BartenderSceneBridge bridge;

  Future<void> settle() => Future<void>.delayed(Duration.zero);
  Future<void> fixture({StationType station = StationType.juicer}) async {
    repository.emitRoomForTest(
      Room(
        code: controller.room!.code,
        status: RoomStatus.playing,
        players: const {
          'p_0': Player(id: 'p_0', name: 'Bạn', ringIndex: 0),
          'p_1': Player(id: 'p_1', name: 'Đồng đội', ringIndex: 1),
        },
        timer: MatchTimer.start(nowMs: DateTime.now().millisecondsSinceEpoch),
        currentRound: Round(
          number: 2,
          ordersPerPlayer: 3,
          stationAssignment: {0: station, 1: StationType.blender},
          playerOrders: const {
            'p_0': [
              Order(id: 'order1', recipeId: 'lemonade'),
              Order(id: 'order2', recipeId: 'orange_juice'),
            ],
            'p_1': [Order(id: 'other', recipeId: 'orange_juice')],
          },
        ),
        inbox: const {
          0: [
            GameItem(
              id: 'fruit',
              type: GameItemType.ingredient,
              itemId: 'orange',
              fromRingIndex: 0,
            ),
            GameItem(
              id: 'drink',
              type: GameItemType.product,
              itemId: 'lemon_juice',
              fromRingIndex: 0,
            ),
          ],
        },
      ),
    );
    await settle();
  }

  String action(
    String name, {
    String id = 'fruit',
    int round = 2,
    String? order,
  }) => jsonEncode({'action': name, 'id': id, 'round': round, 'order': order});

  setUp(() async {
    repository = _RecordingRoomRepository();
    controller = BartenderController(repository: repository);
    bridge = BartenderSceneBridge(controller);
    await controller.createRoom(totalPlayers: 2);
    await settle();
    await fixture();
  });
  tearDown(() => controller.dispose());

  test('snapshot maps lemonade to its product and omits the live clock', () {
    expect((bridge.snapshot['orders'] as List).first, {
      'id': 'order1',
      'product': 'lemon_juice',
    });
    expect(bridge.snapshot.containsKey('timer'), isFalse);
    expect((bridge.snapshot['items'] as List).first, {
      'id': 'fruit',
      'kind': 'orange',
      'processable': true,
    });
  });

  test(
    'rejects malformed, stale-round, absent-item and unknown actions',
    () async {
      final before = bridge.encodedSnapshot;
      for (final raw in [
        'bad',
        '[]',
        '{}',
        action('trash', round: 1),
        action('trash', id: 'missing'),
        action('unknown'),
      ]) {
        expect(await bridge.handle(raw), isFalse);
      }
      expect(bridge.encodedSnapshot, before);
    },
  );

  test(
    '3D processing preserves instance ID and follows actual station rules',
    () async {
      expect(await bridge.handle(action('process')), isTrue);
      await settle();
      expect(controller.myItems.first.id, 'fruit');
      expect(controller.myItems.first.itemId, 'orange_juice');
      expect(await bridge.handle(action('process')), isFalse);
    },
  );

  test('shaker cannot be triggered by a normal renderer click', () async {
    await fixture(station: StationType.shaker);
    expect(await bridge.handle(action('process', id: 'drink')), isFalse);
    expect(
      await bridge.handle(action('process', id: 'drink'), allowShake: true),
      isTrue,
    );
    await settle();
    expect(controller.myItems.last.itemId, 'citrus_cocktail');
  });

  test(
    'submitting requires the matching owned product and a pending order',
    () async {
      expect(await bridge.handle(action('submit', order: 'order1')), isFalse);
      expect(
        await bridge.handle(action('submit', id: 'drink', order: 'order2')),
        isFalse,
      );
      final previous = controller.room!.timer!.endTime;
      expect(
        await bridge.handle(action('submit', id: 'drink', order: 'order1')),
        isTrue,
      );
      await settle();
      expect(
        repository.submittedProductId,
        'drink',
        reason: '3D submission must pass the instance ID to Zhoufen backend',
      );
      expect(controller.myItems.any((i) => i.id == 'drink'), isFalse);
      expect(controller.myOrders.first.isCompleted, isTrue);
      expect(controller.room!.timer!.endTime, previous + 5000);
      expect(
        await bridge.handle(action('submit', id: 'drink', order: 'order1')),
        isFalse,
      );
      expect(controller.me!.completedOrders, 1);
    },
  );

  test('passing and trash act on real inbox items', () async {
    expect(await bridge.handle(action('right')), isTrue);
    await settle();
    expect(controller.myItems.any((i) => i.id == 'fruit'), isFalse);
    expect(controller.room!.itemsAtRing(1).single.id, 'fruit');
    expect(await bridge.handle(action('trash', id: 'drink')), isTrue);
    await settle();
    expect(controller.myItems, isEmpty);
  });
}

class _RecordingRoomRepository extends FakeRoomRepository {
  String? submittedProductId;

  @override
  Future<void> submitOrder({
    required String code,
    required String playerId,
    required String orderId,
    required String productId,
  }) async {
    submittedProductId = productId;
    await super.submitOrder(
      code: code,
      playerId: playerId,
      orderId: orderId,
      productId: productId,
    );
  }
}
