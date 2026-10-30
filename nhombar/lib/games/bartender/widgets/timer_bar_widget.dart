import 'package:flutter/material.dart';

/// Thanh hiển thị đồng hồ chung, số round và tổng số đơn cả đội đã nộp.
///
/// Xem PROJECT_SPEC.md:
/// - Đồng hồ đếm ngược chung bắt đầu ở 60s, kết thúc trận khi về 0.
/// - Hoàn thành đơn cộng +5s.
/// - Round độc lập với đồng hồ chung.
class TimerBarWidget extends StatelessWidget {
  const TimerBarWidget({
    super.key,
    required this.remainingSeconds,
    required this.roundNumber,
    required this.teamOrders,
    this.initialSeconds = 60,
  });

  final int remainingSeconds;
  final int roundNumber;
  final int teamOrders;
  final int initialSeconds;

  @override
  Widget build(BuildContext context) {
    final isLowTime = remainingSeconds <= 15;
    final isCriticalTime = remainingSeconds <= 7;

    final timerColor = isCriticalTime
        ? Colors.redAccent
        : isLowTime
            ? Colors.orangeAccent
            : Colors.greenAccent.shade400;

    final progress = (remainingSeconds / initialSeconds).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isLowTime ? timerColor.withValues(alpha: 0.6) : Colors.white12,
          width: isLowTime ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              // Badge Round
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'ROUND $roundNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Countdown Timer
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    size: 20,
                    color: timerColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${remainingSeconds}s',
                    style: TextStyle(
                      color: timerColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),

              // Tổng đơn của đội
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_bar, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'ĐỘI: $teamOrders',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Thanh tiến trình thời gian
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
