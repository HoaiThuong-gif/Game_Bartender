import 'dart:async';
import 'dart:math';

import '../bartender_config.dart';
import '../models/game_item.dart';
import '../models/ingredient.dart';
import '../models/match_result.dart';
import '../models/match_timer.dart';
import '../models/order.dart';
import '../models/player.dart';
import '../models/recipe_pool.dart';
import '../models/ring.dart';
import '../models/room.dart';
import '../models/round.dart';
import '../models/station.dart';
import '../models/station_assigner.dart';
import 'room_repository.dart';

/// Bản triển khai trong bộ nhớ (in-memory) của [RoomRepository].
///
/// Dùng cho giai đoạn phát triển local (bước 1-3 trong DEVELOPMENT.md)
/// và chạy thử toàn bộ vòng lặp trận đấu trên một máy duy nhất.
///
/// Tự động mô phỏng các người chơi bot để tạo trải nghiệm cộng tác
/// trọn vẹn: chuyền vật phẩm, chế biến tại trạm, nộp đơn, qua round.
class FakeRoomRepository implements RoomRepository {
  FakeRoomRepository({Random? rng}) : _rng = rng ?? Random();

  final Random _rng;

  Room? _currentRoom;
  StreamController<Room>? _roomStreamController;

  Timer? _gameLoopTimer;
  Timer? _spawnTimer;
  Timer? _botActionTimer;

  bool _isDisposed = false;

  /// Helper: thời điểm hiện tại (ms since epoch).
  int _nowMs() => DateTime.now().millisecondsSinceEpoch;

  StreamController<Room> _getOrCreateController() {
    if (_roomStreamController == null || _roomStreamController!.isClosed) {
      _roomStreamController = StreamController<Room>.broadcast();
    }
    return _roomStreamController!;
  }

  void _emit(Room room) {
    _currentRoom = room;
    if (!_isDisposed &&
        _roomStreamController != null &&
        !_roomStreamController!.isClosed) {
      _roomStreamController!.add(room);
    }
  }

  @override
  Future<Room> createRoom({
    required String hostPlayerName,
    int totalPlayers = 3,
  }) async {
    final code = (_rng.nextInt(9000) + 1000).toString();
    final players = <String, Player>{};

    // Host luôn là ringIndex 0.
    final hostId = 'p_0';
    players[hostId] = Player(
      id: hostId,
      name: hostPlayerName.trim().isEmpty ? 'Bạn' : hostPlayerName,
      ringIndex: 0,
      connected: true,
      completedOrders: 0,
    );

    // Tạo các bot cho các vị trí còn lại trong vòng tròn (ringIndex 1, 2, ...).
    final botNames = ['Bot Minh', 'Bot An', 'Bot Chi', 'Bot Dũng', 'Bot Hoa'];
    for (var i = 1; i < totalPlayers; i++) {
      final botId = 'p_$i';
      final name = botNames[(i - 1) % botNames.length];
      players[botId] = Player(
        id: botId,
        name: name,
        ringIndex: i,
        connected: true,
        completedOrders: 0,
      );
    }

    final room = Room(
      code: code,
      status: RoomStatus.lobby,
      players: players,
      inbox: {for (var i = 0; i < totalPlayers; i++) i: <GameItem>[]},
    );

    _emit(room);
    return room;
  }

  @override
  Future<Room> joinRoom({
    required String code,
    required String playerName,
  }) async {
    // Với FakeRepository, nếu chưa có phòng thì tạo mới với mã đó.
    if (_currentRoom == null || _currentRoom!.code != code) {
      final newRoom = await createRoom(hostPlayerName: playerName);
      return newRoom;
    }

    final current = _currentRoom!;
    if (current.status != RoomStatus.lobby) {
      throw StateError('Phòng đã bắt đầu hoặc kết thúc');
    }

    final newIndex = current.totalPlayerCount;
    final newId = 'p_$newIndex';
    final newPlayers = Map<String, Player>.from(current.players);
    newPlayers[newId] = Player(
      id: newId,
      name: playerName,
      ringIndex: newIndex,
      connected: true,
    );

    final updated = current.copyWith(
      players: newPlayers,
      inbox: {
        ...current.inbox,
        newIndex: <GameItem>[],
      },
    );

    _emit(updated);
    return updated;
  }

