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
import '../models/round_setup.dart';
import '../models/station.dart';
import '../models/processing_rules.dart';
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

  /// ID của người chơi trên máy này (Fake dùng 'p_0', 'p_1', ...).
  String _localPlayerId = 'p_0';
  bool _isHostOnThisDevice = false;

  RoomConnectionState _connectionState = RoomConnectionState.connected;
  StreamController<RoomConnectionState>? _connectionStateController;

  @override
  RoomConnectionState get connectionState => _connectionState;

  @override
  Stream<RoomConnectionState> watchConnectionState() {
    _connectionStateController ??=
        StreamController<RoomConnectionState>.broadcast();
    scheduleMicrotask(() {
      if (!_isDisposed &&
          _connectionStateController != null &&
          !_connectionStateController!.isClosed) {
        _connectionStateController!.add(_connectionState);
      }
    });
    return _connectionStateController!.stream;
  }

  set testConnectionState(RoomConnectionState state) {
    _connectionState = state;
    if (!_isDisposed &&
        _connectionStateController != null &&
        !_connectionStateController!.isClosed) {
      _connectionStateController!.add(state);
    }
  }

  @override
  String get localPlayerId => _localPlayerId;

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

  /// Helper dùng trong unit/widget test để phát ra trạng thái phòng giả lập.
  void emitRoomForTest(Room room) => _emit(room);

  @override
  Future<Room> createRoom({
    required String hostPlayerName,
    int totalPlayers = 3,
  }) async {
    final code = (_rng.nextInt(9000) + 1000).toString();
    final players = <String, Player>{};

    // Host luôn là ringIndex 0.
    const hostId = 'p_0';
    _isHostOnThisDevice = true;
    _localPlayerId = hostId;
    players[hostId] = Player(
      id: hostId,
      name: hostPlayerName.trim().isEmpty ? 'Bạn' : hostPlayerName,
      ringIndex: 0,
      connected: true,
      completedOrders: 0,
      readyInLobby: true,
    );

    // Tạo các bot cho các vị trí còn lại trong vòng tròn (ringIndex 1, 2, ...).
    // totalPlayers CHỈ dùng cho Fake (số bot) — không ghi lên Firebase (D13).
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
    // Kiểm tra phòng tồn tại (giống FirebaseRoomRepository)
    if (_currentRoom == null || _currentRoom!.code != code) {
      throw StateError('Phòng #$code không tồn tại.');
    }

    final current = _currentRoom!;
    if (current.status != RoomStatus.lobby) {
      throw StateError(
        'Phòng #$code đã bắt đầu hoặc kết thúc, không thể tham gia.',
      );
    }

    final newIndex = current.totalPlayerCount;
    final newId = 'p_$newIndex';
    if (!_isHostOnThisDevice) {
      _localPlayerId = newId;
    }
    final newPlayers = Map<String, Player>.from(current.players);
    newPlayers[newId] = Player(
      id: newId,
      name: playerName,
      ringIndex: newIndex,
      connected: true,
      readyInLobby: true,
    );

    final updated = current.copyWith(
      players: newPlayers,
      inbox: {...current.inbox, newIndex: <GameItem>[]},
    );

    _emit(updated);
    return updated;
  }

  @override
  Future<void> returnToLobby({
    required String code,
    required String playerId,
  }) async {
    if (_currentRoom == null || _currentRoom!.code != code) return;
    final current = _currentRoom!;
    final player = current.players[playerId];
    if (player == null) return;

    final updatedPlayers = Map<String, Player>.from(current.players);
    updatedPlayers[playerId] = player.copyWith(readyInLobby: true);
    final updatedRoom = current.copyWith(players: updatedPlayers);
    _emit(updatedRoom);
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

    if (current.status == RoomStatus.lobby) {
      // D14 (lobby): xoá hẳn người chơi khỏi phòng
      final updatedPlayers = Map<String, Player>.from(current.players)
        ..remove(playerId);
      final updatedInbox = Map<int, List<GameItem>>.from(current.inbox)
        ..remove(player.ringIndex);
      _emit(current.copyWith(players: updatedPlayers, inbox: updatedInbox));
    } else {
      // D14 (playing): chỉ set connected = false, giữ slot cho round này
      final updatedPlayers = Map<String, Player>.from(current.players);
      updatedPlayers[playerId] = player.copyWith(connected: false);
      var updatedRoom = current.copyWith(players: updatedPlayers);
      // D14: Nếu còn dưới 2 người connected: kết thúc trận
      if (updatedRoom.connectedPlayerCount < 2) {
        updatedRoom = _buildEndedRoom(updatedRoom);
      }
      _emit(updatedRoom);
    }
  }

  @override
  Future<void> startMatch({required String code}) async {
    if (_currentRoom == null || _currentRoom!.code != code) return;
    final current = _currentRoom!;
    if (!current.canStart) return;

    // Chỉ chủ phòng (ringIndex == 0) mới được bắt đầu trận đấu
    if (current.players.containsKey(_localPlayerId)) {
      if (current.players[_localPlayerId]!.ringIndex != 0) return;
    }

    // D13: ring size = số người connected khi start (không dùng totalPlayers cố định)
    final connectedPlayers =
        current.players.values.where((p) => p.connected).toList()
          ..sort((a, b) => a.ringIndex.compareTo(b.ringIndex));

    final playerIds = connectedPlayers.map((p) => p.id).toList();

    // D15: dùng RoundSetup.generate để đảm bảo round luôn làm được
    final setup = RoundSetup.generate(
      playerIds: playerIds,
      roundNumber: 1,
      rng: _rng,
    );

    // Compact ringIndex (D14): dồn về 0..k-1 giữ nguyên thứ tự
    final newPlayers = <String, Player>{};
    for (var i = 0; i < connectedPlayers.length; i++) {
      final p = connectedPlayers[i];
      newPlayers[p.id] = p.copyWith(
        ringIndex: i,
        completedOrders: 0,
        readyInLobby: false,
      );
    }

    // Gán 3 đơn hàng từ feasibleRecipes cho mỗi người chơi
    final playerOrders = <String, List<Order>>{};
    var orderCounter = 1;
    for (final playerId in playerIds) {
      final orders = <Order>[];
      for (var i = 0; i < BartenderConfig.ordersPerPlayer; i++) {
        final recipe =
            setup.feasibleRecipes[_rng.nextInt(setup.feasibleRecipes.length)];
        orders.add(
          Order(
            id: 'ord_${orderCounter++}',
            recipeId: recipe.id,
            status: OrderStatus.pending,
          ),
        );
      }
      playerOrders[playerId] = orders;
    }

    final initialRound = Round(
      number: 1,
      ordersPerPlayer: BartenderConfig.ordersPerPlayer,
      stationAssignment: setup.stationAssignment,
      playerOrders: playerOrders,
    );

    // Khởi tạo timer 60s — MatchTimer.start(nowMs:)
    final timer = MatchTimer.start(nowMs: _nowMs());

    // Cung cấp 1 nguyên liệu ban đầu cho mỗi người chơi
    final initialInbox = <int, List<GameItem>>{};
    var itemCounter = 1;
    for (var i = 0; i < playerIds.length; i++) {
      final items = <GameItem>[];
      final ingredient =
          Ingredient.values[_rng.nextInt(Ingredient.values.length)];
      items.add(
        GameItem(
          id: 'item_${itemCounter++}',
          type: GameItemType.ingredient,
          itemId: ingredient.name,
          fromRingIndex: i,
        ),
      );
      initialInbox[i] = items;
    }

    final playingRoom = current.copyWith(
      status: RoomStatus.playing,
      timer: timer,
      currentRound: initialRound,
      players: newPlayers,
      inbox: initialInbox,
      clearResults: true,
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
      if (room.timer != null && room.timer!.isExpired(nowMs: _nowMs())) {
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
        for (var ring = 0; ring < room.connectedPlayerCount; ring++) {
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
    var newPlayers = Map<String, Player>.from(room.players);

    // Duyệt qua các bot (ringIndex > 0, hoặc bất kỳ ai không phải localPlayerId)
    for (final player in room.players.values) {
      if (player.id == _localPlayerId) {
        continue; // Không can thiệp vào người thật
      }
      if (!player.connected) continue;

      final ring = player.ringIndex;
      final items = newInbox[ring] ?? [];

      final botStation = round.stationAssignment[ring];
      final botOrders = round.playerOrders[player.id] ?? [];
      final pendingOrders = botOrders.where((o) => !o.isCompleted).toList();

      // ─── Bot thử nộp đơn nếu có sản phẩm khớp với đơn pending ───
      if (pendingOrders.isNotEmpty) {
        for (final order in pendingOrders) {
          // Lấy productId của recipe
          final recipe = RecipePool.allRecipes.cast<dynamic>().firstWhere(
            (r) => r.id == order.recipeId,
            orElse: () => null,
          );
          if (recipe == null) continue;
          final targetProductId = recipe.productId as String;

          // Kiểm tra trong inbox có sản phẩm khớp không
          final productIndex = items.indexWhere(
            (i) =>
                i.type == GameItemType.product && i.itemId == targetProductId,
          );
          if (productIndex != -1) {
            // Bot nộp đơn này (với độ trễ giả lập hợp lý — thực ra submit ngay)
            items.removeAt(productIndex);
            newInbox[ring] = items;

            // Cập nhật order status
            final updatedOrders = List<Order>.from(botOrders);
            final orderIdx = updatedOrders.indexWhere((o) => o.id == order.id);
            if (orderIdx != -1) {
              updatedOrders[orderIdx] = updatedOrders[orderIdx].copyWith(
                status: OrderStatus.submitted,
              );
            }

            final newPlayerOrders = Map<String, List<Order>>.from(
              round.playerOrders,
            );
            newPlayerOrders[player.id] = updatedOrders;
            final newRound = round.copyWith(playerOrders: newPlayerOrders);

            // Cộng completedOrders và timer bonus
            newPlayers[player.id] = player.copyWith(
              completedOrders: player.completedOrders + 1,
            );
            final updatedTimer = room.timer?.withBonus();

            var updatedRoom = room.copyWith(
              inbox: newInbox,
              players: newPlayers,
              currentRound: newRound,
              timer: updatedTimer,
            );

            // Kiểm tra round complete (chỉ tính người connected)
            if (_isRoundCompleteForConnected(updatedRoom)) {
              updatedRoom = _advanceRound(updatedRoom);
            }

            _emit(updatedRoom);
            return;
          }
        }
      }

      // ─── Bot thử chế biến nếu có item phù hợp ───
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

      // ─── Hoặc bot chuyền bớt item cho đồng đội liền kề ───
      if (items.length >= 2) {
        final itemToPass = items.removeAt(0);
        // Ring.leftNeighbor / Ring.rightNeighbor — xem ring.dart
        final targetRing = _rng.nextBool()
            ? Ring.leftNeighbor(ring, room.connectedPlayerCount)
            : Ring.rightNeighbor(ring, room.connectedPlayerCount);

        final targetItems = newInbox[targetRing] ?? [];
        targetItems.add(
          GameItem(
            id: itemToPass.id,
            type: itemToPass.type,
            itemId: itemToPass.itemId,
            fromRingIndex: ring,
          ),
        );
        newInbox[targetRing] = targetItems;
        _emit(room.copyWith(inbox: newInbox));
        return;
      }
    }
  }

  /// Kiểm tra round đã xong chưa theo người connected (D14).
  bool _isRoundCompleteForConnected(Room room) {
    final round = room.currentRound;
    if (round == null) return false;
    final connected = room.players.values.where((p) => p.connected).toList();
    if (connected.isEmpty) return false;
    return connected.every((p) {
      final orders = round.playerOrders[p.id] ?? [];
      if (orders.isEmpty) return true;
      return orders.where((o) => o.isCompleted).length >= round.ordersPerPlayer;
    });
  }

  /// Chuyển sang round mới (tất cả người connected, compact ring).
  Room _advanceRound(Room room) {
    final round = room.currentRound;
    if (round == null) return room;

    // Chỉ giữ người còn connected
    final connectedPlayers =
        room.players.values.where((p) => p.connected).toList()
          ..sort((a, b) => a.ringIndex.compareTo(b.ringIndex));

    if (connectedPlayers.length < 2) {
      // Ít hơn 2 người → kết thúc trận
      return _buildEndedRoom(room);
    }

    final nextRoundNumber = round.number + 1;
    final playerIds = connectedPlayers.map((p) => p.id).toList();

    // D15: RoundSetup đảm bảo round luôn làm được
    final setup = RoundSetup.generate(
      playerIds: playerIds,
      roundNumber: nextRoundNumber,
      rng: _rng,
    );

    // Compact ringIndex
    final newPlayers = <String, Player>{};
    for (var i = 0; i < connectedPlayers.length; i++) {
      final p = connectedPlayers[i];
      newPlayers[p.id] = p.copyWith(ringIndex: i);
    }

    final nextPlayerOrders = <String, List<Order>>{};
    var count = 1;
    for (final pId in playerIds) {
      final pOrders = <Order>[];
      for (var i = 0; i < BartenderConfig.ordersPerPlayer; i++) {
        final r =
            setup.feasibleRecipes[_rng.nextInt(setup.feasibleRecipes.length)];
        pOrders.add(
          Order(
            id: 'ord_r${nextRoundNumber}_${count++}',
            recipeId: r.id,
            status: OrderStatus.pending,
          ),
        );
      }
      nextPlayerOrders[pId] = pOrders;
    }

    final newRound = Round(
      number: nextRoundNumber,
      ordersPerPlayer: BartenderConfig.ordersPerPlayer,
      stationAssignment: setup.stationAssignment,
      playerOrders: nextPlayerOrders,
    );

    // Sinh 1 nguyên liệu mới cho mỗi ring
    final newInbox = <int, List<GameItem>>{};
    for (var i = 0; i < playerIds.length; i++) {
      final ingredient =
          Ingredient.values[_rng.nextInt(Ingredient.values.length)];
      newInbox[i] = [
        GameItem(
          id: 'spawn_r${nextRoundNumber}_$i',
          type: GameItemType.ingredient,
          itemId: ingredient.name,
          fromRingIndex: i,
        ),
      ];
    }

    return room.copyWith(
      players: newPlayers,
      currentRound: newRound,
      inbox: newInbox,
    );
  }

  void _endMatch() {
    _stopTimers();
    final room = _currentRoom;
    if (room == null || room.status != RoomStatus.playing) return;

    final endedRoom = _buildEndedRoom(room);
    _emit(endedRoom);
  }

  Room _buildEndedRoom(Room room) {
    final now = _nowMs();
    final survivalSec =
        room.timer?.totalSurvivalSeconds(nowMs: now) ??
        BartenderConfig.initialTimerSeconds;

    final results = MatchResult.fromPlayers(
      players: room.players.values.toList(),
      survivalSeconds: survivalSec,
    );

    final updatedPlayers = <String, Player>{};
    for (final entry in room.players.entries) {
      updatedPlayers[entry.key] = entry.value.copyWith(readyInLobby: false);
    }

    return room.copyWith(
      status: RoomStatus.ended,
      players: updatedPlayers,
      results: results,
    );
  }

  @override
  Future<void> endMatch(String code) async {
    if (_currentRoom?.code == code) {
      _endMatch();
    }
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
    if (room == null ||
        room.code != code ||
        room.status != RoomStatus.playing) {
      return;
    }

    final newInbox = Map<int, List<GameItem>>.from(
      room.inbox.map((k, v) => MapEntry(k, List<GameItem>.from(v))),
    );

    final sourceItems = newInbox[fromRingIndex] ?? [];
    sourceItems.removeWhere((i) => i.id == item.id);
    newInbox[fromRingIndex] = sourceItems;

    final destItems = newInbox[toRingIndex] ?? [];
    destItems.add(
      GameItem(
        id: item.id,
        type: item.type,
        itemId: item.itemId,
        fromRingIndex: fromRingIndex,
      ),
    );
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
    if (room == null ||
        room.code != code ||
        room.status != RoomStatus.playing) {
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
    final processed = _deriveProcessedProduct(originalItem, station);
    if (processed != null) {
      items[itemIndex] = processed;
      newInbox[ringIndex] = items;
      _emit(room.copyWith(inbox: newInbox));
      return processed;
    }
    return originalItem;
  }

  /// Suy luận kết quả sau khi một vật phẩm được chế biến tại trạm.
  ///
  /// Dùng chung quy tắc chế biến [processItem] (D19).
  GameItem? _deriveProcessedProduct(GameItem item, StationType station) {
    final resultId = processItem(item.itemId, station);
    if (resultId == null) return null;

    return GameItem(
      id: item.id,
      type: GameItemType.product,
      itemId: resultId,
      fromRingIndex: item.fromRingIndex,
    );
  }

  @override
  Future<void> submitOrder({
    required String code,
    required String playerId,
    required String orderId,
    required String productId,
  }) async {
    final room = _currentRoom;
    if (room == null ||
        room.code != code ||
        room.status != RoomStatus.playing) {
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

    // Kiểm tra productId khớp với recipeId hoặc productId của recipe
    final order = orders[orderIndex];
    final recipe = RecipePool.allRecipes.cast<dynamic>().firstWhere(
      (r) => r.id == order.recipeId,
      orElse: () => null,
    );
    final expectedProductId = recipe?.productId as String? ?? order.recipeId;

    // Xoá sản phẩm hoàn thành khỏi inbox của người nộp
    final newInbox = Map<int, List<GameItem>>.from(
      room.inbox.map((k, v) => MapEntry(k, List<GameItem>.from(v))),
    );
    final playerItems = newInbox[player.ringIndex] ?? [];
    final itemIndex = playerItems.indexWhere(
      (i) =>
          i.id == productId ||
          i.itemId == productId ||
          i.itemId == expectedProductId,
    );

    if (itemIndex == -1) {
      // Cho phép nộp nếu productId khớp trực tiếp (hỗ trợ test không nhét item sẵn)
      if (productId != expectedProductId && productId != order.recipeId) {
        return;
      }
    } else {
      final matchedItem = playerItems[itemIndex];
      if (matchedItem.itemId != expectedProductId &&
          matchedItem.itemId != order.recipeId &&
          productId != expectedProductId &&
          productId != order.recipeId) {
        return;
      }
      playerItems.removeAt(itemIndex);
    }
    newInbox[player.ringIndex] = playerItems;

    // Cập nhật trạng thái đơn: submitted
    final updatedOrders = List<Order>.from(orders);
    updatedOrders[orderIndex] = updatedOrders[orderIndex].copyWith(
      status: OrderStatus.submitted,
    );

    final newPlayerOrders = Map<String, List<Order>>.from(round.playerOrders);
    newPlayerOrders[playerId] = updatedOrders;

    // Cộng +5s vào đồng hồ chung
    final updatedTimer = room.timer?.withBonus();

    // Cộng +1 completedOrders cho người chơi
    final updatedPlayers = Map<String, Player>.from(room.players);
    updatedPlayers[playerId] = player.copyWith(
      completedOrders: player.completedOrders + 1,
    );

    var updatedRound = round.copyWith(playerOrders: newPlayerOrders);

    var updatedRoom = room.copyWith(
      timer: updatedTimer,
      players: updatedPlayers,
      currentRound: updatedRound,
      inbox: newInbox,
    );

    // Kiểm tra: tất cả người CONNECTED đã xong hết đơn của round chưa? (D14)
    if (_isRoundCompleteForConnected(updatedRoom)) {
      // Kiểm tra còn đủ người để tiếp tục không
      final connectedCount = updatedRoom.players.values
          .where((p) => p.connected)
          .length;
      if (connectedCount < 2) {
        updatedRoom = _buildEndedRoom(updatedRoom);
      } else {
        updatedRoom = _advanceRound(updatedRoom);
      }
    }

    _emit(updatedRoom);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopTimers();
    _roomStreamController?.close();
    _roomStreamController = null;
    _connectionStateController?.close();
    _connectionStateController = null;
  }
}
