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
    this.progress = const {},
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

  /// Tien do hoan thanh don theo ringIndex (key la ringIndex, value la so don da xong).
  /// Khớp với API.md: round/progress/{ringIndex}
  final Map<int, int> progress;

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
    Map<int, int>? progress,
  }) {
    return Round(
      number: number ?? this.number,
      ordersPerPlayer: ordersPerPlayer ?? this.ordersPerPlayer,
      stationAssignment: stationAssignment ?? this.stationAssignment,
      playerOrders: playerOrders ?? this.playerOrders,
      progress: progress ?? this.progress,
    );
  }

  /// Chuyển thành JSON map khớp với API.md.
  Map<String, dynamic> toJson() => {
    'number': number,
    'ordersPerPlayer': ordersPerPlayer,
    'stationAssignment': stationAssignment.map(
      (k, v) => MapEntry(k.toString(), v?.name),
    ),
    'progress': progress.map((k, v) => MapEntry(k.toString(), v)),
    'playerOrders': playerOrders.map(
      (k, v) => MapEntry(k, v.map((o) => o.toJson()).toList()),
    ),
  };

  /// Khởi tạo từ JSON map.
  factory Round.fromJson(Map<String, dynamic> json) {
    final rawAssignments =
        (json['stationAssignment'] as Map<String, dynamic>?) ?? {};
    final stationAssignment = rawAssignments.map((k, v) {
      final ring = int.parse(k);
      final station = v != null ? StationType.values.byName(v as String) : null;
      return MapEntry(ring, station);
    });

    final rawProgress = (json['progress'] as Map<String, dynamic>?) ?? {};
    final progress = rawProgress.map((k, v) {
      return MapEntry(int.parse(k), (v as num).toInt());
    });

    final rawOrders = (json['playerOrders'] as Map<String, dynamic>?) ?? {};
    final playerOrders = rawOrders.map((k, v) {
      final list = (v as List<dynamic>)
          .map((o) => Order.fromJson(o as Map<String, dynamic>))
          .toList();
      return MapEntry(k, list);
    });

    return Round(
      number: (json['number'] as num?)?.toInt() ?? 1,
      ordersPerPlayer: (json['ordersPerPlayer'] as num?)?.toInt() ?? 3,
      stationAssignment: stationAssignment,
      playerOrders: playerOrders,
      progress: progress,
    );
  }

  @override
  String toString() =>
      'Round(#$number, ordersPerPlayer=$ordersPerPlayer, '
      'complete=$isComplete)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Round &&
          number == other.number &&
          ordersPerPlayer == other.ordersPerPlayer &&
          _mapEquals(stationAssignment, other.stationAssignment) &&
          _mapEquals(progress, other.progress) &&
          _playerOrdersEquals(playerOrders, other.playerOrders);

  @override
  int get hashCode => Object.hash(
    number,
    ordersPerPlayer,
    Object.hashAll(stationAssignment.entries),
    Object.hashAll(progress.entries),
  );

  static bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  static bool _playerOrdersEquals(
    Map<String, List<Order>> a,
    Map<String, List<Order>> b,
  ) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      final bList = b[entry.key];
      if (bList == null || bList.length != entry.value.length) return false;
      for (var i = 0; i < entry.value.length; i++) {
        if (entry.value[i] != bList[i]) return false;
      }
    }
    return true;
  }
}
