import 'match_timer.dart';
import 'player.dart';
import 'round.dart';

/// Trạng thái phòng chơi — aggregate chứa tất cả dữ liệu của một trận.
///
/// Khớp với schema Firebase gốc: rooms/{roomCode}/
/// Xem API.md cho chi tiết đầy đủ.
///
/// Đây là "source of truth" phía client — controller đọc/ghi Room qua
/// RoomRepository interface (xem ARCHITECTURE.md).
class Room {
  const Room({
    required this.code,
    required this.status,
    required this.players,
    this.timer,
    this.currentRound,
  });

  /// Mã phòng (ví dụ "4821"). Dùng để người khác nhập vào phòng.
  final String code;

  /// Trạng thái phòng hiện tại.
  final RoomStatus status;

  /// Danh sách người chơi. Key = playerId.
  final Map<String, Player> players;

  /// Đồng hồ chung (null khi phòng đang ở lobby, chưa bắt đầu trận).
  final MatchTimer? timer;

  /// Round hiện tại (null khi chưa bắt đầu trận).
  final Round? currentRound;

  /// Số người chơi đang kết nối.
  int get connectedPlayerCount =>
      players.values.where((p) => p.connected).length;

  /// Tổng số người chơi (kể cả đã thoát — slot vẫn giữ).
  int get totalPlayerCount => players.length;

  /// Có đủ người để bắt đầu trận không (≥ 2).
  /// Xem PROJECT_SPEC.md: "Trận có thể bắt đầu khi có từ 2 người trở lên."
  bool get canStart =>
      status == RoomStatus.lobby && connectedPlayerCount >= 2;

  /// Lấy Player theo ringIndex.
  Player? playerAtRing(int ringIndex) {
    return players.values.cast<Player?>().firstWhere(
      (p) => p!.ringIndex == ringIndex,
      orElse: () => null,
    );
  }

  /// Tạo bản sao với một số trường thay đổi.
  Room copyWith({
    RoomStatus? status,
    Map<String, Player>? players,
    MatchTimer? timer,
    Round? currentRound,
  }) {
    return Room(
      code: code,
      status: status ?? this.status,
      players: players ?? this.players,
      timer: timer ?? this.timer,
      currentRound: currentRound ?? this.currentRound,
    );
  }

  @override
  String toString() =>
      'Room($code, $status, ${players.length} players, '
      'round=${currentRound?.number})';
}

/// Trạng thái phòng. Khớp với trường "status" trong API.md.
enum RoomStatus {
  /// Đang chờ người chơi vào — chưa bắt đầu trận.
  lobby,

  /// Đang chơi.
  playing,

  /// Trận đã kết thúc (đồng hồ về 0).
  ended,
}
