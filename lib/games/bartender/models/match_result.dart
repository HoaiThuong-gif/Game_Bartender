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

  /// Chuyển thành JSON map khớp với API.md schema results.
  Map<String, dynamic> toJson() => {
        'totalSurvivalSeconds': totalSurvivalSeconds,
        'totalTeamOrders': totalTeamOrders,
        'ranking': ranking
            .map((p) => {
                  'playerId': p.id,
                  'name': p.name,
                  'completedOrders': p.completedOrders,
                  'ringIndex': p.ringIndex,
                })
            .toList(),
      };

  /// Khởi tạo từ JSON map.
  factory MatchResult.fromJson(Map<String, dynamic> json) {
    final rankingList = (json['ranking'] as List<dynamic>? ?? []).map((e) {
      final map = e as Map<String, dynamic>;
      return Player(
        id: (map['playerId'] ?? map['id'] ?? '') as String,
        name: (map['name'] ?? '') as String,
        ringIndex: (map['ringIndex'] as num?)?.toInt() ?? 0,
        completedOrders: (map['completedOrders'] as num?)?.toInt() ?? 0,
        connected: (map['connected'] as bool?) ?? true,
        readyInLobby: (map['readyInLobby'] as bool?) ?? true,
      );
    }).toList();
    return MatchResult(
      totalSurvivalSeconds:
          (json['totalSurvivalSeconds'] as num?)?.toInt() ?? 0,
      totalTeamOrders: (json['totalTeamOrders'] as num?)?.toInt() ?? 0,
      ranking: rankingList,
    );
  }

  @override
  String toString() =>
      'MatchResult(survival=${totalSurvivalSeconds}s, '
      'teamOrders=$totalTeamOrders, '
      'players=${ranking.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchResult &&
          totalSurvivalSeconds == other.totalSurvivalSeconds &&
          totalTeamOrders == other.totalTeamOrders &&
          _listEquals(ranking, other.ranking);

  @override
  int get hashCode => Object.hash(
        totalSurvivalSeconds,
        totalTeamOrders,
        Object.hashAll(ranking),
      );

  static bool _listEquals(List<Player> a, List<Player> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
