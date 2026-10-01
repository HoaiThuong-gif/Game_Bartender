/// Dữ liệu một người chơi trong phòng.
///
/// Khớp với schema Firebase: rooms/{code}/players/{playerId}/
/// Xem API.md cho chi tiết các trường.
class Player {
  const Player({
    required this.id,
    required this.name,
    required this.ringIndex,
    this.connected = true,
    this.completedOrders = 0,
  });

  /// ID duy nhất của người chơi (dùng làm key trong Firebase).
  final String id;

  /// Tên hiển thị do người chơi tự nhập.
  final String name;

  /// Vị trí trong vòng tròn (0-based). Không đổi suốt trận.
  /// Xem API.md: "ringIndex is assigned at room-creation/join time
  /// and does not change mid-match."
  final int ringIndex;

  /// Có đang kết nối hay không. false = đã thoát giữa trận.
  /// Slot vẫn giữ nguyên (không xoá) để không phải đánh số lại.
  final bool connected;

  /// Số đơn cá nhân đã hoàn thành — dùng cho bảng xếp hạng cuối trận.
  final int completedOrders;

  /// Tạo bản sao với một số trường thay đổi.
  Player copyWith({
    bool? connected,
    int? completedOrders,
  }) {
    return Player(
      id: id,
      name: name,
      ringIndex: ringIndex,
      connected: connected ?? this.connected,
      completedOrders: completedOrders ?? this.completedOrders,
    );
  }

  @override
  String toString() =>
      'Player($name, ring=$ringIndex, orders=$completedOrders)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player &&
          id == other.id &&
          name == other.name &&
          ringIndex == other.ringIndex &&
          connected == other.connected &&
          completedOrders == other.completedOrders;

  @override
  int get hashCode =>
      Object.hash(id, name, ringIndex, connected, completedOrders);
}
