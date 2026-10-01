/// Đồng hồ đếm ngược chung của trận đấu.
///
/// Xem PROJECT_SPEC.md mục "Vòng lặp trận đấu":
/// - Bắt đầu ở 60 giây.
/// - Chỉ dùng để KẾT THÚC trận khi về 0.
/// - Hoàn thành đơn → +5 giây.
///
/// Xem ARCHITECTURE.md: "Đồng hồ chung đồng bộ dưới dạng mốc thời gian
/// tuyệt đối endTime, mỗi client tự tính thời gian còn lại."
///
/// Xem API.md: timer/endTime, timer/startedAt.
class MatchTimer {
  const MatchTimer({
    required this.endTime,
    required this.startedAt,
  });

  /// Thời điểm trận kết thúc (mốc tuyệt đối, milliseconds since epoch).
  /// Client tính thời gian còn lại = endTime - now.
  /// Firebase lưu dạng server timestamp.
  final int endTime;

  /// Thời điểm trận bắt đầu (milliseconds since epoch).
  final int startedAt;

  /// Thời gian ban đầu (mặc định 60 giây) — xem PROJECT_SPEC.md.
  static const int initialDurationMs = 60 * 1000;

  /// Số giây được cộng mỗi khi hoàn thành một đơn — xem PROJECT_SPEC.md.
  static const int bonusMs = 5 * 1000;

  /// Tạo timer mới, bắt đầu từ bây giờ với 60 giây.
  ///
  /// [nowMs]: thời điểm hiện tại (milliseconds since epoch).
  /// Inject được để test deterministic.
  factory MatchTimer.start({required int nowMs}) {
    return MatchTimer(
      startedAt: nowMs,
      endTime: nowMs + initialDurationMs,
    );
  }

  /// Tính thời gian còn lại (milliseconds). Trả về 0 nếu đã hết giờ.
  ///
  /// [nowMs]: thời điểm hiện tại.
  /// [serverOffsetMs]: độ lệch giữa đồng hồ client và server
  ///   (Firebase .info/serverTimeOffset). Mặc định = 0.
  int remainingMs({required int nowMs, int serverOffsetMs = 0}) {
    final correctedNow = nowMs + serverOffsetMs;
    final remaining = endTime - correctedNow;
    return remaining > 0 ? remaining : 0;
  }

  /// Trận đã hết giờ chưa.
  bool isExpired({required int nowMs, int serverOffsetMs = 0}) {
    return remainingMs(nowMs: nowMs, serverOffsetMs: serverOffsetMs) == 0;
  }

  /// Tạo bản sao với endTime được cộng thêm bonus (+5 giây).
  /// Gọi khi một người chơi hoàn thành đơn.
  MatchTimer withBonus() {
    return MatchTimer(
      startedAt: startedAt,
      endTime: endTime + bonusMs,
    );
  }

  /// Tổng thời gian sống sót (giây) — dùng cho màn hình kết quả.
  int totalSurvivalSeconds({required int nowMs}) {
    final elapsed = nowMs - startedAt;
    return (elapsed / 1000).round();
  }

  @override
  String toString() => 'MatchTimer(end=$endTime, started=$startedAt)';
}
