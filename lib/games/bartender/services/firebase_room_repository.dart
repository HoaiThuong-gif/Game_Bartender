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
/// Ghi chú thiết kế:
/// - Tất cả write operation dùng `set` hoặc `update` không dùng
///   `push` — key được kiểm soát bởi client để dễ debug.
/// - Không write đồng hồ đếm ngược lên DB mỗi giây (xem API.md).
/// - `round/progress` là nguồn sự thật cho round completion (xem API.md).
/// - Để xoá toàn bộ Firebase: xoá file này + 3 dòng trong pubspec.yaml
///   + google-services.json + firebase_options.dart. Code game không đổi.
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

  /// UID của người chơi trên máy này (được gán sau signInAnonymously).
  String? _myUid;

  /// Stream subscription lắng nghe thay đổi phòng từ RTDB.
  StreamSubscription<DatabaseEvent>? _roomSubscription;

  /// Stream controller để phát Room objects đã được parse ra ngoài.
  final Map<String, StreamController<Room>> _streamControllers = {};

  // ─── Auth ───────────────────────────────────────────────────────────────────

  /// Đảm bảo client đã đăng nhập ẩn danh.
  /// Gọi trước khi bất kỳ thao tác nào cần uid.
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

  DatabaseReference _roomRef(String code) =>
      _db.ref('rooms/$code');

  DatabaseReference _inboxRef(String code, int ring) =>
      _db.ref('rooms/$code/inbox/$ring');

  DatabaseReference _roundRef(String code) =>
      _db.ref('rooms/$code/round');

  DatabaseReference _timerRef(String code) =>
      _db.ref('rooms/$code/timer');

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

    // Ghi thông tin host vào players/
    final players = <String, Player>{
      uid: Player(
        id: uid,
        name: hostPlayerName.trim().isEmpty ? 'Bạn' : hostPlayerName,
        ringIndex: 0,
        connected: true,
        completedOrders: 0,
      ),
    };

    // Khởi tạo inbox rỗng cho tất cả vị trí (kể cả bot chưa join)
    final inbox = <int, List<GameItem>>{
      for (var i = 0; i < totalPlayers; i++) i: const [],
    };

    final room = Room(
      code: code,
      status: RoomStatus.lobby,
      players: players,
      inbox: inbox,
    );

    // Ghi lên RTDB
    await _roomRef(code).set({
      'createdAt': now,
      'status': 'lobby',
      'totalPlayers': totalPlayers, // lưu để client khác biết kích thước ring
      'players': {
        uid: {
          'name': players[uid]!.name,
          'ringIndex': 0,
          'connected': true,
          'completedOrders': 0,
        },
      },
    });

    return room;
  }

  @override
  Future<Room> joinRoom({
    required String code,
    required String playerName,
  }) async {
    final uid = await _ensureAuth();

    // Đọc danh sách players hiện tại để tìm ringIndex kế tiếp
    final snap = await _db.ref('rooms/$code/players').get();
    if (!snap.exists) throw StateError('Phòng $code không tồn tại');

    final existingPlayers = _parsePlayersFromMap(
      (snap.value as Map?) ?? {},
    );
    final newIndex = existingPlayers.length;

    // Thêm player mới
    await _db.ref('rooms/$code/players/$uid').set({
      'name': playerName,
      'ringIndex': newIndex,
      'connected': true,
      'completedOrders': 0,
    });

    // Đọc lại trạng thái phòng mới nhất
    final roomSnap = await _roomRef(code).get();
    return _parseRoom(code, roomSnap.value as Map);
  }

  @override
  Future<void> leaveRoom({
    required String code,
    required String playerId,
  }) async {
    // Giữ slot, chỉ set connected = false (API.md: "slot not removed")
    await _db.ref('rooms/$code/players/$playerId/connected').set(false);
  }

  @override
  Future<void> startMatch({required String code}) async {
    final roomSnap = await _roomRef(code).get();
    if (!roomSnap.exists) return;

    final roomData = roomSnap.value as Map;
    final playersData = (roomData['players'] as Map?) ?? {};
    final totalPlayers = (roomData['totalPlayers'] as int?) ?? playersData.length;

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
      final playerOrders = <String, dynamic>{};
      for (var i = 0; i < BartenderConfig.ordersPerPlayer; i++) {
        final recipe = recipes[_rng.nextInt(recipes.length)];
        final orderId = 'ord_${orderCounter++}';
        playerOrders[orderId] = {
          'recipeId': recipe.id,
          'status': 'pending',
        };
      }
      ordersData[playerId] = playerOrders;
      progressData['${(entry.value as Map)['ringIndex']}'] = 0;
    }

    // Tạo timer 60s
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final endTime = nowMs + BartenderConfig.initialTimerSeconds * 1000;

    // Ghi tất cả một lúc bằng multi-path update (atomic hơn set tuần tự)
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
          for (final e in assignment.entries)
            '${e.key}': e.value?.name ?? '',
        },
        'progress': progressData,
      },
      'orders': ordersData,
    });

    // Sinh nguyên liệu ban đầu vào inbox của mỗi người chơi
    for (var ring = 0; ring < totalPlayers; ring++) {
      final itemId = 'init_${ring}_${DateTime.now().microsecondsSinceEpoch}';
      final ingredient = _rng.nextInt(4); // đơn giản, tránh import enum
      await _inboxRef(code, ring).child(itemId).set({
        'type': 'ingredient',
        'itemId': ['orange', 'lemon', 'strawberry', 'ice'][ingredient],
        'fromRingIndex': ring,
      });
    }
  }

  @override
  Stream<Room> watchRoom(String code) {
    final existing = _streamControllers[code];
    if (existing != null && !existing.isClosed) {
      return existing.stream;
    }

    final ctrl = StreamController<Room>.broadcast(
      onCancel: () {
        _roomSubscription?.cancel();
        _roomSubscription = null;
      },
    );
    _streamControllers[code] = ctrl;

    _roomSubscription?.cancel();
    _roomSubscription = _roomRef(code).onValue.listen(
      (event) {
        if (!event.snapshot.exists || ctrl.isClosed) return;
        try {
          final room = _parseRoom(code, event.snapshot.value as Map);
          ctrl.add(room);
        } catch (e) {
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
    // Xoá item khỏi inbox người gửi
    await _inboxRef(code, fromRingIndex).child(item.id).remove();

    // Thêm item vào inbox người nhận (với fromRingIndex mới)
    await _inboxRef(code, toRingIndex).child(item.id).set({
      'type': item.type.name,
      'itemId': item.itemId,
      'fromRingIndex': fromRingIndex,
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
    // Đọc item hiện tại
    final snap = await _inboxRef(code, ringIndex).child(itemId).get();
    if (!snap.exists) throw ArgumentError('Item $itemId không tồn tại');

    final data = snap.value as Map;
    final currentItemId = data['itemId'] as String;

    // Tính kết quả chế biến (logic đồng bộ với FakeRoomRepository)
    final resultItemId = _processItem(currentItemId, station);

    // Ghi lại item đã chế biến
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
    // Đọc thông tin người chơi (cần ringIndex)
    final playerSnap = await _db.ref('rooms/$code/players/$playerId').get();
    if (!playerSnap.exists) return;

    final playerData = playerSnap.value as Map;
    final ringIndex = playerData['ringIndex'] as int;

    // Đọc progress hiện tại
    final progressSnap = await _progressRef(code).child('$ringIndex').get();
    final currentProgress = (progressSnap.value as int?) ?? 0;

    // Đọc endTime hiện tại để cộng bonus
    final timerSnap = await _timerRef(code).get();
    final timerData = timerSnap.value as Map;
    final currentEndTime = timerData['endTime'] as int;

    // Ghi tất cả trong một multi-path update
    await _db.ref().update({
      // Cập nhật trạng thái đơn
      'rooms/$code/orders/$playerId/$orderId/status': 'submitted',
      // Cộng progress
      'rooms/$code/round/progress/$ringIndex': currentProgress + 1,
      // Cộng completedOrders cá nhân
      'rooms/$code/players/$playerId/completedOrders':
          ((playerData['completedOrders'] as int?) ?? 0) + 1,
      // Cộng +5s vào timer
      'rooms/$code/timer/endTime':
          currentEndTime + BartenderConfig.orderCompletionBonusSeconds * 1000,
    });

    // Xoá item đã nộp khỏi inbox
    await _inboxRef(code, ringIndex).child(productId).remove();

    // Kiểm tra round hoàn thành: đọc tất cả progress
    await _checkRoundCompletion(code);
  }

  /// Kiểm tra xem tất cả người chơi đã hoàn thành đủ đơn của round chưa.
  /// Nếu đúng, tạo round mới (hoặc kết thúc trận nếu hết giờ).
  Future<void> _checkRoundCompletion(String code) async {
    final roundSnap = await _roundRef(code).get();
    if (!roundSnap.exists) return;

    final roundData = roundSnap.value as Map;
    final ordersPerPlayer = (roundData['ordersPerPlayer'] as int?) ??
        BartenderConfig.ordersPerPlayer;
    final progressData = (roundData['progress'] as Map?) ?? {};

    // Lấy số người chơi (connected)
    final roomSnap = await _roomRef(code).get();
    final roomData = roomSnap.value as Map;
    final playersData = (roomData['players'] as Map?) ?? {};
    final totalPlayers =
        (roomData['totalPlayers'] as int?) ?? playersData.length;

    // Kiểm tra từng ring đã đạt ordersPerPlayer chưa
    bool allDone = true;
    for (var i = 0; i < totalPlayers; i++) {
      final progress = (progressData['$i'] as int?) ?? 0;
      if (progress < ordersPerPlayer) {
        allDone = false;
        break;
      }
    }

    if (!allDone) return;

    // Tất cả done → tạo round mới
    final currentRoundNumber = (roundData['number'] as int?) ?? 1;
    final nextRound = currentRoundNumber + 1;
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
      final ring = pData['ringIndex'] as int;
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
        for (final e in newAssignment.entries)
          '${e.key}': e.value?.name ?? '',
      },
      'rooms/$code/round/progress': newProgress,
      'rooms/$code/orders': newOrders,
    });
  }

  /// Kết thúc trận — ghi results và set status = ended.
  /// Thường được gọi từ client nào phát hiện timer hết (race-safe vì RTDB
  /// transaction sẽ bảo vệ, nhưng với MVP chấp nhận write tuần tự).
  Future<void> endMatch(String code) async {
    final roomSnap = await _roomRef(code).get();
    if (!roomSnap.exists) return;

    final roomData = roomSnap.value as Map;
    final status = roomData['status'] as String?;
    if (status == 'ended') return; // đã kết thúc rồi

    final playersData = (roomData['players'] as Map?) ?? {};
    final timerData = (roomData['timer'] as Map?) ?? {};
    final startedAt = (timerData['startedAt'] as int?) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final survivalSec = ((now - startedAt) / 1000).round();

    // Build ranking
    final ranking = playersData.entries.map((e) {
      final d = e.value as Map;
      return {
        'playerId': e.key,
        'completedOrders': (d['completedOrders'] as int?) ?? 0,
      };
    }).toList()
      ..sort((a, b) => (b['completedOrders'] as int)
          .compareTo(a['completedOrders'] as int));

    final totalOrders = ranking.fold<int>(
      0,
      (sum, r) => sum + (r['completedOrders'] as int),
    );

    await _db.ref().update({
      'rooms/$code/status': 'ended',
      'rooms/$code/results': {
        'totalSurvivalSeconds': survivalSec,
        'totalTeamOrders': totalOrders,
        'ranking': ranking,
      },
    });
  }

  // ─── Parsing ────────────────────────────────────────────────────────────────

  /// Parse dữ liệu thô từ RTDB thành [Room] model.
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
    final timerData = (data['timer'] as Map?);
    if (timerData != null) {
      timer = MatchTimer(
        endTime: (timerData['endTime'] as int?) ?? 0,
        startedAt: (timerData['startedAt'] as int?) ?? 0,
      );
    }

    // Round
    Round? currentRound;
    final roundData = (data['round'] as Map?);
    if (roundData != null) {
      final stationData = (roundData['stationAssignment'] as Map?) ?? {};
      final assignment = <int, StationType?>{};
      for (final e in stationData.entries) {
        final ring = int.tryParse(e.key.toString()) ?? 0;
        final stName = (e.value as String?) ?? '';
        assignment[ring] = StationType.values.cast<StationType?>().firstWhere(
              (s) => s?.name == stName,
              orElse: () => null,
            );
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
    final resultsData = (data['results'] as Map?);
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

  /// Tính kết quả chế biến — phải đồng bộ với FakeRoomRepository.
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
    _roomSubscription?.cancel();
    for (final ctrl in _streamControllers.values) {
      ctrl.close();
    }
    _streamControllers.clear();
  }
}
