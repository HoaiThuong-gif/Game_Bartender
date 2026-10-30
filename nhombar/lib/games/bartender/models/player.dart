/// Dữ liệu một người chơi trong phòng.
///
/// Khớp với schema Firebase: rooms/{code}/players/{playerId}/
class Player {
  const Player({
    required this.id,
    required this.name,
    required this.ringIndex,
    this.connected = true,
    this.completedOrders = 0,
    this.readyInLobby = true,
  });

  /// ID duy nhất của người chơi (dùng làm key trong Firebase).
  final String id;

  /// Tên hiển thị do người chơi tự nhập.
  final String name;

  /// Vị trí trong vòng tròn (0-based). Không đổi suốt trận.
  /// and does not change mid-match."
  final int ringIndex;

  /// Có đang kết nối hay không. false = đã thoát giữa trận.
  /// Slot vẫn giữ nguyên (không xoá) để không phải đánh số lại.
  final bool connected;

  /// Số đơn cá nhân đã hoàn thành — dùng cho bảng xếp hạng cuối trận.
  final int completedOrders;

  /// Người chơi đã ở trong phòng chờ / sẵn sàng cho trận tiếp theo.
  /// Sau khi thua trận, cờ này đặt thành false cho đến khi người chơi bấm "QUAY LẠI PHÒNG".
  final bool readyInLobby;

  /// Tạo bản sao với một số trường thay đổi.
  Player copyWith({
    int? ringIndex,
    bool? connected,
    int? completedOrders,
    bool? readyInLobby,
  }) {
    return Player(
      id: id,
      name: name,
      ringIndex: ringIndex ?? this.ringIndex,
      connected: connected ?? this.connected,
      completedOrders: completedOrders ?? this.completedOrders,
      readyInLobby: readyInLobby ?? this.readyInLobby,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'ringIndex': ringIndex,
    'connected': connected,
    'completedOrders': completedOrders,
    'readyInLobby': readyInLobby,
  };

  /// Khởi tạo từ JSON map.
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: (json['name'] ?? '') as String,
      ringIndex: (json['ringIndex'] as num).toInt(),
      connected: (json['connected'] as bool?) ?? true,
      completedOrders: (json['completedOrders'] as num?)?.toInt() ?? 0,
      readyInLobby: (json['readyInLobby'] as bool?) ?? true,
    );
  }

  @override
  String toString() =>
      'Player($name, ring=$ringIndex, orders=$completedOrders, ready=$readyInLobby)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player &&
          id == other.id &&
          name == other.name &&
          ringIndex == other.ringIndex &&
          connected == other.connected &&
          completedOrders == other.completedOrders &&
          readyInLobby == other.readyInLobby;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    ringIndex,
    connected,
    completedOrders,
    readyInLobby,
  );
}
