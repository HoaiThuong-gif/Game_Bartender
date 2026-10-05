import 'dart:async';

import 'package:flutter/foundation.dart';

import '../bartender_config.dart';
import '../models/game_item.dart';
import '../models/order.dart';
import '../models/player.dart';
import '../models/ring.dart';
import '../models/room.dart';
import '../models/station.dart';
import '../services/fake_room_repository.dart';
import '../services/firebase_room_repository.dart';
import '../services/room_repository.dart';

/// Quản lý trạng thái trận đấu Bartender và giao tiếp giữa UI và RoomRepository.
///
/// Tuân theo mẫu ChangeNotifier của Flutter (tương tự CubeInputController bên Rubik).
/// Xem ARCHITECTURE.md: "controllers/ Round/timer state management — reads/writes via RoomRepository,
/// exposes state to widgets".
///
/// Tự động chọn repository dựa theo [BartenderConfig.useFakeRepository]:
/// - true  → [FakeRoomRepository] (chạy offline, single-device, giai đoạn 1-4)
/// - false → [FirebaseRoomRepository] (chạy online RTDB, giai đoạn 5+)
class BartenderController extends ChangeNotifier {
  BartenderController({RoomRepository? repository})
      : _repository = repository ??
            (BartenderConfig.useFakeRepository
                ? FakeRoomRepository()
                : FirebaseRoomRepository());

  final RoomRepository _repository;

  Room? _room;
  String? _myPlayerId;
  String? _noticeMessage;
  String? _errorMessage;
  bool _isBusy = false;
  bool _isDisposed = false;

  StreamSubscription<Room>? _roomSubscription;
  Timer? _countdownTicker;
  Timer? _noticeTimer;

  // ─── Getters ──────────────────────────────────────────────────

  Room? get room => _room;
  String? get myPlayerId => _myPlayerId;
  String? get noticeMessage => _noticeMessage;
  String? get errorMessage => _errorMessage;
  bool get isBusy => _isBusy;

  /// Thông tin người chơi hiện tại trên máy này.
  Player? get me =>
      _myPlayerId == null ? null : _room?.players[_myPlayerId];

  /// Vị trí của người chơi hiện tại trong vòng tròn.
  int get myRingIndex => me?.ringIndex ?? 0;

  /// Trạm chế biến được phân cho người chơi hiện tại trong round này.
  /// Có thể là null nếu round này người chơi không có trạm (xem DECISIONS D5).
  StationType? get myStation =>
      _room?.currentRound?.stationAssignment[myRingIndex];

  /// Danh sách đơn hàng cần làm của người chơi hiện tại trong round này.
  List<Order> get myOrders =>
      _myPlayerId == null
          ? const []
          : (_room?.currentRound?.playerOrders[_myPlayerId] ?? const []);

  /// Danh sách các vật phẩm hiện có trên màn hình của người chơi.
  List<GameItem> get myItems =>
      _room?.itemsAtRing(myRingIndex) ?? const [];

  /// Người chơi liền kề bên trái trong vòng tròn.
  Player? get leftNeighbor {
    if (_room == null || _room!.totalPlayerCount < 2) return null;
    final leftIndex =
        Ring.leftNeighbor(myRingIndex, _room!.totalPlayerCount);
    return _room!.playerAtRing(leftIndex);
  }

  /// Người chơi liền kề bên phải trong vòng tròn.
  Player? get rightNeighbor {
    if (_room == null || _room!.totalPlayerCount < 2) return null;
    final rightIndex =
        Ring.rightNeighbor(myRingIndex, _room!.totalPlayerCount);
    return _room!.playerAtRing(rightIndex);
  }