  @override
  Future<void> leaveRoom({
    required String code,
    required String playerId,
  }) async {
    if (_currentRoom == null || _currentRoom!.code != code) return;

    final current = _currentRoom!;
    final player = current.players[playerId];
    if (player == null) return;

    // Giữ slot, chỉ set connected = false theo API.md
    final updatedPlayers = Map<String, Player>.from(current.players);
    updatedPlayers[playerId] = player.copyWith(connected: false);

    final updated = current.copyWith(players: updatedPlayers);
    _emit(updated);
  }

  @override
  Future<void> startMatch({required String code}) async {
    if (_currentRoom == null || _currentRoom!.code != code) return;
    final current = _currentRoom!;
    if (!current.canStart) return;

    final playerCount = current.totalPlayerCount;

    // Khởi tạo Round 1
    // StationAssigner.assign(playerCount:, random:) — xem station_assigner.dart
    final stationAssignment = StationAssigner.assign(
      playerCount: playerCount,
      random: _rng,
    );

    // Gán 3 đơn hàng từ RecipePool cho mỗi người chơi
    final recipes = RecipePool.recipesForRound(1);
    final playerOrders = <String, List<Order>>{};

    var orderCounter = 1;
    for (final playerId in current.players.keys) {
      final orders = <Order>[];
      for (var i = 0; i < BartenderConfig.ordersPerPlayer; i++) {
        final recipe = recipes[_rng.nextInt(recipes.length)];
        orders.add(Order(
          id: 'ord_${orderCounter++}',
          recipeId: recipe.id,
          status: OrderStatus.pending,
        ));
      }
      playerOrders[playerId] = orders;
    }

    final initialRound = Round(
      number: 1,
      ordersPerPlayer: BartenderConfig.ordersPerPlayer,
      stationAssignment: stationAssignment,
      playerOrders: playerOrders,
    );

    // Khởi tạo timer 60s — MatchTimer.start(nowMs:)
    final timer = MatchTimer.start(nowMs: _nowMs());

    // Cung cấp 1 nguyên liệu ban đầu cho mỗi người chơi
    final initialInbox = <int, List<GameItem>>{};
    var itemCounter = 1;
    for (var i = 0; i < playerCount; i++) {
      final items = <GameItem>[];
      final ingredient = Ingredient.values[_rng.nextInt(Ingredient.values.length)];
      items.add(GameItem(
        id: 'item_${itemCounter++}',
        type: GameItemType.ingredient,
        itemId: ingredient.name,
        fromRingIndex: i,
      ));
      initialInbox[i] = items;
    }

    final playingRoom = current.copyWith(
      status: RoomStatus.playing,
      timer: timer,
      currentRound: initialRound,
      inbox: initialInbox,
    );

    _emit(playingRoom);

    // Bắt đầu các vòng lặp định kỳ (spawn, bot loop, timer check)
    _startTimers();
  }

