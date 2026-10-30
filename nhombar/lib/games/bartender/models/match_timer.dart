/// Đồng hồ đếm ngược chung của trận đấu.
///
/// - Bắt đầu ở 60 giây.
/// - Chỉ dùng để KẾT THÚC trận khi về 0.
/// - Hoàn thành đơn → +5 giây.
///
/// tuyệt đối endTime, mỗi client tự tính thời gian còn lại."
///
class MatchTimer {
  const MatchTimer({
    required this.endTime,
    required this.startedAt,
    this.serverOffsetMs = 0,
    this.isPreparing = false,
    this.readyPlayerIds = const {},
  });

  /// Thời điểm trận kết thúc (mốc tuyệt đối, milliseconds since epoch).
  /// Client tính thời gian còn lại = endTime - (now + offset).
  /// Firebase lưu dạng server timestamp.
  final int endTime;

  /// Thời điểm trận bắt đầu (milliseconds since epoch).
  final int startedAt;

  /// Độ lệch giữa đồng hồ client và server (ms).
  /// Dương = server nhanh hơn client; âm = server chậm hơn client.
  /// Mặc định 0 (dùng khi Fake hoặc chưa fetch được).
  final int serverOffsetMs;

  /// An opt-in shared preparation phase. The clock is frozen until all peers report ready.
  final bool isPreparing;
  final Set<String> readyPlayerIds;
  static const countdownMs = 3000;

  factory MatchTimer.prepare({required int nowMs, int serverOffsetMs = 0}) =>
      MatchTimer(
        startedAt: nowMs + serverOffsetMs,
        endTime: nowMs + serverOffsetMs + initialDurationMs,
        serverOffsetMs: serverOffsetMs,
        isPreparing: true,
      );

  MatchTimer markSceneReady({
    required String playerId,
    required Set<String> connectedPlayerIds,
    required int nowMs,
  }) {
    if (!isPreparing || !connectedPlayerIds.contains(playerId)) return this;
    final ready = {...readyPlayerIds, playerId};
    if (connectedPlayerIds.length >= 2 &&
        connectedPlayerIds.every(ready.contains)) {
      return MatchTimer.start(
        nowMs: nowMs + countdownMs,
        serverOffsetMs: serverOffsetMs,
      );
    }
    return MatchTimer(
      startedAt: startedAt,
      endTime: endTime,
      serverOffsetMs: serverOffsetMs,
      isPreparing: true,
      readyPlayerIds: Set.unmodifiable(ready),
    );
  }

  bool hasStarted({required int nowMs}) =>
      !isPreparing && nowMs + serverOffsetMs >= startedAt;
  int startsInSeconds({required int nowMs}) {
    if (isPreparing) return 0;
    final remaining = startedAt - nowMs - serverOffsetMs;
    return remaining <= 0 ? 0 : (remaining + 999) ~/ 1000;
  }

  static const int initialDurationMs = 60 * 1000;

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

  Map<String, dynamic> toJson() => {
    'startedAt': startedAt,
    'endTime': endTime,
    if (isPreparing) 'preparing': true,
    if (isPreparing)
      'readyPlayers': {for (final id in readyPlayerIds) id: true},
  };

  /// Khởi tạo từ JSON map.
  factory MatchTimer.fromJson(
    Map<String, dynamic> json, {
    int serverOffsetMs = 0,
  }) {
    return MatchTimer(
      startedAt: (json['startedAt'] as num).toInt(),
      endTime: (json['endTime'] as num).toInt(),
      serverOffsetMs: serverOffsetMs,
      isPreparing: json['preparing'] == true,
      readyPlayerIds: Set.unmodifiable(
        ((json['readyPlayers'] as Map?) ?? {}).entries
            .where((e) => e.value == true)
            .map((e) => e.key.toString()),
      ),
    );
  }

  /// Tính thời gian còn lại (milliseconds). Trả về 0 nếu đã hết giờ.
  ///
  /// [nowMs]: thời điểm hiện tại (client clock).
  /// serverOffsetMs đã được lưu trong instance.
  int remainingMs({required int nowMs}) {
    if (isPreparing) return initialDurationMs;
    final correctedNow = nowMs + serverOffsetMs;
    final remaining =
        endTime - (correctedNow < startedAt ? startedAt : correctedNow);
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
      isPreparing: isPreparing,
      readyPlayerIds: readyPlayerIds,
    );
  }

  /// Tổng thời gian sống sót (giây) — dùng cho màn hình kết quả.
  int totalSurvivalSeconds({required int nowMs}) {
    if (isPreparing) return 0;
    final serverNow = nowMs + serverOffsetMs;
    final effectiveEnd = serverNow < endTime ? serverNow : endTime;
    final elapsed = effectiveEnd - startedAt;
    return (elapsed / 1000).round().clamp(0, 999);
  }

  @override
  String toString() =>
      'MatchTimer(end=$endTime, started=$startedAt, offset=$serverOffsetMs)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchTimer &&
          startedAt == other.startedAt &&
          endTime == other.endTime &&
          serverOffsetMs == other.serverOffsetMs &&
          isPreparing == other.isPreparing &&
          readyPlayerIds.length == other.readyPlayerIds.length &&
          readyPlayerIds.containsAll(other.readyPlayerIds);

  @override
  int get hashCode => Object.hash(
    startedAt,
    endTime,
    serverOffsetMs,
    isPreparing,
    Object.hashAll(readyPlayerIds.toList()..sort()),
  );
}
