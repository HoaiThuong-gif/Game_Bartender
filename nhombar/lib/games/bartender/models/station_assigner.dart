import 'dart:math';

import 'station.dart';

/// Phân công trạm chế biến ngẫu nhiên cho mỗi round.
///
/// Xem PROJECT_SPEC.md mục "Trạm chế biến":
/// "Mỗi round, trạm được phân ngẫu nhiên cho người chơi."
///
/// Xem DECISIONS.md D5:
/// "Chấp nhận việc hai người cùng loại trạm hoặc một người không có trạm nào,
/// kể cả khi chỉ 2-4 người."
///
/// Logic tổng quát cho N người bất kỳ.
class StationAssigner {
  StationAssigner._();

  /// Phân ngẫu nhiên trạm cho [playerCount] người chơi.
  ///
  /// Trả về `Map<ringIndex, StationType?>`.
  /// Giá trị null nghĩa là người chơi đó không có trạm round này.
  ///
  /// [playerCount]: số người chơi (≥ 2).
  /// [random]: nguồn random, inject được để test deterministic.
  static Map<int, StationType?> assign({
    required int playerCount,
    Random? random,
  }) {
    assert(playerCount >= 2, 'Cần ít nhất 2 người chơi');

    final rng = random ?? Random();
    final stations = StationType.values;

    // Mỗi người chơi được gán ngẫu nhiên một trạm từ pool.
    // Có thể trùng (2 người cùng trạm) hoặc thiếu (không phải
    // mọi loại trạm đều được dùng) — đúng theo DECISIONS.md D5.
    final assignment = <int, StationType?>{};
    for (var i = 0; i < playerCount; i++) {
      // Mỗi người có xác suất (stations.length / (stations.length + 1))
      // được gán trạm. Còn lại = không có trạm (null).
      // Ví dụ: 4 trạm → 80% có trạm, 20% không.
      // Điều này tạo ra khả năng "không có trạm" được đề cập
      // trong DECISIONS.md D5.
      final roll = rng.nextInt(stations.length + 1);
      if (roll < stations.length) {
        assignment[i] = stations[roll];
      } else {
        assignment[i] = null; // Không có trạm round này.
      }
    }

    return assignment;
  }
}
