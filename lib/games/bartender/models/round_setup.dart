import 'dart:math';

import 'recipe.dart';
import 'recipe_pool.dart';
import 'station.dart';

/// Kết quả của một lần tạo phân trạm + đơn cho một round.
///
/// Xem DECISIONS.md D15: phân trạm ngẫu nhiên nhưng đảm bảo round luôn làm được.
/// Hàm thuần — không phụ thuộc Firebase, dùng chung cho Fake và Firebase.
class RoundSetup {
  const RoundSetup({
    required this.stationAssignment,
    required this.feasibleRecipes,
  });

  /// Trạm được phân cho mỗi ringIndex (key = ringIndex, value = StationType? hoặc null).
  final Map<int, StationType?> stationAssignment;

  /// Các công thức có thể thực hiện được với phân trạm này.
  /// Đảm bảo luôn có ít nhất 1 công thức (D15).
  final List<Recipe> feasibleRecipes;

  /// Công thức làm được với MỘT phân trạm có sẵn (D15). Hàm thuần, không random.
  static List<Recipe> feasibleFor({
    required Map<int, StationType?> assignment,
    required int roundNumber,
  }) {
    final assigned = assignment.values.whereType<StationType>().toSet();
    return RecipePool.recipesForRound(roundNumber)
        .where((r) => r.steps.every((s) => assigned.contains(s.station)))
        .toList();
  }

  /// Tạo phân trạm và lọc công thức khả thi cho một round.
  ///
  /// D15: Chọn "mỏ neo" — recipe đảm bảo có thể làm được.
  /// Giao các trạm của recipe mỏ neo cho các người KHÁC NHAU (distinct).
  /// Người còn lại nhận trạm ngẫu nhiên hoặc không có (D5).
  /// Công thức khả thi = tất cả recipe mà mọi bước đều có trạm trong phân công.
  ///
  /// [playerIds]: danh sách player ID theo thứ tự (index = ringIndex).
  /// [roundNumber]: số round để lấy đúng pool (D7).
  /// [rng]: nguồn random inject được để test deterministic.
  static RoundSetup generate({
    required List<String> playerIds,
    required int roundNumber,
    Random? rng,
  }) {
    assert(playerIds.length >= 2, 'Cần ít nhất 2 người chơi');
    final random = rng ?? Random();
    final playerCount = playerIds.length;

    // Lấy pool công thức cho round này (D7)
    final roundRecipes = RecipePool.recipesForRound(roundNumber);

    // Lọc các công thức có số loại trạm khác nhau <= số người chơi
    // (D15: mỏ neo phải có đủ người để giao từng trạm)
    final anchorCandidates = roundRecipes.where((r) {
      final distinctStations = r.steps.map((s) => s.station).toSet();
      return distinctStations.length <= playerCount;
    }).toList();

    // Phải có ít nhất 1 mỏ neo (thiết kế đảm bảo: D16 = max 3 trạm, min 2 người)
    assert(anchorCandidates.isNotEmpty, 'Không có công thức nào phù hợp cho $playerCount người');

    // Chọn mỏ neo ngẫu nhiên
    final anchor = anchorCandidates[random.nextInt(anchorCandidates.length)];

    // Tập các trạm khác nhau của mỏ neo (theo thứ tự xuất hiện)
    final anchorStations = <StationType>[];
    for (final step in anchor.steps) {
      if (!anchorStations.contains(step.station)) {
        anchorStations.add(step.station);
      }
    }

    // Chọn ngẫu nhiên [anchorStations.length] người để giao trạm mỏ neo
    // (mỗi người một trạm khác nhau, không trùng)
    final ringIndices = List<int>.generate(playerCount, (i) => i);
    ringIndices.shuffle(random);
    final anchorRings = ringIndices.take(anchorStations.length).toList();

    // Tạo assignment ban đầu
    final assignment = <int, StationType?>{
      for (var i = 0; i < playerCount; i++) i: null,
    };

    // Giao trạm mỏ neo cho các ring được chọn
    for (var i = 0; i < anchorStations.length; i++) {
      assignment[anchorRings[i]] = anchorStations[i];
    }

    // Người còn lại (chưa được giao) nhận trạm ngẫu nhiên hoặc null (D5)
    final allStations = StationType.values;
    for (var i = 0; i < playerCount; i++) {
      if (!anchorRings.contains(i)) {
        // Xác suất có trạm = stations.length / (stations.length + 1) (D5)
        final roll = random.nextInt(allStations.length + 1);
        assignment[i] = roll < allStations.length ? allStations[roll] : null;
      }
    }

    final feasible = feasibleFor(assignment: assignment, roundNumber: roundNumber);

    // Đảm bảo luôn có mỏ neo trong feasible (kiểm tra logic)
    assert(
      feasible.any((r) => r.id == anchor.id),
      'Mỏ neo ${anchor.id} phải luôn có trong feasible recipes',
    );

    return RoundSetup(
      stationAssignment: assignment,
      feasibleRecipes: feasible,
    );
  }
}
