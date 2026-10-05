import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../bartender_config.dart';
import '../models/game_item.dart';
import '../models/match_result.dart';
import '../models/match_timer.dart';
import '../models/order.dart';
import '../models/player.dart';
import '../models/recipe_pool.dart';
import '../models/room.dart';
import '../models/round.dart';
import '../models/station.dart';
import '../models/station_assigner.dart';
import 'room_repository.dart';

/// Triển khai [RoomRepository] trên Firebase Realtime Database.
///
/// Tuân theo schema trong API.md (rooms/{code}/...).
/// Dùng xác thực ẩn danh (FirebaseAuth.signInAnonymously) để mỗi
/// client có uid duy nhất, phục vụ làm playerId trong RTDB.
///
/// Thiết kế race-safe (multi-device):
/// - joinRoom dùng RTDB runTransaction để tránh ringIndex trùng.
/// - submitOrder dùng runTransaction để increment progress + timer atomically.
/// - _checkRoundCompletion chỉ host (ringIndex==0) được trigger tạo round mới.
/// - endMatch chỉ ghi nếu status còn "playing" (idempotent).
///
/// Để xoá Firebase: xoá file này + 3 dòng pubspec.yaml + firebase_options.dart
/// + google-services.json. Code game (controller/widgets/screens) không đổi.
class FirebaseRoomRepository implements RoomRepository {
  FirebaseRoomRepository({
    FirebaseDatabase? database,
    FirebaseAuth? auth,
    Random? rng,
  })  : _db = database ?? FirebaseDatabase.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _rng = rng ?? Random();

  final FirebaseDatabase _db;
  final FirebaseAuth _auth;
  final Random _rng;

  /// UID của người chơi trên máy này.
  String? _myUid;

  /// Stream subscriptions theo từng room code.
  final Map<String, StreamSubscription<DatabaseEvent>> _subs = {};

  /// Stream controllers theo từng room code.
  final Map<String, StreamController<Room>> _streamControllers = {};

  // ─── Auth ───────────────────────────────────────────────────────────────────

