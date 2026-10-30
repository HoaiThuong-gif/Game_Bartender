// ignore_for_file: avoid_relative_lib_imports
import 'dart:async';
import 'dart:convert';
import 'dart:math';

// Reusing existing models without moving them
import '../../../nhombar/lib/games/bartender/models/game_item.dart';
import '../../../nhombar/lib/games/bartender/models/ingredient.dart';
import '../../../nhombar/lib/games/bartender/models/match_result.dart';
import '../../../nhombar/lib/games/bartender/models/match_timer.dart';
import '../../../nhombar/lib/games/bartender/models/order.dart';
import '../../../nhombar/lib/games/bartender/models/player.dart';
import '../../../nhombar/lib/games/bartender/models/processing_rules.dart';
import '../../../nhombar/lib/games/bartender/models/recipe_pool.dart';
import '../../../nhombar/lib/games/bartender/models/ring.dart';
import '../../../nhombar/lib/games/bartender/models/room.dart';
import '../../../nhombar/lib/games/bartender/models/round.dart';
import '../../../nhombar/lib/games/bartender/models/round_setup.dart';
import '../../../nhombar/lib/games/bartender/models/station.dart';
import 'exceptions.dart';

/// Identity session associated with a player token.
class PlayerSession {
  final String roomCode;
  final String playerId;
  final DateTime createdAt;

  PlayerSession({
    required this.roomCode,
    required this.playerId,
  }) : createdAt = DateTime.now();
}

/// Result returned from createRoom or joinRoom.
class JoinResult {
  final Room room;
  final String playerId;
  final String playerToken;

  const JoinResult({
    required this.room,
    required this.playerId,
    required this.playerToken,
  });

  Map<String, dynamic> toJson() => {
        'room': room.toJson(),
        'playerId': playerId,
        'playerToken': playerToken,
      };
}

