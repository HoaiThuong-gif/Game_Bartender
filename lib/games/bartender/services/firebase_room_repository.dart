import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:nhom_bar/games/bartender/models/recipe_pool.dart';

import '../bartender_config.dart';
import '../models/game_item.dart';
import '../models/match_result.dart';
import '../models/match_timer.dart';
import '../models/order.dart';
import '../models/player.dart';
import '../models/room.dart';
import '../models/round.dart';
import '../models/round_setup.dart';
import '../models/station.dart';
import '../models/processing_rules.dart';
import 'room_repository.dart';
import 'rtdb_utils.dart';

/// Gốc đường dẫn của tất cả node Bartender trên RTDB (D18).
///
/// Bartender dùng chung dự án Firebase `nhom-bar` với Rubik.
/// Mọi đường dẫn đều bắt đầu bằng hằng số này — KHÔNG dùng 'rooms/' trực tiếp.
const String _roomsRoot = 'bartender/rooms';

/// Triển khai [RoomRepository] trên Firebase Realtime Database.
///
/// Tuân theo schema trong API.md (bartender/rooms/{code}/... theo D18).
/// Dùng xác thực ẩn danh (FirebaseAuth.signInAnonymously) để mỗi
/// client có uid duy nhất, phục vụ làm playerId trong RTDB.
///
/// Thiết kế race-safe (multi-device) theo D17:
/// - joinRoom dùng RTDB runTransaction để tránh ringIndex trùng.
/// - submitOrder dùng transaction trên order status + multi-path update.
/// - _tryAdvanceRound dùng transaction trên round node.
/// - endMatch dùng transaction trên results (ghi results trước, status sau).
///
/// Để xoá Firebase: xoá file này + 3 dòng pubspec.yaml + firebase_options.dart
/// + google-services.json. Code game (controller/widgets/screens) không đổi.
class FirebaseRoomRepository implements RoomRepository {
  FirebaseRoomRepository({
    FirebaseDatabase? database,
    FirebaseAuth? auth,
    Random? rng,
  }) : _db =
           database ??
           (() {
             // Kiểm tra URL hợp lệ trước khi tạo instance
             final url = BartenderConfig.databaseUrl;
             if (url.isEmpty) {
               throw StateError(
                 'BartenderConfig.databaseUrl rỗng — '
                 'chạy với --dart-define=DATABASE_URL=<url> '
                 'hoặc kiểm tra BartenderConfig.databaseUrl.',
               );
             }
             return FirebaseDatabase.instanceFor(
               app: Firebase.app(),
               databaseURL: url,
             );
           })(),
       _auth = auth ?? FirebaseAuth.instance,
       _rng = rng ?? Random();

  final FirebaseDatabase _db;
  final FirebaseAuth _auth;
  final Random _rng;

  /// UID của người chơi trên máy này.
  String? _myUid;

  /// Cache serverTimeOffset từ .info/serverTimeOffset.
  int _serverOffsetMs = 0;
  bool _offsetFetched = false;

  /// Stream subscriptions theo từng room code.
  final Map<String, StreamSubscription<DatabaseEvent>> _subs = {};

  /// Stream controllers theo từng room code.
  final Map<String, StreamController<Room>> _streamControllers = {};

  /// Timer spawn nguyên liệu định kỳ theo từng room code.
  final Map<String, Timer> _spawnTimers = {};

  /// Cache Room mới nhất theo từng room code (dùng cho timer spawn).
  final Map<String, Room> _latestRooms = {};

  @override
  String get localPlayerId {
    final uid = _myUid;
    if (uid == null) {
      throw StateError(
        'localPlayerId chưa có — phải gọi createRoom hoặc joinRoom trước.',
      );
    }
    return uid;
  }

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

  // ─── Server time offset ─────────────────────────────────────────────────────