  Future<String> _ensureAuth() async {
    if (_myUid != null) return _myUid!;
    User? user = _auth.currentUser;
    if (user == null) {
      final cred = await _auth.signInAnonymously();
      user = cred.user;
    }
    _myUid = user!.uid;
    return _myUid!;
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  DatabaseReference _roomRef(String code) => _db.ref('rooms/$code');
  DatabaseReference _inboxRef(String code, int ring) =>
      _db.ref('rooms/$code/inbox/$ring');
  DatabaseReference _roundRef(String code) => _db.ref('rooms/$code/round');
  DatabaseReference _timerRef(String code) => _db.ref('rooms/$code/timer');
  DatabaseReference _progressRef(String code) =>
      _db.ref('rooms/$code/round/progress');

  // ─── RoomRepository impl ────────────────────────────────────────────────────

  @override
  Future<Room> createRoom({
    required String hostPlayerName,
    int totalPlayers = 3,
  }) async {
    final uid = await _ensureAuth();
    final code = (_rng.nextInt(9000) + 1000).toString();
    final now = DateTime.now().millisecondsSinceEpoch;

    final hostName =
        hostPlayerName.trim().isEmpty ? 'Bạn' : hostPlayerName.trim();

    await _roomRef(code).set({
      'createdAt': now,
      'status': 'lobby',
      'totalPlayers': totalPlayers,
      'players': {
        uid: {
          'name': hostName,
          'ringIndex': 0,
          'connected': true,
          'completedOrders': 0,
        },
      },
    });

    return Room(
      code: code,
      status: RoomStatus.lobby,
      players: {
        uid: Player(
          id: uid,
          name: hostName,
          ringIndex: 0,
          connected: true,
          completedOrders: 0,
        ),
      },
      inbox: {for (var i = 0; i < totalPlayers; i++) i: const []},
    );
  }

  @override
  Future<Room> joinRoom({
    required String code,
    required String playerName,
  }) async {
    final uid = await _ensureAuth();
    final name = playerName.trim().isEmpty ? 'Khách' : playerName.trim();

    // Dùng transaction để tránh race condition ringIndex trùng
    // khi nhiều người join cùng lúc.
    int assignedRing = -1;

    await _db.ref('rooms/$code/players').runTransaction((currentData) {
      final players =
          (currentData as Map<String, dynamic>?) ?? <String, dynamic>{};

      // Nếu player đã tồn tại (reconnect), giữ nguyên ringIndex
      if (players.containsKey(uid)) {
        players[uid] = {
          ...Map<String, dynamic>.from(players[uid] as Map),
          'connected': true,
        };
        assignedRing =
            (players[uid] as Map)['ringIndex'] as int? ?? players.length - 1;
        return Transaction.success(players);
      }

      // Player mới: gán ringIndex = số player hiện tại
      assignedRing = players.length;
      players[uid] = {
        'name': name,
        'ringIndex': assignedRing,
        'connected': true,
        'completedOrders': 0,
      };
      return Transaction.success(players);
    });

    // Đọc lại room state mới nhất sau transaction
    final snap = await _roomRef(code).get();
    if (!snap.exists) throw StateError('Phòng $code không tồn tại');
    return _parseRoom(code, snap.value as Map);
  }

  @override
  Future<void> leaveRoom({
    required String code,
    required String playerId,
  }) async {
    // Không xoá slot — chỉ set connected=false để giữ nguyên ringIndex
    await _db
        .ref('rooms/$code/players/$playerId/connected')
        .set(false);
  }

  @override
  Future<void> startMatch({required String code}) async {
    final roomSnap = await _roomRef(code).get();
    if (!roomSnap.exists) return;

    final roomData = roomSnap.value as Map;
    // Guard: chỉ start nếu đang ở lobby
    if ((roomData['status'] as String?) != 'lobby') return;

    final playersData = (roomData['players'] as Map?) ?? {};
    final totalPlayers =
        (roomData['totalPlayers'] as int?) ?? playersData.length;

    // Phân trạm
    final assignment = StationAssigner.assign(
      playerCount: totalPlayers,
      random: _rng,
    );

    // Tạo đơn hàng round 1
    final recipes = RecipePool.recipesForRound(1);
    final ordersData = <String, dynamic>{};
    final progressData = <String, dynamic>{};
    var orderCounter = 1;

    for (final entry in playersData.entries) {
      final playerId = entry.key as String;
      final playerData = entry.value as Map;
      final ring = (playerData['ringIndex'] as int?) ?? 0;
      final playerOrders = <String, dynamic>{};
      for (var i = 0; i < BartenderConfig.ordersPerPlayer; i++) {
        final recipe = recipes[_rng.nextInt(recipes.length)];
        playerOrders['ord_${orderCounter++}'] = {
          'recipeId': recipe.id,
          'status': 'pending',
        };
      }
      ordersData[playerId] = playerOrders;
      progressData['$ring'] = 0;
    }

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final endTime = nowMs + BartenderConfig.initialTimerSeconds * 1000;

    // Multi-path update — atomic
    await _roomRef(code).update({
      'status': 'playing',
      'timer': {
        'startedAt': nowMs,
        'endTime': endTime,
      },
      'round': {
        'number': 1,
        'ordersPerPlayer': BartenderConfig.ordersPerPlayer,
        'stationAssignment': {
          for (final e in assignment.entries) '${e.key}': e.value?.name ?? '',
        },
        'progress': progressData,
      },
      'orders': ordersData,
    });

    // Sinh nguyên liệu ban đầu
    for (var ring = 0; ring < totalPlayers; ring++) {
      final itemId = 'init_${ring}_${DateTime.now().microsecondsSinceEpoch}';
      final ingredients = ['orange', 'lemon', 'strawberry', 'ice'];
      await _inboxRef(code, ring).child(itemId).set({
        'type': 'ingredient',
        'itemId': ingredients[_rng.nextInt(ingredients.length)],
        'fromRingIndex': ring,
      });
    }
  }

  @override
  Stream<Room> watchRoom(String code) {
    // Trả lại stream hiện tại nếu đã có
    final existing = _streamControllers[code];
    if (existing != null && !existing.isClosed) {
      return existing.stream;
    }

    final ctrl = StreamController<Room>.broadcast(
      onCancel: () {
        _subs[code]?.cancel();
        _subs.remove(code);
      },
    );
    _streamControllers[code] = ctrl;

    // Mỗi room có subscription riêng (fix bug cũ chỉ track 1 sub)
    _subs[code]?.cancel();
    _subs[code] = _roomRef(code).onValue.listen(
      (event) {
        if (ctrl.isClosed) return;
        if (!event.snapshot.exists) return;
        try {
          final room = _parseRoom(code, event.snapshot.value as Map);
          ctrl.add(room);
        } catch (_) {
          // Dữ liệu chưa đầy đủ (vd: mới tạo phòng) — bỏ qua
        }
      },
      onError: (Object e) {
        if (!ctrl.isClosed) ctrl.addError(e);
      },
    );

    return ctrl.stream;
  }

  @override
  Future<void> sendItem({
    required String code,
    required int fromRingIndex,
    required int toRingIndex,
    required GameItem item,
  }) async {
    // Xoá rồi ghi trong cùng một multi-path update
    await _db.ref().update({
      'rooms/$code/inbox/$fromRingIndex/${item.id}': null, // null = xoá
      'rooms/$code/inbox/$toRingIndex/${item.id}': {
        'type': item.type.name,
        'itemId': item.itemId,
        'fromRingIndex': fromRingIndex,
      },
    });
  }

  @override
  Future<void> trashItem({
    required String code,
    required int ringIndex,
    required String itemId,
  }) async {
    await _inboxRef(code, ringIndex).child(itemId).remove();
  }

  @override
  Future<GameItem> processItemAtStation({
    required String code,
    required int ringIndex,
    required String itemId,
    required StationType station,
  }) async {
    final snap = await _inboxRef(code, ringIndex).child(itemId).get();
    if (!snap.exists) throw ArgumentError('Item $itemId không tồn tại');

    final data = snap.value as Map;
    final currentItemId = data['itemId'] as String;
    final resultItemId = _processItem(currentItemId, station);

    await _inboxRef(code, ringIndex).child(itemId).update({
      'type': 'product',
      'itemId': resultItemId,
    });

    return GameItem(
      id: itemId,
      type: GameItemType.product,
      itemId: resultItemId,
      fromRingIndex: ringIndex,
    );
  }

  @override
  Future<void> submitOrder({
    required String code,
    required String playerId,
    required String orderId,
    required String productId,
  }) async {
    // Lấy ringIndex
    final playerSnap =
        await _db.ref('rooms/$code/players/$playerId').get();
    if (!playerSnap.exists) return;
    final ringIndex =
        (playerSnap.value as Map)['ringIndex'] as int? ?? 0;

    // Dùng transaction để increment progress atomically (race-safe)
    bool roundCompleted = false;
    int ordersPerPlayer = BartenderConfig.ordersPerPlayer;

    await _progressRef(code).runTransaction((currentData) {
      final progress =
          Map<String, dynamic>.from((currentData as Map?) ?? {});
      final current = (progress['$ringIndex'] as int?) ?? 0;
      progress['$ringIndex'] = current + 1;

      // Kiểm tra tất cả ring xong chưa (cần biết totalPlayers)
      // Không thể đọc DB bên trong transaction — sẽ check sau
      return Transaction.success(progress);
    });

    // Cộng timer bonus + cập nhật order status + completedOrders
    // Dùng transaction trên timer để atomic increment endTime
    await _timerRef(code).child('endTime').runTransaction((currentData) {
      final current = (currentData as int?) ?? 0;
      return Transaction.success(
          current + BartenderConfig.orderCompletionBonusSeconds * 1000);
    });

    // Cập nhật order status và completedOrders cá nhân
    await _db.ref().update({
      'rooms/$code/orders/$playerId/$orderId/status': 'submitted',
      'rooms/$code/players/$playerId/completedOrders':
          ServerValue.increment(1),
    });

    // Xoá product đã nộp khỏi inbox
    await _inboxRef(code, ringIndex).child(productId).remove();

    // Đọc round info để kiểm tra round completion
    final roundSnap = await _roundRef(code).get();
    if (!roundSnap.exists) return;
    final roundData = roundSnap.value as Map;
    ordersPerPlayer = (roundData['ordersPerPlayer'] as int?) ??
        BartenderConfig.ordersPerPlayer;

    // Đọc progress sau transaction
    final progressSnap = await _progressRef(code).get();
    final progressData = (progressSnap.value as Map?) ?? {};

    // Lấy totalPlayers
    final roomSnap = await _roomRef(code).get();
    if (!roomSnap.exists) return;
    final roomData = roomSnap.value as Map;
    final playersData = (roomData['players'] as Map?) ?? {};
    final totalPlayers =
        (roomData['totalPlayers'] as int?) ?? playersData.length;

    // Kiểm tra tất cả done
    roundCompleted = true;
    for (var i = 0; i < totalPlayers; i++) {
      if (((progressData['$i'] as int?) ?? 0) < ordersPerPlayer) {
        roundCompleted = false;
        break;
      }
    }

    // Chỉ host (ringIndex==0) mới được tạo round mới để tránh duplicate writes
    if (roundCompleted && ringIndex == 0) {
      await _startNextRound(
        code: code,
        currentRound: (roundData['number'] as int?) ?? 1,
        ordersPerPlayer: ordersPerPlayer,
        playersData: playersData,
        totalPlayers: totalPlayers,
      );
    }
  }

  /// Tạo round tiếp theo — chỉ được gọi bởi host (ringIndex==0).
  Future<void> _startNextRound({
    required String code,
    required int currentRound,
    required int ordersPerPlayer,
    required Map playersData,
    required int totalPlayers,
  }) async {
    final nextRound = currentRound + 1;
    final newAssignment = StationAssigner.assign(
      playerCount: totalPlayers,
      random: _rng,
    );
    final nextRecipes = RecipePool.recipesForRound(nextRound);
    final newOrders = <String, dynamic>{};
    final newProgress = <String, dynamic>{};
    var counter = 1;

    for (final entry in playersData.entries) {
      final pId = entry.key as String;
      final pData = entry.value as Map;
      final ring = (pData['ringIndex'] as int?) ?? 0;
      final pOrders = <String, dynamic>{};
      for (var i = 0; i < ordersPerPlayer; i++) {
        final recipe = nextRecipes[_rng.nextInt(nextRecipes.length)];
        pOrders['ord_r${nextRound}_${counter++}'] = {
          'recipeId': recipe.id,
          'status': 'pending',
        };
      }
      newOrders[pId] = pOrders;
      newProgress['$ring'] = 0;
    }

    await _db.ref().update({
      'rooms/$code/round/number': nextRound,
      'rooms/$code/round/stationAssignment': {
        for (final e in newAssignment.entries) '${e.key}': e.value?.name ?? '',
      },
      'rooms/$code/round/progress': newProgress,
      'rooms/$code/orders': newOrders,
    });

    // Sinh nguyên liệu mới cho round mới
    for (var ring = 0; ring < totalPlayers; ring++) {
      final itemId =
          'r${nextRound}_${ring}_${DateTime.now().microsecondsSinceEpoch}';
      final ingredients = ['orange', 'lemon', 'strawberry', 'ice'];
      await _inboxRef(code, ring).child(itemId).set({
        'type': 'ingredient',
        'itemId': ingredients[_rng.nextInt(ingredients.length)],
        'fromRingIndex': ring,
      });
    }
  }

  /// Kết thúc trận — ghi results và set status = ended.
  /// Idempotent: không ghi lại nếu đã ended.
  /// Gọi từ BartenderController khi timer hết.
  Future<void> endMatch(String code) async {
    // Dùng transaction để chỉ 1 client thực sự ghi ended
    bool shouldWrite = false;
    await _roomRef(code).child('status').runTransaction((currentData) {
      if (currentData == 'playing') {
        shouldWrite = true;
        return Transaction.success('ended');
      }
      return Transaction.abort(); // đã ended hoặc không đang play
    });

    if (!shouldWrite) return;

    final roomSnap = await _roomRef(code).get();
    if (!roomSnap.exists) return;
    final roomData = roomSnap.value as Map;
    final playersData = (roomData['players'] as Map?) ?? {};
    final timerData = (roomData['timer'] as Map?) ?? {};
    final startedAt = (timerData['startedAt'] as int?) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final survivalSec = ((now - startedAt) / 1000).round().clamp(
          0,
          BartenderConfig.initialTimerSeconds * 10,
        );

    final ranking = playersData.entries.map((e) {
      final d = e.value as Map;
      return {
        'playerId': e.key,
        'completedOrders': (d['completedOrders'] as int?) ?? 0,
      };
    }).toList()
      ..sort((a, b) =>
          (b['completedOrders'] as int).compareTo(a['completedOrders'] as int));

    final totalOrders = ranking.fold<int>(
      0,
      (sum, r) => sum + (r['completedOrders'] as int),
    );

    await _db.ref('rooms/$code/results').set({
      'totalSurvivalSeconds': survivalSec,
      'totalTeamOrders': totalOrders,
      'ranking': ranking,
    });
  }

  // ─── Parsing ────────────────────────────────────────────────────────────────

  Room _parseRoom(String code, Map data) {
    final statusStr = (data['status'] as String?) ?? 'lobby';
    final status = RoomStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => RoomStatus.lobby,
    );

    final playersData = (data['players'] as Map?) ?? {};
    final players = _parsePlayersFromMap(playersData);

    // Inbox
    final inboxData = (data['inbox'] as Map?) ?? {};
    final inbox = <int, List<GameItem>>{};
    for (final entry in inboxData.entries) {
      final ring = int.tryParse(entry.key.toString()) ?? 0;
      final itemsMap = (entry.value as Map?) ?? {};
      inbox[ring] = itemsMap.entries.map((e) {
        final d = e.value as Map;
        return GameItem(
          id: e.key.toString(),
          type: (d['type'] as String?) == 'product'
              ? GameItemType.product
              : GameItemType.ingredient,
          itemId: (d['itemId'] as String?) ?? '',
          fromRingIndex: (d['fromRingIndex'] as int?) ?? 0,
        );
      }).toList();
    }

    // Timer
    MatchTimer? timer;
    final timerData = data['timer'] as Map?;
    if (timerData != null) {
      timer = MatchTimer(
        endTime: (timerData['endTime'] as int?) ?? 0,
        startedAt: (timerData['startedAt'] as int?) ?? 0,
      );
    }

    // Round
    Round? currentRound;
    final roundData = data['round'] as Map?;
    if (roundData != null) {
      final stationData = (roundData['stationAssignment'] as Map?) ?? {};
      final assignment = <int, StationType?>{};
      for (final e in stationData.entries) {
        final ring = int.tryParse(e.key.toString()) ?? 0;
        final stName = (e.value as String?) ?? '';
        assignment[ring] = StationType.values
            .cast<StationType?>()
            .firstWhere((s) => s?.name == stName, orElse: () => null);
      }

      final ordersData = (data['orders'] as Map?) ?? {};
      final playerOrders = <String, List<Order>>{};
      for (final pEntry in ordersData.entries) {
        final pId = pEntry.key.toString();
        final pOrdersMap = (pEntry.value as Map?) ?? {};
        playerOrders[pId] = pOrdersMap.entries.map((e) {
          final d = e.value as Map;
          return Order(
            id: e.key.toString(),
            recipeId: (d['recipeId'] as String?) ?? '',
            status: (d['status'] as String?) == 'submitted'
                ? OrderStatus.submitted
                : OrderStatus.pending,
          );
        }).toList();
      }

      currentRound = Round(
        number: (roundData['number'] as int?) ?? 1,
        ordersPerPlayer: (roundData['ordersPerPlayer'] as int?) ??
            BartenderConfig.ordersPerPlayer,
        stationAssignment: assignment,
        playerOrders: playerOrders,
      );
    }

    // Results
    MatchResult? results;
    final resultsData = data['results'] as Map?;
    if (resultsData != null) {
      final rankingData = (resultsData['ranking'] as List?) ?? [];
      final ranking = rankingData.map((r) {
        final d = r as Map;
        final pId = (d['playerId'] as String?) ?? '';
        return players[pId] ??
            Player(
              id: pId,
              name: pId,
              ringIndex: 0,
              completedOrders: (d['completedOrders'] as int?) ?? 0,
            );
      }).toList();

      results = MatchResult(
        totalSurvivalSeconds:
            (resultsData['totalSurvivalSeconds'] as int?) ?? 0,
        totalTeamOrders: (resultsData['totalTeamOrders'] as int?) ?? 0,
        ranking: ranking,
      );
    }

    return Room(
      code: code,
      status: status,
      players: players,
      inbox: inbox,
      timer: timer,
      currentRound: currentRound,
      results: results,
    );
  }

