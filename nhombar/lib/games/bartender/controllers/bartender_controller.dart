import 'dart:async';

import 'package:flutter/foundation.dart';

import '../bartender_config.dart';
import '../models/game_item.dart';
import '../models/order.dart';
import '../models/player.dart';
import '../models/ring.dart';
import '../models/room.dart';
import '../models/station.dart';
import '../services/bartender_haptics.dart';
import '../services/fake_room_repository.dart';
import '../services/firebase_room_repository.dart';
import '../services/api_room_repository.dart';
import '../services/room_repository.dart';
export '../services/room_repository.dart' show RoomConnectionState;

/// Quản lý trạng thái trận đấu Bartender và giao tiếp giữa UI và RoomRepository.
///
/// Tuân theo mẫu ChangeNotifier của Flutter (tương tự CubeInputController bên Rubik).
/// exposes state to widgets".
///
/// Tự động chọn repository dựa theo [BartenderConfig.useFakeRepository]:
/// - true  → [FakeRoomRepository] (chạy offline, single-device, giai đoạn 1-4)
/// - false → [ApiRoomRepository] (backend HTTP độc lập)
class BartenderController extends ChangeNotifier {
  BartenderController({RoomRepository? repository, int Function()? nowMs})
    : _nowMs = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch),
      _repository =
          repository ??
          (switch (BartenderConfig.backend) {
            BartenderBackend.fake => FakeRoomRepository(),
            BartenderBackend.firebase => FirebaseRoomRepository(),
            BartenderBackend.api => ApiRoomRepository(),
          }) {
    _connectionState = _repository.connectionState;
    _connectionSubscription = _repository.watchConnectionState().listen((
      state,
    ) {
      if (_isDisposed) return;
      if (_connectionState != state) {
        _connectionState = state;
        if (state == RoomConnectionState.lost && _errorMessage == null) {
          _errorMessage = 'Mất kết nối với máy chủ.';
        }
        notifyListeners();
      }
    });
  }

  final RoomRepository _repository;
  final int Function() _nowMs;

  @visibleForTesting
  RoomRepository get repository => _repository;

  Room? _room;
  String? _noticeMessage;
  String? _errorMessage;
  bool _isBusy = false;
  bool _isDisposed = false;
  bool _hasReturnedToLobby = false;
  int? _reportedPreparation;
  int? _reportingPreparation;
  String? _lastTick;

  StreamSubscription<Room>? _roomSubscription;
  StreamSubscription<RoomConnectionState>? _connectionSubscription;
  RoomConnectionState _connectionState = RoomConnectionState.connected;
  Timer? _countdownTicker;
  Timer? _noticeTimer;

  // ─── Getters ──────────────────────────────────────────────────

  Room? get room => _room;

  /// Trạng thái kết nối hiện tại của repository (connected / reconnecting / lost).
  RoomConnectionState get connectionState => _connectionState;

  /// ID người chơi trên máy này — lấy từ repository (không đoán).
  String? get myPlayerId {
    try {
      return _repository.localPlayerId;
    } catch (_) {
      return null;
    }
  }

  String? get noticeMessage => _noticeMessage;
  String? get errorMessage => _errorMessage;
  bool get isBusy => _isBusy;

  /// Thông tin người chơi hiện tại trên máy này.
  Player? get me {
    final pid = myPlayerId;
    return pid == null ? null : _room?.players[pid];
  }

  /// Vị trí của người chơi hiện tại trong vòng tròn.
  int get myRingIndex => me?.ringIndex ?? 0;

  /// Trạm chế biến được phân cho người chơi hiện tại trong round này.
  /// Có thể là null nếu round này người chơi không có trạm (xem DECISIONS D5).
  StationType? get myStation =>
      _room?.currentRound?.stationAssignment[myRingIndex];

  /// Danh sách đơn hàng cần làm của người chơi hiện tại trong round này.
  List<Order> get myOrders {
    final pid = myPlayerId;
    return pid == null
        ? const []
        : (_room?.currentRound?.playerOrders[pid] ?? const []);
  }

  /// Danh sách các vật phẩm hiện có trên màn hình của người chơi.
  List<GameItem> get myItems => _room?.itemsAtRing(myRingIndex) ?? const [];

  /// Người chơi liền kề bên trái trong vòng tròn.
  Player? get leftNeighbor {
    if (_room == null || _room!.totalPlayerCount < 2) return null;
    final leftIndex = Ring.leftNeighbor(myRingIndex, _room!.totalPlayerCount);
    return _room!.playerAtRing(leftIndex);
  }

  /// Người chơi liền kề bên phải trong vòng tròn.
  Player? get rightNeighbor {
    if (_room == null || _room!.totalPlayerCount < 2) return null;
    final rightIndex = Ring.rightNeighbor(myRingIndex, _room!.totalPlayerCount);
    return _room!.playerAtRing(rightIndex);
  }

  /// Số giây còn lại của đồng hồ chung.
  int get remainingSeconds {
    final timer = _room?.timer;
    if (timer == null) return 0;
    return (timer.remainingMs(nowMs: _nowMs()) + 999) ~/ 1000;
  }

  bool get isMatchPreparing =>
      isMatchPlaying && _room?.timer?.isPreparing == true;
  int get startCountdownSeconds => isMatchPlaying
      ? (_room?.timer?.startsInSeconds(nowMs: _nowMs()) ?? 0)
      : 0;
  bool get isGameplayActive =>
      isMatchPlaying && (_room?.timer?.hasStarted(nowMs: _nowMs()) ?? false);
  int get sceneReadyPlayerCount =>
      _room?.players.values
          .where(
            (p) =>
                p.connected &&
                (_room?.timer?.readyPlayerIds.contains(p.id) ?? false),
          )
          .length ??
      0;

  Future<void> reportSceneReady({required int preparationId}) async {
    final code = _room?.code;
    if (code == null ||
        !isMatchPreparing ||
        _room!.timer!.startedAt != preparationId ||
        myPlayerId == null ||
        _reportedPreparation == preparationId ||
        _reportingPreparation == preparationId) {
      return;
    }
    _reportingPreparation = preparationId;
    try {
      await _repository.markSceneReady(
        code: code,
        playerId: myPlayerId!,
        preparationId: preparationId,
      );
      if (!_isDisposed) _reportedPreparation = preparationId;
    } catch (e) {
      if (!_isDisposed) {
        _errorMessage = 'Không thể chuẩn bị trận: $e';
        notifyListeners();
      }
    } finally {
      if (_reportingPreparation == preparationId) _reportingPreparation = null;
    }
  }

  /// Tổng số đơn cả đội đã hoàn thành trong trận đấu.
  int get totalTeamOrders {
    final players = _room?.players.values;
    if (players == null) return 0;
    return players.fold<int>(0, (sum, p) => sum + p.completedOrders);
  }

  /// Trạng thái trận đấu: đang chờ ở lobby?
  bool get isInLobby => _room?.status == RoomStatus.lobby;

  /// Trạng thái trận đấu: đang diễn ra?
  bool get isMatchPlaying => _room?.status == RoomStatus.playing;

  /// Trạng thái trận đấu: đã kết thúc?
  bool get isMatchEnded => _room?.status == RoomStatus.ended;

  /// Người chơi có đang ở màn hình kết quả hay không.
  /// Khi trận kết thúc nhưng người chơi chưa bấm "Quay lại phòng" -> true.
  bool get isViewingResults => isMatchEnded && !_hasReturnedToLobby;

  // ─── Actions ──────────────────────────────────────────────────

  /// Tạo phòng mới với vai trò chủ phòng (host).
  Future<void> createRoom({
    String playerName = 'Người chơi',
    int totalPlayers = 1,
  }) async {
    _setBusy(true);
    _clearMessages();
    try {
      final room = await _repository.createRoom(
        hostPlayerName: playerName,
        totalPlayers: totalPlayers,
      );
      // localPlayerId đã được repository gán trong createRoom.
      _subscribeToRoom(room.code);
      _room = room;
      _showNotice('Đã tạo phòng #${room.code}!');
    } catch (e) {
      _errorMessage = 'Không thể tạo phòng: $e';
    } finally {
      _setBusy(false);
    }
  }

  /// Tham gia phòng đã tạo bằng mã phòng.
  Future<void> joinRoom({
    required String code,
    required String playerName,
  }) async {
    _setBusy(true);
    _clearMessages();
    try {
      final room = await _repository.joinRoom(
        code: code,
        playerName: playerName,
      );
      // localPlayerId đã được repository gán trong joinRoom.
      _subscribeToRoom(room.code);
      _room = room;
      _showNotice('Đã vào phòng #${room.code}!');
    } catch (e) {
      _errorMessage = 'Không thể vào phòng: $e';
    } finally {
      _setBusy(false);
    }
  }

  /// Bắt đầu trận đấu (chỉ chủ phòng myRingIndex == 0 mới có quyền).
  Future<void> startMatch({bool waitForScene = false}) async {
    final code = _room?.code;
    if (code == null) return;
    if (myRingIndex != 0) {
      _errorMessage = 'Chỉ chủ phòng mới có thể bắt đầu trận đấu.';
      notifyListeners();
      return;
    }
    _setBusy(true);
    _clearMessages();
    try {
      await _repository.startMatch(code: code, waitForScene: waitForScene);
    } catch (e) {
      _errorMessage = 'Không thể bắt đầu: $e';
    } finally {
      _setBusy(false);
    }
  }

  /// Chuyền một vật phẩm sang người bên trái trong vòng tròn.
  Future<void> swipeItemLeft(GameItem item) async {
    final code = _room?.code;
    if (code == null || !isGameplayActive) return;

    final target = leftNeighbor;
    if (target == null) return;

    try {
      await _repository.sendItem(
        code: code,
        fromRingIndex: myRingIndex,
        toRingIndex: target.ringIndex,
        item: item,
      );
      _showNotice('⬅️ Đã chuyền cho ${target.name}!');
    } catch (e) {
      _errorMessage = 'Không thể chuyền: $e';
      notifyListeners();
    }
  }

  /// Chuyền một vật phẩm sang người bên phải trong vòng tròn.
  Future<void> swipeItemRight(GameItem item) async {
    final code = _room?.code;
    if (code == null || !isGameplayActive) return;

    final target = rightNeighbor;
    if (target == null) return;

    try {
      await _repository.sendItem(
        code: code,
        fromRingIndex: myRingIndex,
        toRingIndex: target.ringIndex,
        item: item,
      );
      _showNotice('➡️ Đã chuyền cho ${target.name}!');
    } catch (e) {
      _errorMessage = 'Không thể chuyền: $e';
      notifyListeners();
    }
  }

  /// Kéo hoặc bấm bỏ vật phẩm vào thùng rác.
  Future<void> trashItem(GameItem item) async {
    final code = _room?.code;
    if (code == null || !isGameplayActive) return;

    try {
      await _repository.trashItem(
        code: code,
        ringIndex: myRingIndex,
        itemId: item.id,
      );
      unawaited(BartenderHaptics.itemTrashed());
      _showNotice('🗑️ Đã bỏ thùng rác!');
    } catch (e) {
      _errorMessage = 'Không thể xoá vật phẩm: $e';
      notifyListeners();
    }
  }

  /// Chế biến vật phẩm tại trạm hiện tại của người chơi.
  Future<void> processItemAtStation(GameItem item) async {
    final code = _room?.code;
    final station = myStation;
    if (code == null || station == null || !isGameplayActive) {
      return;
    }

    _setBusy(true);
    try {
      await _repository.processItemAtStation(
        code: code,
        ringIndex: myRingIndex,
        itemId: item.id,
        station: station,
      );
      _showNotice('✨ Đã ${station.actionVerb}!');
    } catch (e) {
      _errorMessage = 'Chế biến thất bại: $e';
    } finally {
      _setBusy(false);
    }
  }

  /// Nộp đơn hàng đã hoàn tất.
  /// Cộng +5s vào đồng hồ chung và +1 đơn cho cá nhân.
  Future<void> submitOrder(Order order, GameItem product) async {
    final code = _room?.code;
    final pId = myPlayerId;
    if (code == null || pId == null || !isGameplayActive) {
      return;
    }

    _setBusy(true);
    try {
      await _repository.submitOrder(
        code: code,
        playerId: pId,
        orderId: order.id,
        productId: product.id.isNotEmpty ? product.id : product.itemId,
      );
      unawaited(BartenderHaptics.orderSubmitted());
      _showNotice('🎉 +5s! Đã hoàn thành đơn hàng!');
    } catch (e) {
      _errorMessage = 'Không thể nộp đơn: $e';
    } finally {
      _setBusy(false);
    }
  }

  /// Quay lại phòng chờ ban đầu sau khi trận kết thúc (giữ nguyên mã phòng).
  Future<void> returnToLobby() async {
    final code = _room?.code;
    final pId = myPlayerId;

    if (code != null && pId != null) {
      _setBusy(true);
      try {
        await _repository.returnToLobby(code: code, playerId: pId);
        if (!_isDisposed) _hasReturnedToLobby = true;
      } catch (e) {
        _errorMessage = 'Chưa quay lại được phòng: $e';
      } finally {
        _setBusy(false);
      }
    }
  }

  /// Chơi lại từ đầu (quay lại phòng chờ ban đầu).
  Future<void> playAgain() => returnToLobby();

  /// Rời phòng hiện tại.
  Future<void> leaveRoom() async {
    final code = _room?.code;
    final pId = myPlayerId;
    _setBusy(true);
    try {
      if (code != null && pId != null) {
        await _repository.leaveRoom(code: code, playerId: pId);
      }
      if (!_isDisposed) _resetRoom();
    } catch (error) {
      _errorMessage = 'Chưa rời được phòng: $error';
    } finally {
      _setBusy(false);
    }
  }

  // ─── Private Helpers ──────────────────────────────────────────

  void _subscribeToRoom(String code) {
    _roomSubscription?.cancel();
    _roomSubscription = _repository
        .watchRoom(code)
        .listen(
          (updatedRoom) {
            // D14: Nếu người chơi bị loại khỏi phòng (ví dụ qua ranh giới round khi mất kết nối)
            if (myPlayerId != null &&
                _room != null &&
                !updatedRoom.players.containsKey(myPlayerId)) {
              _stopTicker();
              _roomSubscription?.cancel();
              _roomSubscription = null;
              _room = null;
              _errorMessage = 'Bạn đã bị loại khỏi phòng do mất kết nối.';
              notifyListeners();
              return;
            }

            final oldRound = _room?.currentRound?.number;
            if (updatedRoom.status == RoomStatus.playing ||
                updatedRoom.status == RoomStatus.lobby) {
              _hasReturnedToLobby = false;
            }
            _room = updatedRoom;

            // Thông báo khi chuyển round
            if (oldRound != null &&
                updatedRoom.currentRound != null &&
                updatedRoom.currentRound!.number > oldRound) {
              _showNotice(
                '🔔 BẮT ĐẦU ROUND ${updatedRoom.currentRound!.number}! Đổi trạm mới!',
              );
            }

            // Quản lý ticker đếm ngược
            if (updatedRoom.status == RoomStatus.playing) {
              _startTicker();
            } else {
              _stopTicker();
            }

            notifyListeners();
          },
          onError: (err) {
            if (_isDisposed) return;
            _errorMessage = err
                .toString()
                .replaceFirst('StateError: ', '')
                .replaceFirst('Exception: ', '');
            notifyListeners();
          },
        );
  }

  void _startTicker() {
    if (_countdownTicker?.isActive == true) return;
    _countdownTicker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_room?.status != RoomStatus.playing) return;
      final signature =
          '$remainingSeconds:$startCountdownSeconds:$isMatchPreparing';
      if (signature != _lastTick) {
        _lastTick = signature;
        notifyListeners();
      }
      if (isGameplayActive && remainingSeconds <= 0) {
        _stopTicker();
        unawaited(BartenderHaptics.timeExpired());
        final code = _room?.code;
        if (code != null) {
          _repository.endMatch(code).catchError((Object error) {
            if (_isDisposed) return;
            _errorMessage = 'Không cập nhật được kết quả: $error';
            notifyListeners();
          });
        }
      }
    });
  }

  void _stopTicker() {
    _countdownTicker?.cancel();
    _countdownTicker = null;
    _lastTick = null;
  }

  void _showNotice(String msg) {
    _noticeMessage = msg;
    _noticeTimer?.cancel();
    _noticeTimer = Timer(const Duration(seconds: 3), () {
      _noticeMessage = null;
      if (!_isDisposed) notifyListeners();
    });
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _noticeMessage = null;
  }

  void _setBusy(bool val) {
    _isBusy = val;
    if (!_isDisposed) notifyListeners();
  }

  void _resetRoom() {
    _stopTicker();
    _roomSubscription?.cancel();
    _roomSubscription = null;
    _room = null;
    _hasReturnedToLobby = false;
    _clearMessages();
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _connectionSubscription?.cancel();
    _stopTicker();
    _noticeTimer?.cancel();
    _roomSubscription?.cancel();
    _repository.dispose();
    super.dispose();
  }
}