  /// Lấy và cache serverTimeOffset từ Firebase .info/connected
  /// (ARCHITECTURE.md: dùng để tính endTime chính xác).
  Future<int> _getServerOffsetMs() async {
    if (_offsetFetched) return _serverOffsetMs;
    try {
      final snap = await _db.ref('.info/serverTimeOffset').get();
      if (snap.exists) {
        _serverOffsetMs = ((snap.value as num?) ?? 0).round();
      }
    } catch (_) {
      // Lỗi thì dùng 0 — vẫn chạy được nhưng không sync chính xác
    }
    _offsetFetched = true;
    return _serverOffsetMs;
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  /// Reference đến node phòng. Mọi đường dẫn đều qua helper này.
  DatabaseReference _roomRef(String code) => _db.ref('$_roomsRoot/$code');

  /// Reference đến inbox của một ringIndex.
  DatabaseReference _inboxRef(String code, int ring) =>
      _db.ref('$_roomsRoot/$code/inbox/$ring');

  /// Reference đến node round.
  DatabaseReference _roundRef(String code) =>
      _db.ref('$_roomsRoot/$code/round');

  // ─── RoomRepository impl ────────────────────────────────────────────────────

  @override
  Future<Room> createRoom({
    required String hostPlayerName,
    int totalPlayers = 3,
    // totalPlayers chỉ dùng cho Fake (số bot). Không ghi lên Firebase (D13).
  }) async {
    final uid = await _ensureAuth();
    final hostName = hostPlayerName.trim().isEmpty
        ? 'Bạn'
        : hostPlayerName.trim();

    String code = '';
    bool created = false;
    const maxAttempts = 20; // Giới hạn số lần thử tạo mã phòng

    // Dùng transaction để không ghi đè phòng đang tồn tại (thử mã khác nếu trùng)
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      code = (_rng.nextInt(9000) + 1000).toString();
      final tr = await _roomRef(code).runTransaction((currentData) {
        if (currentData != null) {
          return Transaction.abort(); // Trùng mã
        }
        return Transaction.success({
          'createdAt': ServerValue.timestamp, // Dùng server timestamp (Bước 6)
          'status': 'lobby',
          // Không ghi totalPlayers lên Firebase (D13)
          'players': {
            uid: {
              'name': hostName,
              'ringIndex': 0,
              'connected': true,
              'completedOrders': 0,
              'readyInLobby': true,
            },
          },
        });
      });
      if (tr.committed) {
        created = true;
        break;
      }
    }
    if (!created) {
      throw StateError(
        'Không thể tạo phòng sau $maxAttempts lần thử — tất cả mã đều đã được dùng.',
      );
    }

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
      inbox: const {},
    );
  }

  @override
  Future<Room> joinRoom({
    required String code,
    required String playerName,
  }) async {
    final uid = await _ensureAuth();
    final name = playerName.trim().isEmpty ? 'Khách' : playerName.trim();

    // Kiểm tra tồn tại và trạng thái
    final roomSnap = await _roomRef(code).get();
    if (!roomSnap.exists) {
      throw StateError('Phòng #$code không tồn tại.');
    }
    final roomData = asMap(roomSnap.value);
    if (roomData['status'] != 'lobby') {
      throw StateError(
        'Phòng #$code đã bắt đầu hoặc kết thúc, không thể tham gia.',
      );
    }

    // Dùng transaction để tránh race condition ringIndex trùng
    int assignedRing = -1;

    final tr = await _db.ref('$_roomsRoot/$code/players').runTransaction((
      currentData,
    ) {
      final players = asMap(currentData);

      // Nếu player đã tồn tại (reconnect), giữ nguyên ringIndex
      if (players.containsKey(uid)) {
        players[uid] = {...asMap(players[uid]), 'connected': true};
        assignedRing =
            asMap(players[uid])['ringIndex'] as int? ?? players.length - 1;
        return Transaction.success(players);
      }

      // Check maxPlayers
      if (players.length >= BartenderConfig.maxPlayers) {
        return Transaction.abort();
      }

      // Tìm ringIndex lớn nhất hiện tại
      int maxRing = -1;
      for (final p in players.values) {
        final r = asMap(p)['ringIndex'] as int? ?? -1;
        if (r > maxRing) maxRing = r;
      }
      assignedRing = maxRing + 1;

      players[uid] = {
        'name': name,
        'ringIndex': assignedRing,
        'connected': true,
        'completedOrders': 0,
        'readyInLobby': true,
      };
      return Transaction.success(players);
    });

    if (!tr.committed) {
      final players = asMap(tr.snapshot.value);
      if (!players.containsKey(uid) &&
          players.length >= BartenderConfig.maxPlayers) {
        throw StateError(
          'Phòng #$code đã đầy (${BartenderConfig.maxPlayers} người).',
        );
      }
      throw StateError('Không thể tham gia phòng #$code, vui lòng thử lại.');
    }

    // Gán onDisconnect để tự set connected=false nếu mất kết nối (D14)
    await _db.ref('$_roomsRoot/$code/players/$uid').onDisconnect().update({
      'connected': false,
    });

    // Đọc lại room state mới nhất sau transaction
    final snap = await _roomRef(code).get();
    if (!snap.exists) throw StateError('Phòng $code không tồn tại');
    return _parseRoom(code, asMap(snap.value));
  }

  @override
  Future<void> returnToLobby({
    required String code,
    required String playerId,
  }) async {
    await _db
        .ref('$_roomsRoot/$code/players/$playerId/readyInLobby')
        .set(true);
  }

  @override
  Future<void> leaveRoom({
    required String code,
    required String playerId,
  }) async {
    // D14: lobby → xoá hẳn node; playing → chỉ set connected=false
    final statusSnap = await _db.ref('$_roomsRoot/$code/status').get();
    final status = (statusSnap.value as String?) ?? 'lobby';

    if (status == 'lobby') {
      // Xoá hẳn node người chơi khỏi phòng
      await _db.ref('$_roomsRoot/$code/players/$playerId').remove();
    } else {
      // Đang chơi: chỉ đánh dấu not connected, để vẫn giữ slot cho round này
      await _db.ref('$_roomsRoot/$code/players/$playerId/connected').set(false);
    }
    // Huỷ onDisconnect (không cần thiết nữa vì đã rời tự nguyện)
    await _db
        .ref('$_roomsRoot/$code/players/$playerId')
        .onDisconnect()
        .cancel();
    _stopSpawnTimer(code);
    _latestRooms.remove(code);
  }

  @override
  Future<void> startMatch({required String code}) async {
    // Đọc room, guard lobby hoặc ended
    final roomSnap = await _roomRef(code).get();
    if (!roomSnap.exists) return;
    final roomData = asMap(roomSnap.value);
    final currentStatus = roomData['status'] as String?;
    if (currentStatus != 'lobby' && currentStatus != 'ended') return;

    final playersData = asMap(roomData['players']);

    // Chỉ chủ phòng (ringIndex == 0) mới có quyền bắt đầu trận đấu
    final uid = _myUid ?? _auth.currentUser?.uid;
    if (uid != null && playersData.containsKey(uid)) {
      final callerRing = asMap(playersData[uid])['ringIndex'] as int? ?? -1;
      if (callerRing != 0) {
        debugPrint(
          'startMatch bị từ chối: caller $uid có ringIndex $callerRing != 0 (không phải host).',
        );
        return;
      }
    }

    // Chỉ tính người connected (D13: ring = số người connected khi bắt đầu)
    final connectedPlayers = {
      for (final e in playersData.entries)
        if ((asMap(e.value)['connected'] as bool?) != false) e.key: e.value,
    };
    if (connectedPlayers.length < 2) return; // Chưa đủ người

    // Kiểm tra tất cả người chơi connected đã sẵn sàng trong phòng chờ chưa
    final allReady = connectedPlayers.values.every(
      (p) => (asMap(p)['readyInLobby'] as bool?) ?? true,
    );
    if (!allReady) {
      debugPrint('startMatch bị từ chối: Chưa đủ người chơi quay lại phòng.');
      return;
    }

    // Dồn ringIndex về 0..k-1 (D14: compact ring)
    final compacted = compactRing(connectedPlayers);
    final playerIds = compacted.keys.toList();

    // Dùng RoundSetup.generate để phân trạm và tạo đơn (D15)
    final setup = RoundSetup.generate(
      playerIds: playerIds,
      roundNumber: 1,
      rng: _rng,
    );

    // Tính server offset để tính endTime chính xác (Bước 6)
    final offset = await _getServerOffsetMs();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final correctedNow = nowMs + offset;
    final endTime = correctedNow + BartenderConfig.initialTimerSeconds * 1000;

    // Tạo orders data
    final ordersData = <String, dynamic>{};
    var orderCounter = 1;
    for (final entry in compacted.entries) {
      final playerId = entry.key;
      final playerOrders = <String, dynamic>{};
      for (var i = 0; i < BartenderConfig.ordersPerPlayer; i++) {
        final recipe =
            setup.feasibleRecipes[_rng.nextInt(setup.feasibleRecipes.length)];
        playerOrders['ord_r1_${orderCounter++}'] = {
          'recipeId': recipe.id,
          'status': 'pending',
        };
      }
      ordersData[playerId] = playerOrders;
    }

    // Progress: key là ringIndex (String) theo API.md
    final progressData = <String, dynamic>{
      for (final e in compacted.entries)
        '${asMap(e.value)['ringIndex'] as int? ?? 0}': 0,
    };

    // Cập nhật players với ringIndex đã compact
    final playersUpdate = <String, dynamic>{};
    for (final e in compacted.entries) {
      playersUpdate[e.key] = asMap(e.value);
    }

    // Transaction trên status để chuyển lobby/ended → playing chỉ một lần (D17)
    bool started = false;
    await _roomRef(code).child('status').runTransaction((currentData) {
      if (currentData != 'lobby' && currentData != 'ended') {
        return Transaction.abort();
      }
      started = true;
      return Transaction.success('playing');
    });

    if (!started) return; // Client khác đã start

    // Multi-path update: players compact + timer + round + orders + reset results (atomic hơn có thể)
    final updates = <String, dynamic>{
      '$_roomsRoot/$code/results': null,
      '$_roomsRoot/$code/timer/startedAt': ServerValue.timestamp,
      '$_roomsRoot/$code/timer/endTime': endTime,
      '$_roomsRoot/$code/round': {
        'number': 1,
        'ordersPerPlayer': BartenderConfig.ordersPerPlayer,
        'stationAssignment': {
          for (final e in setup.stationAssignment.entries)
            '${e.key}': e.value?.name ?? '',
        },
        'progress': progressData,
      },
      '$_roomsRoot/$code/orders': ordersData,
    };

    // Cập nhật ringIndex đã compact, reset completedOrders và readyInLobby cho từng player
    for (final e in compacted.entries) {
      final d = asMap(e.value);
      updates['$_roomsRoot/$code/players/${e.key}/ringIndex'] =
          d['ringIndex'] as int? ?? 0;
      updates['$_roomsRoot/$code/players/${e.key}/completedOrders'] = 0;
      updates['$_roomsRoot/$code/players/${e.key}/readyInLobby'] = false;
    }

    // Xoá người không connected (nếu có) khỏi players
    for (final key in playersData.keys) {
      if (!compacted.containsKey(key)) {
        updates['$_roomsRoot/$code/players/$key'] = null;
      }
    }

    // Nguyên liệu ban đầu cho từng ring, gộp vào CÙNG lần update (D17).
    const ingredients = ['orange', 'lemon', 'strawberry', 'ice'];
    for (var ring = 0; ring < compacted.length; ring++) {
      final itemId = 'init_${ring}_${DateTime.now().microsecondsSinceEpoch}';
      updates['$_roomsRoot/$code/inbox/$ring/$itemId'] = {
        'type': 'ingredient',
        'itemId': ingredients[_rng.nextInt(ingredients.length)],
        'fromRingIndex': ring,
      };
    }

    await _db.ref().update(updates);

    // Gán onDisconnect cho host (để bắt kết nối mất sau khi start)
    if (uid != null) {
      await _db.ref('$_roomsRoot/$code/players/$uid').onDisconnect().update({
        'connected': false,
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
        _stopSpawnTimer(code);
        _latestRooms.remove(code);
        _streamControllers[code]?.close();
        _streamControllers.remove(code);
      },
    );
    _streamControllers[code] = ctrl;

    // Mỗi room có subscription riêng
    _subs[code]?.cancel();
    _subs[code] = _roomRef(code).onValue.listen(
      (event) {
        if (ctrl.isClosed) return;
        if (!event.snapshot.exists) return;
        try {
          final room = _parseRoom(code, asMap(event.snapshot.value));
          _latestRooms[code] = room;
          ctrl.add(room);

          // Quản lý timer spawn nguyên liệu định kỳ (mỗi 3s)
          if (room.status == RoomStatus.playing) {
            _startSpawnTimerIfNeeded(code);
            // Kiểm tra chuyển round khi đang playing (D17: không host)
            _checkAndTryAdvanceRound(room);
          } else {
            _stopSpawnTimer(code);
          }

          // Nếu đang playing mà < 2 connected: kết thúc trận (D14)
          if (room.status == RoomStatus.playing &&
              room.connectedPlayerCount < 2) {
            debugPrint(
              'Bartender: còn ${room.connectedPlayerCount} người — kết thúc trận.',
            );
            // Không await để không block stream
            endMatch(
              code,
            ).catchError((e) => debugPrint('Lỗi endMatch (< 2 connected): $e'));
          }
        } catch (e, st) {
          debugPrint('Lỗi parse room $code: $e\n$st');
        }
      },
      onError: (Object e) {
        if (!ctrl.isClosed) ctrl.addError(e);
      },
    );

    return ctrl.stream;
  }

  /// Khởi động timer spawn nguyên liệu mỗi 3s nếu chưa chạy.
  void _startSpawnTimerIfNeeded(String code) {
    if (_spawnTimers.containsKey(code)) return;

    _spawnTimers[code] = Timer.periodic(
      const Duration(seconds: BartenderConfig.ingredientSpawnIntervalSeconds),
      (_) => _spawnIngredientForMyRing(code),
    );
  }

  /// Dừng timer spawn nguyên liệu.
  void _stopSpawnTimer(String code) {
    _spawnTimers[code]?.cancel();
    _spawnTimers.remove(code);
  }

  /// Cấp nguyên liệu ngẫu nhiên cho khay của người chơi trên máy này.
  ///
  /// Mỗi máy chỉ ghi vào khay của chính mình (inbox/$myRing), đảm bảo không race condition
  /// và không phụ thuộc vào máy khác. Chỉ cấp nếu khay chưa đầy (< 5 món).
  Future<void> _spawnIngredientForMyRing(String code) async {
    final room = _latestRooms[code];
    if (room == null || room.status != RoomStatus.playing) return;

    final uid = _myUid ?? _auth.currentUser?.uid;
    if (uid == null) return;
    final me = room.players[uid];
    if (me == null || !me.connected) return;

    final myRing = me.ringIndex;
    final currentItems = room.inbox[myRing] ?? const [];
    if (currentItems.length >= 5) return;

    const ingredients = ['orange', 'lemon', 'strawberry', 'ice'];
    final chosen = ingredients[_rng.nextInt(ingredients.length)];
    final itemId = 'spw_${myRing}_${DateTime.now().microsecondsSinceEpoch}';

    try {
      await _inboxRef(code, myRing).child(itemId).set({
        'type': 'ingredient',
        'itemId': chosen,
        'fromRingIndex': myRing,
      });
    } catch (e) {
      debugPrint('Lỗi spawn ingredient cho ring $myRing: $e');
    }
  }

  /// Kiểm tra và thử chuyển round nếu tất cả người connected đã hoàn thành đơn.
  /// D17: bất kỳ client nào cũng có thể trigger — transaction bảo vệ race condition.
  void _checkAndTryAdvanceRound(Room room) {
    final round = room.currentRound;
    if (round == null) return;

    // Tìm các player connected
    final connected = room.players.values.where((p) => p.connected).toList();
    if (connected.isEmpty) return;

    // Kiểm tra tất cả connected đã đạt ordersPerPlayer chưa
    // Dùng round/progress từ room đã parse
    // round.playerOrders không có progress — xem API.md: progress/{ringIndex}
    // Ta dùng completedOrders của player trong round (round counter reset per round)
    // Thực ra phải đọc progress từ Firebase — nhưng ta có thể estimate từ orderOrders
    // Cách đúng: đọc round/progress trực tiếp, hoặc dựa vào completedOrders
    // Ở đây ta check dựa vào player orders (submitted count per round)
    final bool allDone = connected.every((p) {
      final orders = round.playerOrders[p.id];
      if (orders == null || orders.isEmpty) return true;
      final submitted = orders.where((o) => o.isCompleted).length;
      return submitted >= round.ordersPerPlayer;
    });

    if (!allDone) return;

    // Không await — bắn và quên, bắt lỗi
    _tryAdvanceRound(
      room.code,
      round.number,
      connected,
    ).catchError((e) => debugPrint('Lỗi _tryAdvanceRound: $e'));
  }

  /// Thử chuyển sang round tiếp theo bằng transaction trên round node.
  /// Chỉ client thắng transaction (committed == true) mới thực sự ghi dữ liệu mới.
  Future<void> _tryAdvanceRound(
    String code,
    int observedRoundNumber,
    List<Player> connectedPlayers,
  ) async {
    final nextRound = observedRoundNumber + 1;

    // Compact ring: loại người disconnect, dồn ringIndex về 0..k-1
    final aliveIds = connectedPlayers.map((p) => p.id).toList();

    // Transaction trên round node (D17)
    TransactionResult? tr;
    try {
      tr = await _roundRef(code).runTransaction((currentData) {
        if (currentData == null) return Transaction.abort();
        final roundData = asMap(currentData);
        final currentNumber =
            (roundData['number'] as int?) ?? observedRoundNumber;
        if (currentNumber != observedRoundNumber) {
          return Transaction.abort(); // Đã advance trước đó
        }

        // Chỉ cho chuyển round khi MỌI người đang connected đã đủ đơn.
        // progress được lưu theo ringIndex hiện tại (trước khi dồn ring).
        final progress = asMap(roundData['progress']);
        final needed =
            (roundData['ordersPerPlayer'] as num?)?.toInt() ??
            BartenderConfig.ordersPerPlayer;
        final allDone = connectedPlayers.every((p) {
          final done = (progress['${p.ringIndex}'] as num?)?.toInt() ?? 0;
          return done >= needed;
        });
        if (!allDone) return Transaction.abort();

        // Tạo round mới (RoundSetup.generate là hàm thuần)
        final setup = RoundSetup.generate(
          playerIds: aliveIds,
          roundNumber: nextRound,
          rng: _rng,
        );

        final newProgress = <String, dynamic>{
          for (var i = 0; i < aliveIds.length; i++) '$i': 0,
        };

        return Transaction.success({
          'number': nextRound,
          'ordersPerPlayer': BartenderConfig.ordersPerPlayer,
          'stationAssignment': {
            for (final e in setup.stationAssignment.entries)
              '${e.key}': e.value?.name ?? '',
          },
          'progress': newProgress,
        });
      });
    } catch (e) {
      debugPrint('Transaction round advance thất bại: $e');
      return;
    }

    if (!tr.committed) return; // Thua race

    // Chỉ client thắng tiếp tục ghi orders, players compact, inbox
    final roundData = asMap(tr.snapshot.value);
    // Lấy stationAssignment từ roundData vừa commit
    final stationData = asMap(roundData['stationAssignment']);
    final newAssignment = <int, StationType?>{};
    for (final e in stationData.entries) {
      final ring = int.tryParse(e.key) ?? 0;
      final stName = (e.value as String?) ?? '';
      newAssignment[ring] = StationType.values.cast<StationType?>().firstWhere(
        (s) => s?.name == stName,
        orElse: () => null,
      );
    }

    final feasible = RoundSetup.feasibleFor(
      assignment: newAssignment,
      roundNumber: nextRound,
    );
    if (feasible.isEmpty) {
      debugPrint('Bartender: không có công thức khả thi cho round $nextRound');
      return;
    }

    // Tạo orders mới
    final ordersData = <String, dynamic>{};
    var counter = 1;
    for (var i = 0; i < aliveIds.length; i++) {
      final pId = aliveIds[i];
      final pOrders = <String, dynamic>{};
      for (var j = 0; j < BartenderConfig.ordersPerPlayer; j++) {
        final recipe = feasible[_rng.nextInt(feasible.length)];
        pOrders['ord_r${nextRound}_${counter++}'] = {
          'recipeId': recipe.id,
          'status': 'pending',
        };
      }
      ordersData[pId] = pOrders;
    }

    // Multi-path update: compact players (ringIndex mới), orders mới, inbox (sinh 1 nguyên liệu mới)
    final updates = <String, dynamic>{'$_roomsRoot/$code/orders': ordersData};

    // Cập nhật ringIndex cho players còn sống + xoá người đã disconnect
    // Đọc players hiện tại
    final playersSnap = await _db.ref('$_roomsRoot/$code/players').get();
    final currentPlayers = asMap(playersSnap.value);

    for (final e in currentPlayers.entries) {
      if (!aliveIds.contains(e.key)) {
        // Xoá người disconnect
        updates['$_roomsRoot/$code/players/${e.key}'] = null;
      } else {
        // Cập nhật ringIndex mới
        final newRing = aliveIds.indexOf(e.key);
        updates['$_roomsRoot/$code/players/${e.key}/ringIndex'] = newRing;
      }
    }

    // ---- Inbox mới (D14): đồ của người còn lại đi theo họ sang ringIndex mới ----
    final inboxSnap = await _db.ref('$_roomsRoot/$code/inbox').get();
    final oldInbox = asMap(inboxSnap.value); // khoá = ringIndex CŨ

    final newInbox = <String, dynamic>{};
    for (final p in connectedPlayers) {
      final newRing = aliveIds.indexOf(p.id);
      final items = <String, dynamic>{};

      // Đồ cũ của người này đi theo họ.
      final oldItems = asMap(oldInbox['${p.ringIndex}']);
      for (final e in oldItems.entries) {
        final d = asMap(e.value);
        items[e.key] = {
          'type': d['type'],
          'itemId': d['itemId'],
          'fromRingIndex': newRing,
        };
      }

      // Thêm 1 nguyên liệu mới cho mỗi ring.
      const ingredients = ['orange', 'lemon', 'strawberry', 'ice'];
      final newItemId =
          'r${nextRound}_${newRing}_${DateTime.now().microsecondsSinceEpoch}';
      items[newItemId] = {
        'type': 'ingredient',
        'itemId': ingredients[_rng.nextInt(ingredients.length)],
        'fromRingIndex': newRing,
      };

      newInbox['$newRing'] = items;
    }
    // Ghi đè cả node inbox: xoá luôn hòm thư của người bị loại.
    updates['$_roomsRoot/$code/inbox'] = newInbox;

    await _db.ref().update(updates);
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
      '$_roomsRoot/$code/inbox/$fromRingIndex/${item.id}': null, // null = xoá
      '$_roomsRoot/$code/inbox/$toRingIndex/${item.id}': {
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

    final data = asMap(snap.value);
    final currentItemId = data['itemId'] as String;
    final resultItemId = processItem(currentItemId, station);
    if (resultItemId == null) {
      final fromRing = (data['fromRingIndex'] as int?) ?? ringIndex;
      final typeStr = (data['type'] as String?) ?? 'ingredient';
      return GameItem(
        id: itemId,
        type: typeStr == 'product'
            ? GameItemType.product
            : GameItemType.ingredient,
        itemId: currentItemId,
        fromRingIndex: fromRing,
      );
    }

    await _inboxRef(
      code,
      ringIndex,
    ).child(itemId).update({'type': 'product', 'itemId': resultItemId});

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
    final playerSnap = await _db
        .ref('$_roomsRoot/$code/players/$playerId')
        .get();
    if (!playerSnap.exists) return;
    final ringIndex = asMap(playerSnap.value)['ringIndex'] as int? ?? 0;

    // 1) Tìm đúng sản phẩm trong inbox của người nộp.
    //    Khoá trong inbox là id của món, KHÔNG phải itemId.
    final inboxSnap = await _inboxRef(code, ringIndex).get();
    String? productKey;
    for (final e in asMap(inboxSnap.value).entries) {
      final d = asMap(e.value);
      if (d['type'] == 'product' && d['itemId'] == productId) {
        productKey = e.key;
        break;
      }
    }
    if (productKey == null) return; // Không có sản phẩm này → không nộp

    // 2) Sản phẩm phải khớp công thức của đơn (giống bản Fake).
    final orderSnap = await _db
        .ref('$_roomsRoot/$code/orders/$playerId/$orderId')
        .get();
    final recipeId = asMap(orderSnap.value)['recipeId'] as String?;
    if (recipeId == null) return;
    final matches = RecipePool.allRecipes.where((r) => r.id == recipeId);
    final expectedProductId = matches.isEmpty
        ? recipeId
        : matches.first.productId;
    if (productId != expectedProductId && productId != recipeId) return;

    // 3) Transaction nhỏ trên order/status để idempotent (D17).
    //    Abort nếu không phải pending — tránh nộp lại cùng đơn.
    bool accepted = false;
    try {
      final tr = await _db
          .ref('$_roomsRoot/$code/orders/$playerId/$orderId/status')
          .runTransaction((currentData) {
            if (currentData != 'pending') return Transaction.abort();
            return Transaction.success('submitted');
          });
      accepted = tr.committed;
    } catch (_) {
      return;
    }
    if (!accepted) return; // Đã nộp trước đó

    // 4) MỘT multi-path update; nếu lỗi thì hoàn lại trạng thái đơn để
    //    không bị kẹt ở "submitted" mà chưa tính tiến độ.
    try {
      await _db.ref().update({
        '$_roomsRoot/$code/players/$playerId/completedOrders':
            ServerValue.increment(1),
        '$_roomsRoot/$code/round/progress/$ringIndex': ServerValue.increment(1),
        '$_roomsRoot/$code/timer/endTime': ServerValue.increment(
          BartenderConfig.orderCompletionBonusSeconds * 1000,
        ),
        '$_roomsRoot/$code/inbox/$ringIndex/$productKey': null, // xoá đúng món
      });
    } catch (e) {
      await _db
          .ref('$_roomsRoot/$code/orders/$playerId/$orderId/status')
          .set('pending');
      rethrow;
    }
  }

  @override
  Future<void> endMatch(String code) async {
    // Chỉ chạy khi status == 'playing' (D17)
    final statusSnap = await _db.ref('$_roomsRoot/$code/status').get();
    if ((statusSnap.value as String?) != 'playing') return;

    // Thu thập dữ liệu để tính results
    final roomSnap = await _roomRef(code).get();
    if (!roomSnap.exists) return;
    final roomData = asMap(roomSnap.value);
    final playersData = asMap(roomData['players']);
    final timerData = asMap(roomData['timer']);

    final startedAt = (timerData['startedAt'] as int?) ?? 0;
    final offset = await _getServerOffsetMs();
    final now = DateTime.now().millisecondsSinceEpoch;
    final serverNow = now + offset;
    final endTime = (timerData['endTime'] as int?) ?? serverNow;
    // survivalSeconds = min(serverNow, endTime) − startedAt (Bước 6)
    final survivalMs = serverNow.clamp(startedAt, endTime) - startedAt;
    final survivalSec = (survivalMs / 1000).round().clamp(
      0,
      BartenderConfig.initialTimerSeconds * 10,
    );

    final ranking =
        playersData.entries.map((e) {
          final d = asMap(e.value);
          return {
            'playerId': e.key,
            'completedOrders': (d['completedOrders'] as int?) ?? 0,
          };
        }).toList()..sort(
          (a, b) => (b['completedOrders'] as int).compareTo(
            a['completedOrders'] as int,
          ),
        );

    final totalOrders = ranking.fold<int>(
      0,
      (sum, r) => sum + (r['completedOrders'] as int),
    );

    final resultsPayload = {
      'totalSurvivalSeconds': survivalSec,
      'totalTeamOrders': totalOrders,
      'ranking': ranking,
    };

    // Transaction trên results (D17): ghi results TRƯỚC khi set ended.
    // Chỉ ghi khi results còn null (chưa ai ghi).
    bool resultsWritten = false;
    try {
      final tr = await _db.ref('$_roomsRoot/$code/results').runTransaction((
        currentData,
      ) {
        if (currentData != null) return Transaction.abort(); // Đã có
        resultsWritten = true;
        return Transaction.success(resultsPayload);
      });
      resultsWritten = tr.committed;
    } catch (e) {
      debugPrint('Lỗi transaction results: $e');
      return;
    }

    if (!resultsWritten) return; // Đã có client khác ghi

    // Results đã ghi → set status = ended và đặt readyInLobby = false cho mọi người
    final endUpdates = <String, dynamic>{
      '$_roomsRoot/$code/status': 'ended',
    };
    for (final pId in playersData.keys) {
      endUpdates['$_roomsRoot/$code/players/$pId/readyInLobby'] = false;
    }
    await _db.ref().update(endUpdates);
  }

  // ─── Parsing ────────────────────────────────────────────────────────────────

  Room _parseRoom(String code, Map<String, dynamic> data) {
    final statusStr = (data['status'] as String?) ?? 'lobby';
    final status = RoomStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => RoomStatus.lobby,
    );

    final playersData = asMap(data['players']);
    final players = _parsePlayersFromMap(playersData);

    // Inbox
    final inboxData = asMap(data['inbox']);
    final inbox = <int, List<GameItem>>{};
    for (final entry in inboxData.entries) {
      final ring = int.tryParse(entry.key.toString()) ?? 0;
      final itemsMap = asMap(entry.value);
      inbox[ring] = itemsMap.entries.map((e) {
        final d = asMap(e.value);
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

    // Timer — truyền serverOffsetMs vào MatchTimer (Bước 6)
    MatchTimer? timer;
    final timerData = asMap(data['timer']);
    if (timerData.isNotEmpty) {
      timer = MatchTimer(
        endTime: (timerData['endTime'] as int?) ?? 0,
        startedAt: (timerData['startedAt'] as int?) ?? 0,
        serverOffsetMs: _serverOffsetMs, // Dùng cached offset
      );
    }

    // Round
    Round? currentRound;
    final roundData = asMap(data['round']);
    if (roundData.isNotEmpty) {
      final stationData = asMap(roundData['stationAssignment']);
      final assignment = <int, StationType?>{};
      for (final e in stationData.entries) {
        final ring = int.tryParse(e.key.toString()) ?? 0;
        final stName = (e.value as String?) ?? '';
        assignment[ring] = StationType.values.cast<StationType?>().firstWhere(
          (s) => s?.name == stName,
          orElse: () => null,
        );
      }

      final ordersData = asMap(data['orders']);
      final playerOrders = <String, List<Order>>{};
      for (final pEntry in ordersData.entries) {
        final pId = pEntry.key.toString();
        final pOrdersMap = asMap(pEntry.value);
        playerOrders[pId] = pOrdersMap.entries.map((e) {
          final d = asMap(e.value);
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
        ordersPerPlayer:
            (roundData['ordersPerPlayer'] as int?) ??
            BartenderConfig.ordersPerPlayer,
        stationAssignment: assignment,
        playerOrders: playerOrders,
      );
    }

    // Results
    MatchResult? results;
    final resultsData = asMap(data['results']);
    if (resultsData.isNotEmpty) {
      final rankingField = resultsData['ranking'];
      final rankingIterable = rankingField is List
          ? rankingField
          : asMap(rankingField).values;
      final ranking = rankingIterable.map((r) {
        final d = asMap(r);
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

  Map<String, Player> _parsePlayersFromMap(Map<String, dynamic> data) {
    final result = <String, Player>{};
    for (final entry in data.entries) {
      final id = entry.key.toString();
      final d = asMap(entry.value);
      result[id] = Player(
        id: id,
        name: (d['name'] as String?) ?? id,
        ringIndex: (d['ringIndex'] as int?) ?? 0,
        connected: (d['connected'] as bool?) ?? true,
        completedOrders: (d['completedOrders'] as int?) ?? 0,
        readyInLobby: (d['readyInLobby'] as bool?) ?? true,
      );
    }
    return result;
  }

  @override
  void dispose() {
    for (final timer in _spawnTimers.values) {
      timer.cancel();
    }
    _spawnTimers.clear();
    _latestRooms.clear();
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

/// Compact ringIndex: dồn các player về 0..k-1 giữ nguyên thứ tự.
///
/// [playersData] là `Map<playerId, playerData>` (chỉ những người còn connected).
/// Trả về `Map<playerId, playerData>` với `ringIndex` mới.

///
/// Dùng chung cho startMatch (lobby → playing) và round boundary (D14).
Map<String, dynamic> compactRing(Map<String, dynamic> playersData) {
  // Sắp theo ringIndex cũ để giữ nguyên thứ tự
  final sorted = playersData.entries.toList()
    ..sort((a, b) {
      final ra = asMap(a.value)['ringIndex'] as int? ?? 0;
      final rb = asMap(b.value)['ringIndex'] as int? ?? 0;
      return ra.compareTo(rb);
    });

  final result = <String, dynamic>{};
  for (var i = 0; i < sorted.length; i++) {
    final e = sorted[i];
    final d = Map<String, dynamic>.from(asMap(e.value));
    d['ringIndex'] = i;
    result[e.key] = d;
  }
  return result;
}