  /// Số giây còn lại của đồng hồ chung.
  int get remainingSeconds {
    final timer = _room?.timer;
    if (timer == null) return 0;
    return timer.remainingMs(nowMs: DateTime.now().millisecondsSinceEpoch) ~/
        1000;
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

  // ─── Actions ──────────────────────────────────────────────────

  /// Tạo phòng mới với vai trò chủ phòng (host).
  Future<void> createRoom({
    String playerName = 'Bạn',
    int totalPlayers = 3,
  }) async {
    _setBusy(true);
    _clearMessages();
    try {
      final room = await _repository.createRoom(
        hostPlayerName: playerName,
        totalPlayers: totalPlayers,
      );
      // FakeRoomRepository đặt playerId dạng 'p_0'.
      // FirebaseRoomRepository dùng uid từ FirebaseAuth —
      // cả hai đều đặt host ở ringIndex==0, nên tìm theo ringIndex.
      _myPlayerId = room.players.entries
          .firstWhere(
            (e) => e.value.ringIndex == 0,
            orElse: () => room.players.entries.first,
          )
          .key;
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
      // FirebaseRoomRepository trả về room sau khi uid đã được ghi vào DB.
      // Tìm uid của mình bằng cách so khớp tên + ringIndex mới nhất.
      // Với FakeRoomRepository, players là 'p_0', 'p_1', ... —
      // ringIndex cao nhất = player mới nhất.
      final maxRingIndex = room.players.values
          .map((p) => p.ringIndex)
          .fold(0, (a, b) => a > b ? a : b);
      _myPlayerId = room.players.entries
          .firstWhere(
            (e) => e.value.ringIndex == maxRingIndex,
            orElse: () => room.players.entries.last,
          )
          .key;
      _subscribeToRoom(room.code);
      _room = room;
      _showNotice('Đã vào phòng #${room.code}!');
    } catch (e) {
      _errorMessage = 'Không thể vào phòng: $e';
    } finally {
      _setBusy(false);
    }
  }

  /// Bắt đầu trận đấu.
  Future<void> startMatch() async {
    final code = _room?.code;
    if (code == null) return;
    _setBusy(true);
    _clearMessages();
    try {
      await _repository.startMatch(code: code);
    } catch (e) {
      _errorMessage = 'Không thể bắt đầu: $e';
    } finally {
      _setBusy(false);
    }
  }

  /// Chuyền một vật phẩm sang người bên trái trong vòng tròn.
  Future<void> swipeItemLeft(GameItem item) async {
    final code = _room?.code;
    if (code == null || _room?.status != RoomStatus.playing) return;

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
    if (code == null || _room?.status != RoomStatus.playing) return;

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
    if (code == null || _room?.status != RoomStatus.playing) return;

    try {
      await _repository.trashItem(
        code: code,
        ringIndex: myRingIndex,
        itemId: item.id,
      );
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
    if (code == null ||
        station == null ||
        _room?.status != RoomStatus.playing) {
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
    final pId = _myPlayerId;
    if (code == null || pId == null || _room?.status != RoomStatus.playing) {
      return;
    }

    _setBusy(true);
    try {
      await _repository.submitOrder(
        code: code,
        playerId: pId,
        orderId: order.id,
        productId: product.itemId,
      );
      _showNotice('🎉 +5s! Đã hoàn thành đơn hàng!');
    } catch (e) {
      _errorMessage = 'Không thể nộp đơn: $e';
    } finally {
      _setBusy(false);
    }
  }

  /// Chơi lại từ đầu (tạo lại phòng mới).
  Future<void> playAgain() async {
    final name = me?.name ?? 'Bạn';
    final count = _room?.totalPlayerCount ?? 3;
    _resetRoom();
    await createRoom(playerName: name, totalPlayers: count);
  }

  /// Rời phòng hiện tại.
  Future<void> leaveRoom() async {
    final code = _room?.code;
    final pId = _myPlayerId;
    if (code != null && pId != null) {
      await _repository.leaveRoom(code: code, playerId: pId);
    }
    _resetRoom();
  }

  // ─── Private Helpers ──────────────────────────────────────────

  void _subscribeToRoom(String code) {
    _roomSubscription?.cancel();
    _roomSubscription = _repository.watchRoom(code).listen((updatedRoom) {
      final oldRound = _room?.currentRound?.number;
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
    });
  }

  void _startTicker() {
    _countdownTicker?.cancel();
    _countdownTicker =
        Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (_room?.status != RoomStatus.playing) return;

      final timeUp = remainingSeconds <= 0;
      notifyListeners();

      // Khi timer hết: controller kích hoạt kết thúc trận.
      // Dùng FirebaseRoomRepository: endMatch dùng transaction nên
      // chỉ 1 client sẽ ghi được, các client khác sẽ nhận status=ended
      // qua watchRoom stream.
      if (timeUp) {
        _stopTicker();
        final code = _room?.code;
        if (code != null) {
          if (_repository is FirebaseRoomRepository) {
            _repository.endMatch(code);
          }
          // FakeRoomRepository tự xử lý timer bên trong.
        }
      }
    });
  }

  void _stopTicker() {
    _countdownTicker?.cancel();
    _countdownTicker = null;
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
    notifyListeners();
  }

  void _resetRoom() {
    _stopTicker();
    _roomSubscription?.cancel();
    _roomSubscription = null;
    _room = null;
    _myPlayerId = null;
    _clearMessages();
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopTicker();
    _noticeTimer?.cancel();
    _roomSubscription?.cancel();
    _repository.dispose();
    super.dispose();
  }
}