  void _startTimers() {
    _stopTimers();

    // 1. Kiểm tra timer kết thúc trận đấu mỗi 500ms
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      final room = _currentRoom;
      if (room == null || room.status != RoomStatus.playing) return;

      // MatchTimer.isExpired(nowMs:) — cần truyền thời gian hiện tại
      if (room.timer != null &&
          room.timer!.isExpired(nowMs: _nowMs())) {
        _endMatch();
      }
    });

    // 2. Xuất hiện nguyên liệu định kỳ (khoảng 3s)
    _spawnTimer = Timer.periodic(
      const Duration(seconds: BartenderConfig.ingredientSpawnIntervalSeconds),
      (_) {
        final room = _currentRoom;
        if (room == null || room.status != RoomStatus.playing) return;

        // Sinh nguyên liệu cho người chơi nếu inbox chưa đầy (< 5 món)
        final newInbox = Map<int, List<GameItem>>.from(
          room.inbox.map((k, v) => MapEntry(k, List<GameItem>.from(v))),
        );

        var changed = false;
        for (var ring = 0; ring < room.totalPlayerCount; ring++) {
          final items = newInbox[ring] ?? [];
          if (items.length < 5) {
            final ingredient =
                Ingredient.values[_rng.nextInt(Ingredient.values.length)];
            final newItem = GameItem(
              id: 'spawn_${DateTime.now().microsecondsSinceEpoch}_$ring',
              type: GameItemType.ingredient,
              itemId: ingredient.name,
              fromRingIndex: ring,
            );
            items.add(newItem);
            newInbox[ring] = items;
            changed = true;
          }
        }

        if (changed) {
          _emit(room.copyWith(inbox: newInbox));
        }
      },
    );

    // 3. Vòng lặp hành vi của bot giả lập (mỗi 4s)
    _botActionTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _simulateBotActions();
    });
  }

  void _simulateBotActions() {
    final room = _currentRoom;
    if (room == null || room.status != RoomStatus.playing) return;

    final round = room.currentRound;
    if (round == null) return;

    final newInbox = Map<int, List<GameItem>>.from(
      room.inbox.map((k, v) => MapEntry(k, List<GameItem>.from(v))),
    );

    // Duyệt qua các bot (ringIndex > 0)
    for (final player in room.players.values) {
      if (player.ringIndex == 0) continue; // Không can thiệp vào host (người thật)

      final ring = player.ringIndex;
      final items = newInbox[ring] ?? [];
      if (items.isEmpty) continue;

      final botStation = round.stationAssignment[ring];

      // Bot thử chế biến nếu có item phù hợp
      if (botStation != null) {
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          final processed = _deriveProcessedProduct(item, botStation);
          if (processed != null) {
            items[i] = processed;
            newInbox[ring] = items;
            _emit(room.copyWith(inbox: newInbox));
            return;
          }
        }
      }

      // Hoặc bot chuyền bớt item cho đồng đội liền kề
      if (items.length >= 2) {
        final itemToPass = items.removeAt(0);
        // Ring.leftNeighbor / Ring.rightNeighbor — xem ring.dart
        final targetRing = _rng.nextBool()
            ? Ring.leftNeighbor(ring, room.totalPlayerCount)
            : Ring.rightNeighbor(ring, room.totalPlayerCount);

        final targetItems = newInbox[targetRing] ?? [];
        targetItems.add(GameItem(
          id: itemToPass.id,
          type: itemToPass.type,
          itemId: itemToPass.itemId,
          fromRingIndex: ring,
        ));
        newInbox[targetRing] = targetItems;
        _emit(room.copyWith(inbox: newInbox));
        return;
      }
    }
  }

  void _endMatch() {
    _stopTimers();
    final room = _currentRoom;
    if (room == null) return;

    final now = _nowMs();
    // MatchTimer.totalSurvivalSeconds(nowMs:) — cần tham số
    final survivalSec = room.timer?.totalSurvivalSeconds(nowMs: now) ??
        BartenderConfig.initialTimerSeconds;

    final results = MatchResult.fromPlayers(
      players: room.players.values.toList(),
      survivalSeconds: survivalSec,
    );

    final endedRoom = room.copyWith(
      status: RoomStatus.ended,
      results: results,
    );

    _emit(endedRoom);
  }

  void _stopTimers() {
    _gameLoopTimer?.cancel();
    _gameLoopTimer = null;
    _spawnTimer?.cancel();
    _spawnTimer = null;
    _botActionTimer?.cancel();
    _botActionTimer = null;
  }

  @override
  Stream<Room> watchRoom(String code) {
    final controller = _getOrCreateController();
    // Phát ngay trạng thái hiện tại nếu có
    if (_currentRoom != null && _currentRoom!.code == code) {
      Timer.run(() {
        if (!_isDisposed && !controller.isClosed) {
          controller.add(_currentRoom!);
        }
      });
    }
    return controller.stream;
  }

  @override
  Future<void> sendItem({
    required String code,
    required int fromRingIndex,
    required int toRingIndex,
    required GameItem item,
  }) async {
    final room = _currentRoom;
    if (room == null || room.code != code || room.status != RoomStatus.playing) {
      return;
    }

    final newInbox = Map<int, List<GameItem>>.from(
      room.inbox.map((k, v) => MapEntry(k, List<GameItem>.from(v))),
    );

    final sourceItems = newInbox[fromRingIndex] ?? [];
    sourceItems.removeWhere((i) => i.id == item.id);
    newInbox[fromRingIndex] = sourceItems;

    final destItems = newInbox[toRingIndex] ?? [];
    destItems.add(GameItem(
      id: item.id,
      type: item.type,
      itemId: item.itemId,
      fromRingIndex: fromRingIndex,
    ));
    newInbox[toRingIndex] = destItems;

    _emit(room.copyWith(inbox: newInbox));
  }

  @override
  Future<void> trashItem({
    required String code,
    required int ringIndex,
    required String itemId,
  }) async {
    final room = _currentRoom;
    if (room == null || room.code != code || room.status != RoomStatus.playing) {
      return;
    }

    final newInbox = Map<int, List<GameItem>>.from(
      room.inbox.map((k, v) => MapEntry(k, List<GameItem>.from(v))),
    );

    final items = newInbox[ringIndex] ?? [];
    items.removeWhere((i) => i.id == itemId);
    newInbox[ringIndex] = items;

    _emit(room.copyWith(inbox: newInbox));
  }

  @override
  Future<GameItem> processItemAtStation({
    required String code,
    required int ringIndex,
    required String itemId,
    required StationType station,
  }) async {
    final room = _currentRoom;
    if (room == null ||
        room.code != code ||
        room.status != RoomStatus.playing) {
      throw StateError('Phòng không hoạt động');
    }

    final newInbox = Map<int, List<GameItem>>.from(
      room.inbox.map((k, v) => MapEntry(k, List<GameItem>.from(v))),
    );

    final items = newInbox[ringIndex] ?? [];
    final itemIndex = items.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) {
      throw ArgumentError('Không tìm thấy vật phẩm $itemId');
    }

    final originalItem = items[itemIndex];
    final processed = _deriveProcessedProduct(originalItem, station) ??
        GameItem(
          id: originalItem.id,
          type: GameItemType.product,
          itemId: '${originalItem.itemId}_processed',
          fromRingIndex: ringIndex,
        );

    items[itemIndex] = processed;
    newInbox[ringIndex] = items;

    _emit(room.copyWith(inbox: newInbox));
    return processed;
  }

  /// Suy luận kết quả sau khi một vật phẩm được chế biến tại trạm.
  GameItem? _deriveProcessedProduct(GameItem item, StationType station) {
    final id = item.itemId;

    if (station == StationType.juicer) {
      if (id == Ingredient.orange.name) {
        return GameItem(
          id: item.id,
          type: GameItemType.product,
          itemId: 'orange_juice',
          fromRingIndex: item.fromRingIndex,
        );
      }
      if (id == Ingredient.lemon.name) {
        return GameItem(
          id: item.id,
          type: GameItemType.product,
          itemId: 'lemonade',
          fromRingIndex: item.fromRingIndex,
        );
      }
    } else if (station == StationType.cuttingBoard) {
      if (id == Ingredient.strawberry.name) {
        return GameItem(
          id: item.id,
          type: GameItemType.product,
          itemId: 'cut_strawberry',
          fromRingIndex: item.fromRingIndex,
        );
      }
    } else if (station == StationType.blender) {
      if (id == 'cut_strawberry' || id == Ingredient.strawberry.name) {
        return GameItem(
          id: item.id,
          type: GameItemType.product,
          itemId: 'strawberry_smoothie',
          fromRingIndex: item.fromRingIndex,
        );
      }
    } else if (station == StationType.shaker) {
      if (id == 'orange_juice' ||
          id == 'lemonade' ||
          id == Ingredient.ice.name) {
        return GameItem(
          id: item.id,
          type: GameItemType.product,
          itemId: 'citrus_cocktail',
          fromRingIndex: item.fromRingIndex,
        );
      }
    }

    return null;
  }

  @override
  Future<void> submitOrder({
    required String code,
    required String playerId,
    required String orderId,
    required String productId,
  }) async {
    final room = _currentRoom;
    if (room == null || room.code != code || room.status != RoomStatus.playing) {
      return;
    }

    final round = room.currentRound;
    if (round == null) return;

    final player = room.players[playerId];
    if (player == null) return;

    final orders = round.playerOrders[playerId];
    if (orders == null) return;

    final orderIndex = orders.indexWhere((o) => o.id == orderId);
    if (orderIndex == -1 || orders[orderIndex].isCompleted) return;

    // Xoá sản phẩm hoàn thành khỏi inbox của người nộp
    final newInbox = Map<int, List<GameItem>>.from(
      room.inbox.map((k, v) => MapEntry(k, List<GameItem>.from(v))),
    );
    final playerItems = newInbox[player.ringIndex] ?? [];
    playerItems.removeWhere(
      (i) => i.id == productId || i.itemId == productId,
    );
    newInbox[player.ringIndex] = playerItems;

    // Cập nhật trạng thái đơn: submitted
    final updatedOrders = List<Order>.from(orders);
    updatedOrders[orderIndex] = updatedOrders[orderIndex].copyWith(
      status: OrderStatus.submitted,
    );

    final newPlayerOrders = Map<String, List<Order>>.from(round.playerOrders);
    newPlayerOrders[playerId] = updatedOrders;

    // Cộng +5s vào đồng hồ chung
    // MatchTimer.withBonus() — không nhận tham số, luôn +5s
    final updatedTimer = room.timer?.withBonus();

    // Cộng +1 completedOrders cho người chơi
    final updatedPlayers = Map<String, Player>.from(room.players);
    updatedPlayers[playerId] = player.copyWith(
      completedOrders: player.completedOrders + 1,
    );

    var updatedRound = round.copyWith(playerOrders: newPlayerOrders);

    // Kiểm tra: tất cả người chơi đã xong hết đơn của round chưa?
    if (updatedRound.isComplete) {
      final nextRoundNumber = round.number + 1;
      final newStations = StationAssigner.assign(
        playerCount: room.totalPlayerCount,
        random: _rng,
      );

      final nextRecipes = RecipePool.recipesForRound(nextRoundNumber);
      final nextPlayerOrders = <String, List<Order>>{};

      var count = 1;
      for (final pId in room.players.keys) {
        final pOrders = <Order>[];
        for (var i = 0; i < BartenderConfig.ordersPerPlayer; i++) {
          final r = nextRecipes[_rng.nextInt(nextRecipes.length)];
          pOrders.add(Order(
            id: 'ord_r${nextRoundNumber}_${count++}',
            recipeId: r.id,
            status: OrderStatus.pending,
          ));
        }
        nextPlayerOrders[pId] = pOrders;
      }

      updatedRound = Round(
        number: nextRoundNumber,
        ordersPerPlayer: BartenderConfig.ordersPerPlayer,
        stationAssignment: newStations,
        playerOrders: nextPlayerOrders,
      );
    }

    final updatedRoom = room.copyWith(
      timer: updatedTimer,
      players: updatedPlayers,
      currentRound: updatedRound,
      inbox: newInbox,
    );

    _emit(updatedRoom);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopTimers();
    _roomStreamController?.close();
    _roomStreamController = null;
  }
}
