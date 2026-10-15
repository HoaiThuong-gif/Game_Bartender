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
/// Xem DECISIONS.md D17: endTime dùng ServerValue.timestamp + serverTimeOffset.
class MatchTimer {
  const MatchTimer({
    required this.endTime,
    required this.startedAt,
    this.serverOffsetMs = 0,
  });

  /// Thời điểm trận kết thúc (mốc tuyệt đối, milliseconds since epoch).
  /// Client tính thời gian còn lại = endTime - (now + offset).
  /// Firebase lưu dạng server timestamp.
  final int endTime;

  /// Thời điểm trận bắt đầu (milliseconds since epoch).
  final int startedAt;

  /// Độ lệch giữa đồng hồ client và server (ms).
  /// Lấy từ Firebase .info/serverTimeOffset (ARCHITECTURE.md, Bước 6).
  /// Dương = server nhanh hơn client; âm = server chậm hơn client.
  /// Mặc định 0 (dùng khi Fake hoặc chưa fetch được).
  final int serverOffsetMs;

  /// Thời gian ban đầu (mặc định 60 giây) — xem PROJECT_SPEC.md.
  static const int initialDurationMs = 60 * 1000;

  /// Số giây được cộng mỗi khi hoàn thành một đơn — xem PROJECT_SPEC.md.
  static const int bonusMs = 5 * 1000;

  /// Tạo timer mới, bắt đầu từ bây giờ với 60 giây.
  ///
  /// [nowMs]: thời điểm hiện tại (milliseconds since epoch).
  /// Inject được để test deterministic.
  factory MatchTimer.start({required int nowMs, int serverOffsetMs = 0}) {
    final correctedNow = nowMs + serverOffsetMs;
    return MatchTimer(
      startedAt: correctedNow,
      endTime: correctedNow + initialDurationMs,
      serverOffsetMs: serverOffsetMs,
    );
  }

  /// Tính thời gian còn lại (milliseconds). Trả về 0 nếu đã hết giờ.
  ///
  /// [nowMs]: thời điểm hiện tại (client clock).
  /// serverOffsetMs đã được lưu trong instance.
  int remainingMs({required int nowMs}) {
    final correctedNow = nowMs + serverOffsetMs;
    final remaining = endTime - correctedNow;
    return remaining > 0 ? remaining : 0;
  }

  /// Trận đã hết giờ chưa.
  bool isExpired({required int nowMs}) {
    return remainingMs(nowMs: nowMs) == 0;
  }

  /// Tạo bản sao với endTime được cộng thêm bonus (+5 giây).
  /// Gọi khi một người chơi hoàn thành đơn.
  MatchTimer withBonus() {
    return MatchTimer(
      startedAt: startedAt,
      endTime: endTime + bonusMs,
      serverOffsetMs: serverOffsetMs,
    );
  }

  /// Tổng thời gian sống sót (giây) — dùng cho màn hình kết quả.
  /// survivalSeconds = min(serverNow, endTime) − startedAt (ARCHITECTURE.md, Bước 6)
  int totalSurvivalSeconds({required int nowMs}) {
    final serverNow = nowMs + serverOffsetMs;
    final effectiveEnd = serverNow < endTime ? serverNow : endTime;
    final elapsed = effectiveEnd - startedAt;
    return (elapsed / 1000).round().clamp(0, 999);
  }

  @override
  String toString() =>
      'MatchTimer(end=$endTime, started=$startedAt, offset=$serverOffsetMs)';
}
