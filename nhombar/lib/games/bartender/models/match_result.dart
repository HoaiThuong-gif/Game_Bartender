import 'player.dart';

/// Kết quả cuối trận — hiển thị trên màn hình kết quả.
///
/// Xem PROJECT_SPEC.md mục "Kết thúc trận":
/// "Hiển thị tổng thời gian sống sót, tổng số đơn cả đội,
/// và bảng xếp hạng cá nhân theo số đơn đã hoàn thành."
///
/// Xem API.md: rooms/{code}/results/
class MatchResult {
  const MatchResult({
    required this.totalSurvivalSeconds,
    required this.totalTeamOrders,
    required this.ranking,
  });

  /// Tổng thời gian sống sót (giây).
  final int totalSurvivalSeconds;

  /// Tổng số đơn cả đội đã hoàn thành.
  final int totalTeamOrders;

  /// Bảng xếp hạng cá nhân — sắp giảm dần theo completedOrders.
  final List<Player> ranking;

  /// Tạo kết quả từ danh sách người chơi và thời gian sống sót.
  factory MatchResult.fromPlayers({
    required List<Player> players,
    required int survivalSeconds,
  }) {
    // Sắp giảm dần theo số đơn hoàn thành.
    final sorted = List<Player>.of(players)
      ..sort((a, b) => b.completedOrders.compareTo(a.completedOrders));

    final totalOrders =
        players.fold<int>(0, (sum, p) => sum + p.completedOrders);

    return MatchResult(
      totalSurvivalSeconds: survivalSeconds,
      totalTeamOrders: totalOrders,
      ranking: sorted,
    );
  }

  @override
  String toString() =>
      'MatchResult(survival=${totalSurvivalSeconds}s, '
      'teamOrders=$totalTeamOrders, '
      'players=${ranking.length})';
}
