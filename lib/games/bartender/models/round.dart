import 'order.dart';
import 'station.dart';

/// Trạng thái một round trong trận đấu.
///
/// Xem PROJECT_SPEC.md mục "Vòng lặp trận đấu":
/// - Mỗi round, mỗi người nhận ordersPerPlayer đơn cần hoàn thành.
/// - Round kết thúc khi TẤT CẢ người chơi đã hoàn thành hết đơn.
/// - Khi round kết thúc: trạm phân lại, round mới bắt đầu.
///
/// Xem DECISIONS.md D4: round model tách rời khỏi đồng hồ chung.
///
/// Logic tổng quát cho N người bất kỳ.
class Round {
  const Round({
    required this.number,
    required this.ordersPerPlayer,
    required this.stationAssignment,
    required this.playerOrders,
  });

  /// Số thứ tự round (1, 2, 3, ...).
  final int number;

  /// Số đơn mỗi người cần hoàn thành trong round này.
  /// Mục tiêu: 3 — xem PROJECT_SPEC.md.
  final int ordersPerPlayer;

  /// Trạm được phân cho mỗi người chơi.
  /// Key = ringIndex, Value = loại trạm (null = không có trạm).
  /// Xem API.md: round/stationAssignment/{ringIndex}
  final Map<int, StationType?> stationAssignment;

  /// Đơn hàng của từng người chơi trong round này.
  /// Key = playerId, Value = danh sách đơn.
  final Map<String, List<Order>> playerOrders;

  /// Kiểm tra một người chơi đã hoàn thành hết đơn của round chưa.
  bool isPlayerDone(String playerId) {
    final orders = playerOrders[playerId];
    if (orders == null || orders.isEmpty) return true;
    return orders.every((order) => order.isCompleted);
  }

  /// Kiểm tra round đã kết thúc chưa (tất cả người chơi đều xong).
  ///
  /// Xem PROJECT_SPEC.md: "Round chỉ kết thúc khi TẤT CẢ người chơi
  /// trong phòng đã hoàn thành hết đơn của round đó."
  bool get isComplete {
    return playerOrders.keys.every(isPlayerDone);
  }

  /// Đếm số đơn đã hoàn thành của một người chơi trong round này.
  int completedCount(String playerId) {
    final orders = playerOrders[playerId];
    if (orders == null) return 0;
    return orders.where((o) => o.isCompleted).length;
  }

  /// Tạo bản sao với một số trường thay đổi.
  Round copyWith({
    int? number,
    int? ordersPerPlayer,
    Map<int, StationType?>? stationAssignment,
    Map<String, List<Order>>? playerOrders,
  }) {
    return Round(
      number: number ?? this.number,
      ordersPerPlayer: ordersPerPlayer ?? this.ordersPerPlayer,
      stationAssignment: stationAssignment ?? this.stationAssignment,
      playerOrders: playerOrders ?? this.playerOrders,
    );
  }

  @override
  String toString() =>
      'Round(#$number, ordersPerPlayer=$ordersPerPlayer, '
      'complete=$isComplete)';
}