/// In-memory room manager and game loop engine.
///
/// All state mutations for a room execute synchronously without awaits,
/// guaranteeing zero race conditions on the single-threaded Dart event loop.
class RoomService {
  RoomService({
    Random? rng,
    bool enableTimers = true,
    int Function()? nowMs,
  })  : _rng = rng ?? Random(),
        _clock = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch),
        _enableTimers = enableTimers {
    if (_enableTimers) {
      _startLoops();
    }
  }

  final Random _rng;
  final int Function() _clock;
  final bool _enableTimers;

  final Map<String, Room> _rooms = {};
  final Map<String, DateTime> _roomCreatedTimes = {};
  final Map<String, DateTime> _roomEndedTimes = {};
  final Map<String, PlayerSession> _sessions = {}; // token -> PlayerSession

  // WebSocket connections
  final Map<String, Set<_ClientSocket>> _roomSockets =
      {}; // roomCode -> sockets
  final Map<String, Set<_ClientSocket>> _playerSockets =
      {}; // playerId -> sockets

  Timer? _gameLoopTimer;
  Timer? _spawnTimer;
  Timer? _pingTimer;
  Timer? _cleanupTimer;

  int get roomsCount => _rooms.length;

  int _nowMs() => _clock();

  String _generateToken() {
    final bytes = List<int>.generate(16, (_) => _rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  String _generateRoomCode() {
    for (var i = 0; i < 1000; i++) {
      final code = (_rng.nextInt(9000) + 1000).toString();
      if (!_rooms.containsKey(code)) return code;
    }
    throw StateError('Cannot generate unique 4-digit room code.');
  }

  String _generateItemId() {
    return 'item_${_nowMs()}_${_rng.nextInt(100000)}';
  }

  void _startLoops() {
    // Game tick every 1s (checks timer expiry)
    _gameLoopTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tickGameLoop();
    });

    // Spawn ingredients every 3s
    _spawnTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _tickIngredientSpawn();
    });

    // WebSocket ping every 25s
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      _sendPing();
    });

    // Cleanup old rooms every 60s
    _cleanupTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _cleanupOldRooms();
    });
  }

  void dispose() {
    _gameLoopTimer?.cancel();
    _spawnTimer?.cancel();
    _pingTimer?.cancel();
    _cleanupTimer?.cancel();

    for (final sockets in List.of(_roomSockets.values)) {
      for (final s in List.of(sockets)) {
        s.close(1000, 'Server shutdown');
      }
    }
    _roomSockets.clear();
    _playerSockets.clear();
    _rooms.clear();
    _sessions.clear();
  }

  PlayerSession _authenticate(String code, String token) {
    final session = _sessions[token];
    if (session == null || session.roomCode != code) {
      throw ApiException.unauthorized();
    }
    return session;
  }

  Room _getRoomOrThrow(String code) {
    final room = _rooms[code];
    if (room == null) {
      throw ApiException.roomNotFound(code);
    }
    return room;
  }

  Player _getPlayerOrThrow(Room room, String playerId) {
    final player = room.players[playerId];
    if (player == null) {
      throw ApiException.unauthorized();
    }
    return player;
  }

  void _broadcast(String code) {
    final room = _rooms[code];
    if (room == null) return;
    final message = jsonEncode({
      'type': 'snapshot',
      'room': room.copyWith(serverNowMs: _nowMs()).toJson(),
    });
    final sockets = _roomSockets[code];
    if (sockets != null) {
      for (final s in List.of(sockets)) {
        s.send(message);
      }
    }
  }

  // ─── API Endpoints Logic ──────────────────────────────────────────

  JoinResult createRoom({required String playerName}) {
    final name = playerName.trim();
    if (name.isEmpty) {
      throw ApiException.invalidRequest('Player name cannot be empty.');
    }

    final code = _generateRoomCode();
    final playerId = 'p_0';
    final token = _generateToken();

    final host = Player(
      id: playerId,
      name: name,
      ringIndex: 0,
      connected: true,
      completedOrders: 0,
      readyInLobby: true,
    );

    final room = Room(
      code: code,
      status: RoomStatus.lobby,
      serverNowMs: _nowMs(),
      players: {playerId: host},
      inbox: const {},
    );

    _rooms[code] = room;
    _roomCreatedTimes[code] = DateTime.now();
    _sessions[token] = PlayerSession(roomCode: code, playerId: playerId);

    return JoinResult(
      room: room,
      playerId: playerId,
      playerToken: token,
    );
  }

  JoinResult joinRoom({
    required String code,
    required String playerName,
  }) {
    final room = _getRoomOrThrow(code);
    final name = playerName.trim();
    if (name.isEmpty) {
      throw ApiException.invalidRequest('Player name cannot be empty.');
    }

    if (room.status != RoomStatus.lobby) {
      throw ApiException.roomNotJoinable();
    }

    if (room.players.length >= 4) {
      throw ApiException.roomFull();
    }

    final newRingIndex = room.players.length;
    final playerId = 'p_$newRingIndex';
    final token = _generateToken();

    final newPlayer = Player(
      id: playerId,
      name: name,
      ringIndex: newRingIndex,
      connected: true,
      completedOrders: 0,
      readyInLobby: true,
    );

    final updatedPlayers = Map<String, Player>.of(room.players)
      ..[playerId] = newPlayer;

    final updatedRoom = room.copyWith(
      serverNowMs: _nowMs(),
      players: updatedPlayers,
    );

    _rooms[code] = updatedRoom;
    _sessions[token] = PlayerSession(roomCode: code, playerId: playerId);
    _broadcast(code);

    return JoinResult(
      room: updatedRoom,
      playerId: playerId,
      playerToken: token,
    );
  }

  Room getRoom({required String code, required String token}) {
    final session = _authenticate(code, token);
    final room = _getRoomOrThrow(code);
    _getPlayerOrThrow(room, session.playerId);
    return room.copyWith(serverNowMs: _nowMs());
  }

  void leaveRoom({required String code, required String token}) {
    final session = _authenticate(code, token);
    final room = _getRoomOrThrow(code);
    final player = _getPlayerOrThrow(room, session.playerId);

    if (room.status == RoomStatus.lobby) {
      final updatedPlayers = Map<String, Player>.of(room.players)
        ..remove(player.id);

      if (updatedPlayers.isEmpty) {
        _deleteRoom(code);
        return;
      }

      // Compact ringIndex in lobby (D14)
      var ring = 0;
      final compacted = <String, Player>{};
      for (final p in updatedPlayers.values) {
        compacted[p.id] = p.copyWith(ringIndex: ring++);
      }

      final updatedRoom = room.copyWith(
        serverNowMs: _nowMs(),
        players: compacted,
      );
      _rooms[code] = updatedRoom;
      _broadcast(code);
    } else if (room.status == RoomStatus.playing) {
      final updatedPlayers = Map<String, Player>.of(room.players)
        ..[player.id] = player.copyWith(connected: false);

      final updatedRoom = room.copyWith(
        serverNowMs: _nowMs(),
        players: updatedPlayers,
      );
      _rooms[code] = updatedRoom;

      if (updatedRoom.connectedPlayerCount < 2) {
        endMatch(code);
      } else {
        _finishPreparationIfReady(code);
        _broadcast(code);
      }
    } else {
      // ended status: mark connected = false
      final updatedPlayers = Map<String, Player>.of(room.players)
        ..[player.id] = player.copyWith(connected: false);
      _rooms[code] = room.copyWith(
        serverNowMs: _nowMs(),
        players: updatedPlayers,
      );
      _broadcast(code);
    }
  }

  void startMatch(
      {required String code,
      required String token,
      bool waitForScene = false}) {
    final session = _authenticate(code, token);
    final room = _getRoomOrThrow(code);
    _getPlayerOrThrow(room, session.playerId);

    // Repeated calls ignored
    if (room.status == RoomStatus.playing) return;

    if (room.status != RoomStatus.lobby && room.status != RoomStatus.ended) {
      throw ApiException.invalidState(
          'Cannot start match in status ${room.status.name}.');
    }

    if (room.connectedPlayerCount < 2) {
      throw ApiException.notEnoughPlayers();
    }

    // Compact connected players into 0..k-1
    final connectedPlayers = room.players.values
        .where((p) => p.connected)
        .toList()
      ..sort((a, b) => a.ringIndex.compareTo(b.ringIndex));

    final compactedPlayers = <String, Player>{};
    for (var i = 0; i < connectedPlayers.length; i++) {
      final p = connectedPlayers[i];
      compactedPlayers[p.id] = p.copyWith(
        ringIndex: i,
        completedOrders: 0,
        readyInLobby: false,
      );
    }

    final playerCount = compactedPlayers.length;
    final playerIds = compactedPlayers.values.map((p) => p.id).toList();

    // Round 1 generation
    final roundSetup = RoundSetup.generate(
      playerIds: playerIds,
      roundNumber: 1,
      rng: _rng,
    );

    final ordersByPlayer = <String, List<Order>>{};
    for (final pid in playerIds) {
      final orders = <Order>[];
      for (var i = 1; i <= 3; i++) {
        final recipe = roundSetup
            .feasibleRecipes[_rng.nextInt(roundSetup.feasibleRecipes.length)];
        orders.add(Order(
          id: 'o_${pid}_1_$i',
          recipeId: recipe.id,
          status: OrderStatus.pending,
        ));
      }
      ordersByPlayer[pid] = orders;
    }

    final progress = {for (var i = 0; i < playerCount; i++) i: 0};

    final currentRound = Round(
      number: 1,
      ordersPerPlayer: 3,
      stationAssignment: roundSetup.stationAssignment,
      playerOrders: ordersByPlayer,
      progress: progress,
    );

    // Initial inboxes: 1 ingredient per player
    final initialIngredients = [
      Ingredient.orange.name,
      Ingredient.lemon.name,
      Ingredient.strawberry.name,
    ];

    final inboxes = <int, List<GameItem>>{};
    for (var ring = 0; ring < playerCount; ring++) {
      final ingName = initialIngredients[ring % initialIngredients.length];
      inboxes[ring] = [
        GameItem(
          id: _generateItemId(),
          type: GameItemType.ingredient,
          itemId: ingName,
          fromRingIndex: ring,
        ),
      ];
    }

    final nowMs = _nowMs();
    final timer = waitForScene
        ? MatchTimer.prepare(nowMs: nowMs)
        : MatchTimer.start(nowMs: nowMs);

    final updatedRoom = room.copyWith(
      status: RoomStatus.playing,
      serverNowMs: nowMs,
      players: compactedPlayers,
      timer: timer,
      currentRound: currentRound,
      inbox: inboxes,
      clearResults: true,
    );

    _rooms[code] = updatedRoom;
    _broadcast(code);
  }

  void markSceneReady(
      {required String code,
      required String token,
      required int preparationId}) {
    final session = _authenticate(code, token);
    final room = _getRoomOrThrow(code);
    final player = _getPlayerOrThrow(room, session.playerId);
    if (!player.connected ||
        room.status != RoomStatus.playing ||
        room.timer?.isPreparing != true ||
        room.timer!.startedAt != preparationId) return;
    final timer = room.timer!.markSceneReady(
        playerId: player.id,
        connectedPlayerIds: room.players.values
            .where((p) => p.connected)
            .map((p) => p.id)
            .toSet(),
        nowMs: _nowMs());
    _rooms[code] = room.copyWith(timer: timer, serverNowMs: _nowMs());
    _broadcast(code);
  }

  void _requireStarted(Room room) {
    if (room.timer != null && !room.timer!.hasStarted(nowMs: _nowMs())) {
      throw ApiException.invalidState('Match is preparing or counting down.');
    }
  }

  void _finishPreparationIfReady(String code) {
    final room = _rooms[code];
    final timer = room?.timer;
    if (room == null ||
        room.status != RoomStatus.playing ||
        timer == null ||
        !timer.isPreparing) return;
    final connected =
        room.players.values.where((p) => p.connected).map((p) => p.id).toSet();
    if (connected.length < 2 || !connected.every(timer.readyPlayerIds.contains))
      return;
    _rooms[code] = room.copyWith(
        timer: timer.markSceneReady(
            playerId: connected.first,
            connectedPlayerIds: connected,
            nowMs: _nowMs()));
  }

  void sendItem({
    required String code,
    required String token,
    required String itemId,
    required int toRingIndex,
  }) {
    final session = _authenticate(code, token);
    final room = _getRoomOrThrow(code);
    final player = _getPlayerOrThrow(room, session.playerId);

    _requireStarted(room);
    if (room.status != RoomStatus.playing) {
      throw ApiException.invalidState('Action only allowed while playing.');
    }

    final playerCount = room.connectedPlayerCount;
    final fromRing = player.ringIndex;

    final isAdjacent =
        Ring.leftNeighbor(fromRing, playerCount) == toRingIndex ||
            Ring.rightNeighbor(fromRing, playerCount) == toRingIndex;

    if (!isAdjacent) {
      throw ApiException.invalidMove(
        'Target ringIndex $toRingIndex is not adjacent to $fromRing.',
      );
    }

    final senderInbox = List<GameItem>.of(room.inbox[fromRing] ?? const []);
    final itemIndex = senderInbox.indexWhere((it) => it.id == itemId);
    if (itemIndex == -1) {
      throw ApiException.itemNotFound(itemId);
    }

    final item = senderInbox.removeAt(itemIndex);
    final movedItem = GameItem(
      id: item.id,
      type: item.type,
      itemId: item.itemId,
      fromRingIndex: fromRing,
    );

    final receiverInbox = List<GameItem>.of(room.inbox[toRingIndex] ?? const [])
      ..add(movedItem);

    final updatedInboxes = Map<int, List<GameItem>>.of(room.inbox)
      ..[fromRing] = senderInbox
      ..[toRingIndex] = receiverInbox;

    final updatedRoom = room.copyWith(
      serverNowMs: _nowMs(),
      inbox: updatedInboxes,
    );

    _rooms[code] = updatedRoom;
    _broadcast(code);
  }

  void trashItem({
    required String code,
    required String token,
    required String itemId,
  }) {
    final session = _authenticate(code, token);
    final room = _getRoomOrThrow(code);
    final player = _getPlayerOrThrow(room, session.playerId);

    _requireStarted(room);
    if (room.status != RoomStatus.playing) {
      throw ApiException.invalidState('Action only allowed while playing.');
    }

    final ring = player.ringIndex;
    final inbox = List<GameItem>.of(room.inbox[ring] ?? const []);
    final idx = inbox.indexWhere((it) => it.id == itemId);
    if (idx == -1) {
      throw ApiException.itemNotFound(itemId);
    }

    inbox.removeAt(idx);

    final updatedInboxes = Map<int, List<GameItem>>.of(room.inbox)
      ..[ring] = inbox;

    final updatedRoom = room.copyWith(
      serverNowMs: _nowMs(),
      inbox: updatedInboxes,
    );

    _rooms[code] = updatedRoom;
    _broadcast(code);
  }

  GameItem processItemAtStation({
    required String code,
    required String token,
    required String itemId,
    required String station,
  }) {
    final session = _authenticate(code, token);
    final room = _getRoomOrThrow(code);
    final player = _getPlayerOrThrow(room, session.playerId);

    _requireStarted(room);
    if (room.status != RoomStatus.playing) {
      throw ApiException.invalidState('Action only allowed while playing.');
    }

    StationType stationType;
    try {
      stationType = StationType.values.byName(station);
    } catch (_) {
      throw ApiException.invalidRequest('Unknown station $station.');
    }

    final assigned = room.currentRound?.stationAssignment[player.ringIndex];
    if (assigned != stationType) {
      throw ApiException.invalidMove(
        'Player is assigned to ${assigned?.name}, cannot use $station.',
      );
    }

    final ring = player.ringIndex;
    final inbox = List<GameItem>.of(room.inbox[ring] ?? const []);
    final idx = inbox.indexWhere((it) => it.id == itemId);
    if (idx == -1) {
      throw ApiException.itemNotFound(itemId);
    }

    final oldItem = inbox[idx];
    final processedItemId = processItem(oldItem.itemId, stationType);
    if (processedItemId == null) {
      throw ApiException.invalidMove(
        'Station $station cannot process item ${oldItem.itemId}.',
      );
    }

    final newItem = GameItem(
      id: oldItem.id,
      type: GameItemType.product,
      itemId: processedItemId,
      fromRingIndex: ring,
    );

    inbox[idx] = newItem;

    final updatedInboxes = Map<int, List<GameItem>>.of(room.inbox)
      ..[ring] = inbox;

    final updatedRoom = room.copyWith(
      serverNowMs: _nowMs(),
      inbox: updatedInboxes,
    );

    _rooms[code] = updatedRoom;
    _broadcast(code);

    return newItem;
  }

  void submitOrder({
    required String code,
    required String token,
    required String orderId,
    required String itemId,
  }) {
    final session = _authenticate(code, token);
    final room = _getRoomOrThrow(code);
    final player = _getPlayerOrThrow(room, session.playerId);

    _requireStarted(room);
    if (room.status != RoomStatus.playing) {
      throw ApiException.invalidState('Action only allowed while playing.');
    }

    final currentRound = room.currentRound;
    if (currentRound == null) {
      throw ApiException.invalidState('No round active.');
    }

    final orders = currentRound.playerOrders[player.id];
    final orderIdx = orders?.indexWhere((o) => o.id == orderId) ?? -1;
    if (orders == null || orderIdx == -1) {
      throw ApiException.orderMismatch(
          'Order $orderId does not belong to player.');
    }

    final order = orders[orderIdx];
    if (order.isCompleted) {
      throw ApiException.orderMismatch('Order $orderId already submitted.');
    }

    final ring = player.ringIndex;
    final inbox = List<GameItem>.of(room.inbox[ring] ?? const []);
    final itemIdx =
        inbox.indexWhere((it) => it.id == itemId || it.itemId == itemId);
    if (itemIdx == -1) {
      throw ApiException.itemNotFound(itemId);
    }

    final productItem = inbox[itemIdx];
    final recipe =
        RecipePool.allRecipes.where((r) => r.id == order.recipeId).firstOrNull;

    if (recipe == null ||
        (productItem.itemId != recipe.productId &&
            productItem.itemId != order.recipeId)) {
      throw ApiException.orderMismatch(
        'Item ${productItem.itemId} does not match recipe product ${recipe?.productId}.',
      );
    }

    // Remove submitted product from inbox
    inbox.removeAt(itemIdx);

    // Update order status
    final updatedOrders = List<Order>.of(orders)
      ..[orderIdx] = order.copyWith(
        status: OrderStatus.submitted,
      );

    final updatedPlayerOrders =
        Map<String, List<Order>>.of(currentRound.playerOrders)
          ..[player.id] = updatedOrders;

    // Update player completed orders
    final updatedPlayer = player.copyWith(
      completedOrders: player.completedOrders + 1,
    );
    final updatedPlayers = Map<String, Player>.of(room.players)
      ..[player.id] = updatedPlayer;

    // Update progress
    final updatedProgress = Map<int, int>.of(currentRound.progress)
      ..[ring] = (currentRound.progress[ring] ?? 0) + 1;

    // Time bonus +5s
    final updatedTimer = room.timer?.withBonus();

    final updatedInboxes = Map<int, List<GameItem>>.of(room.inbox)
      ..[ring] = inbox;

    var updatedRound = currentRound.copyWith(
      playerOrders: updatedPlayerOrders,
      progress: updatedProgress,
    );

    var nextRoom = room.copyWith(
      serverNowMs: _nowMs(),
      players: updatedPlayers,
      timer: updatedTimer,
      currentRound: updatedRound,
      inbox: updatedInboxes,
    );

    // Check round advance: all connected players done
    final connectedPlayers =
        nextRoom.players.values.where((p) => p.connected).toList();

    final allDone = connectedPlayers.every(
      (p) =>
          (updatedProgress[p.ringIndex] ?? 0) >= updatedRound.ordersPerPlayer,
    );

    if (allDone) {
      nextRoom = _advanceRound(nextRoom);
    }

    _rooms[code] = nextRoom;
    _broadcast(code);
  }

  Room _advanceRound(Room room) {
    // Drop disconnected players and compact ring (D14)
    final connected = room.players.values.where((p) => p.connected).toList()
      ..sort((a, b) => a.ringIndex.compareTo(b.ringIndex));

    if (connected.length < 2) {
      _endMatchInternal(room);
      return _rooms[room.code]!;
    }

    final compactedPlayers = <String, Player>{};
    final newInboxes = <int, List<GameItem>>{};

    for (var i = 0; i < connected.length; i++) {
      final oldPlayer = connected[i];
      final newPlayer = oldPlayer.copyWith(ringIndex: i);
      compactedPlayers[newPlayer.id] = newPlayer;

      // Move player inbox items to new ringIndex
      final existingItems = room.inbox[oldPlayer.ringIndex] ?? const [];
      final movedItems = existingItems
          .map((it) => GameItem(
                id: it.id,
                type: it.type,
                itemId: it.itemId,
                fromRingIndex: i,
              ))
          .toList();

      // Add 1 fresh ingredient
      movedItems.add(GameItem(
        id: _generateItemId(),
        type: GameItemType.ingredient,
        itemId: _pickIngredientForRound(room.currentRound?.number ?? 1),
        fromRingIndex: i,
      ));

      newInboxes[i] = movedItems;
    }

    final nextRoundNumber = (room.currentRound?.number ?? 1) + 1;
    final playerIds = compactedPlayers.values.map((p) => p.id).toList();

    final setup = RoundSetup.generate(
      playerIds: playerIds,
      roundNumber: nextRoundNumber,
      rng: _rng,
    );

    final ordersByPlayer = <String, List<Order>>{};
    for (final pid in playerIds) {
      final orders = <Order>[];
      for (var i = 1; i <= 3; i++) {
        final recipe =
            setup.feasibleRecipes[_rng.nextInt(setup.feasibleRecipes.length)];
        orders.add(Order(
          id: 'o_${pid}_${nextRoundNumber}_$i',
          recipeId: recipe.id,
          status: OrderStatus.pending,
        ));
      }
      ordersByPlayer[pid] = orders;
    }

    final progress = {for (var i = 0; i < compactedPlayers.length; i++) i: 0};

    final newRound = Round(
      number: nextRoundNumber,
      ordersPerPlayer: 3,
      stationAssignment: setup.stationAssignment,
      playerOrders: ordersByPlayer,
      progress: progress,
    );

    return room.copyWith(
      serverNowMs: _nowMs(),
      players: compactedPlayers,
      currentRound: newRound,
      inbox: newInboxes,
    );
  }

  String _pickIngredientForRound(int roundNumber) {
    if (roundNumber <= 1) {
      return _rng.nextBool() ? Ingredient.orange.name : Ingredient.lemon.name;
    } else if (roundNumber == 2) {
      final choices = [
        Ingredient.orange.name,
        Ingredient.lemon.name,
        Ingredient.strawberry.name,
      ];
      return choices[_rng.nextInt(choices.length)];
    } else {
      final choices = [
        Ingredient.orange.name,
        Ingredient.lemon.name,
        Ingredient.strawberry.name,
        Ingredient.sugar.name,
        Ingredient.ice.name,
      ];
      return choices[_rng.nextInt(choices.length)];
    }
  }

  void endMatch(String code) {
    final room = _rooms[code];
    if (room == null || room.status == RoomStatus.ended) return;
    _endMatchInternal(room);
  }

  void _endMatchInternal(Room room) {
    final nowMs = _nowMs();
    final survivalSec = room.timer?.totalSurvivalSeconds(nowMs: nowMs) ?? 0;

    final results = MatchResult.fromPlayers(
      players: room.players.values.toList(),
      survivalSeconds: survivalSec,
    );

    // Results written first before status = ended per contract
    final endedRoom = room.copyWith(
      serverNowMs: nowMs,
      results: results,
      status: RoomStatus.ended,
    );

    _rooms[room.code] = endedRoom;
    _roomEndedTimes[room.code] = DateTime.now();
    _broadcast(room.code);
  }

  // ─── Periodic Loops ───────────────────────────────────────────────

  void _tickGameLoop() {
    final nowMs = _nowMs();
    for (final room in List.of(_rooms.values)) {
      if (room.status == RoomStatus.playing) {
        if (room.timer != null && room.timer!.isExpired(nowMs: nowMs)) {
          endMatch(room.code);
        }
      }
    }
  }

  void _tickIngredientSpawn() {
    for (final room in List.of(_rooms.values)) {
      if (room.status == RoomStatus.playing &&
          (room.timer?.hasStarted(nowMs: _nowMs()) ?? false)) {
        var modified = false;
        final inboxes = Map<int, List<GameItem>>.of(room.inbox);

        final connectedRings = room.players.values
            .where((p) => p.connected)
            .map((p) => p.ringIndex)
            .toSet();

        for (final ring in connectedRings) {
          final items = List<GameItem>.of(inboxes[ring] ?? const []);
          if (items.length < 5) {
            items.add(GameItem(
              id: _generateItemId(),
              type: GameItemType.ingredient,
              itemId: _pickIngredientForRound(room.currentRound?.number ?? 1),
              fromRingIndex: ring,
            ));
            inboxes[ring] = items;
            modified = true;
          }
        }

        if (modified) {
          _rooms[room.code] = room.copyWith(
            serverNowMs: _nowMs(),
            inbox: inboxes,
          );
          _broadcast(room.code);
        }
      }
    }
  }

  void _sendPing() {
    const pingMessage = '{"type":"ping"}';
    for (final sockets in _roomSockets.values) {
      for (final s in sockets) {
        s.send(pingMessage);
      }
    }
  }

  void _cleanupOldRooms() {
    final now = DateTime.now();

    for (final entry in List.of(_roomEndedTimes.entries)) {
      if (now.difference(entry.value).inMinutes >= 10) {
        _deleteRoom(entry.key);
      }
    }

    for (final entry in List.of(_roomCreatedTimes.entries)) {
      final room = _rooms[entry.key];
      if (room != null &&
          room.status == RoomStatus.lobby &&
          room.connectedPlayerCount == 0 &&
          now.difference(entry.value).inMinutes >= 30) {
        _deleteRoom(entry.key);
      }
    }
  }

  void _deleteRoom(String code) {
    _rooms.remove(code);
    _roomCreatedTimes.remove(code);
    _roomEndedTimes.remove(code);

    final sockets = _roomSockets.remove(code);
    if (sockets != null) {
      for (final s in sockets) {
        s.close(1000, 'Room closed');
      }
    }

    _sessions.removeWhere((_, session) => session.roomCode == code);
  }

  // ─── WebSocket Client Connection ──────────────────────────────────

  void handleWebSocketConnection({
    required String code,
    required String token,
    required Stream<dynamic> incoming,
    required void Function(String message) send,
    required void Function([int? code, String? reason]) close,
  }) {
    final room = _rooms[code];
    if (room == null) {
      close(4404, 'Room not found');
      return;
    }

    final session = _sessions[token];
    if (session == null || session.roomCode != code) {
      close(4401, 'Unauthorized token');
      return;
    }

    final playerId = session.playerId;
    final socket = _ClientSocket(send: send, close: close);

    // Register socket
    _roomSockets.putIfAbsent(code, () => {}).add(socket);
    _playerSockets.putIfAbsent(playerId, () => {}).add(socket);

    // Mark player connected = true
    final p = room.players[playerId];
    if (p != null && !p.connected) {
      final updatedPlayers = Map<String, Player>.of(room.players)
        ..[playerId] = p.copyWith(connected: true);
      _rooms[code] = room.copyWith(
        serverNowMs: _nowMs(),
        players: updatedPlayers,
      );
      _broadcast(code);
    } else {
      // Send initial snapshot directly to this new socket
      socket.send(jsonEncode({
        'type': 'snapshot',
        'room': _rooms[code]!.copyWith(serverNowMs: _nowMs()).toJson(),
      }));
    }

    incoming.listen(
      (data) {
        // May answer pong or custom messages
      },
      onDone: () => _onSocketClosed(code, playerId, socket),
      onError: (_) => _onSocketClosed(code, playerId, socket),
      cancelOnError: true,
    );
  }

  void _onSocketClosed(String code, String playerId, _ClientSocket socket) {
    final roomSockets = _roomSockets[code];
    roomSockets?.remove(socket);
    if (roomSockets != null && roomSockets.isEmpty) {
      _roomSockets.remove(code);
    }

    final playerSockets = _playerSockets[playerId];
    playerSockets?.remove(socket);

    // When a player's last socket closes: connected = false
    if (playerSockets == null || playerSockets.isEmpty) {
      _playerSockets.remove(playerId);

      final room = _rooms[code];
      if (room != null) {
        final p = room.players[playerId];
        if (p != null && p.connected) {
          final updatedPlayers = Map<String, Player>.of(room.players)
            ..[playerId] = p.copyWith(connected: false);

          final updatedRoom = room.copyWith(
            serverNowMs: _nowMs(),
            players: updatedPlayers,
          );
          _rooms[code] = updatedRoom;

          if (updatedRoom.status == RoomStatus.playing &&
              updatedRoom.connectedPlayerCount < 2) {
            endMatch(code);
          } else {
            _finishPreparationIfReady(code);
            _broadcast(code);
          }
        }
      }
    }
  }
}

class _ClientSocket {
  final void Function(String message) send;
  final void Function([int? code, String? reason]) close;

  _ClientSocket({required this.send, required this.close});
}
