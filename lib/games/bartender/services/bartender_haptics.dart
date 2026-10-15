import 'package:flutter/services.dart';

/// Lớp bọc HapticFeedback cho game Bartender.
///
/// Bọc các phản hồi rung cho 3 sự kiện chính:
/// 1. Nộp đơn đúng ([orderSubmitted])
/// 2. Bỏ đồ vào thùng rác ([itemTrashed])
/// 3. Hết giờ ([timeExpired])
///
/// Có thể bật/tắt hoặc giả lập callback trong test.
class BartenderHaptics {
  BartenderHaptics._();

  /// Cho phép bật/tắt rung toàn cục (mặc định bật).
  static bool enabled = true;

  /// Callback giả lập để test: nhận tên sự kiện ('orderSubmitted', 'itemTrashed', 'timeExpired').
  static void Function(String event)? onHaptic;

  /// Rung khi nộp đơn đúng: medium impact xác nhận hoàn thành đơn.
  static Future<void> orderSubmitted() async {
    if (!enabled) return;
    onHaptic?.call('orderSubmitted');
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {
      // Bỏ qua nếu nền tảng không hỗ trợ rung
    }
  }

  /// Rung khi bỏ đồ vào thùng rác: light impact xác nhận xoá vật phẩm.
  static Future<void> itemTrashed() async {
    if (!enabled) return;
    onHaptic?.call('itemTrashed');
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Bỏ qua nếu nền tảng không hỗ trợ rung
    }
  }

  /// Rung khi hết giờ: heavy impact cảnh báo kết thúc trận.
  static Future<void> timeExpired() async {
    if (!enabled) return;
    onHaptic?.call('timeExpired');
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {
      // Bỏ qua nếu nền tảng không hỗ trợ rung
    }
  }

  /// Reset cấu hình về mặc định (dùng sau mỗi test).
  static void reset() {
    enabled = true;
    onHaptic = null;
  }
}