  Map<String, Player> _parsePlayersFromMap(Map data) {
    final result = <String, Player>{};
    for (final entry in data.entries) {
      final id = entry.key.toString();
      final d = entry.value as Map;
      result[id] = Player(
        id: id,
        name: (d['name'] as String?) ?? id,
        ringIndex: (d['ringIndex'] as int?) ?? 0,
        connected: (d['connected'] as bool?) ?? true,
        completedOrders: (d['completedOrders'] as int?) ?? 0,
      );
    }
    return result;
  }

  /// Logic chế biến — phải đồng bộ với FakeRoomRepository.
  String _processItem(String itemId, StationType station) {
    switch (station) {
      case StationType.juicer:
        if (itemId == 'orange') return 'orange_juice';
        if (itemId == 'lemon') return 'lemonade';
      case StationType.cuttingBoard:
        if (itemId == 'strawberry') return 'cut_strawberry';
      case StationType.blender:
        if (itemId == 'cut_strawberry' || itemId == 'strawberry') {
          return 'strawberry_smoothie';
        }
      case StationType.shaker:
        if (itemId == 'orange_juice' ||
            itemId == 'lemonade' ||
            itemId == 'ice') {
          return 'citrus_cocktail';
        }
    }
    return '${itemId}_processed';
  }

  @override
  void dispose() {
    for (final sub in _subs.values) {
      sub.cancel();
    }
    _subs.clear();
    for (final ctrl in _streamControllers.values) {
      ctrl.close();
    }
    _streamControllers.clear();
  }
}
