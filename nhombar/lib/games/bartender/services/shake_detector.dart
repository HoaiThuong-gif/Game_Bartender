import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

/// Một mẫu gia tốc với toạ độ (x, y, z) và thời điểm tính bằng mili-giây.
class ShakeSample {
  const ShakeSample({
    required this.x,
    required this.y,
    required this.z,
    required this.timestampMs,
  });

  final double x;
  final double y;
  final double z;
  final int timestampMs;
}

/// Lớp thuần nhận diện động tác lắc điện thoại.
///
/// Hoàn toàn độc lập với phần cứng/UI: nhận chuỗi mẫu gia tốc + thời gian,
/// tính độ lớn gia tốc, lọc ngưỡng (threshold), chống nhận nhầm bằng cooldown
/// và xác định khi người chơi "đã lắc đủ".
class ShakeDetector {
  ShakeDetector({
    this.threshold = 12.0,
    this.minShakes = 3,
    this.windowMs = 1500,
    this.shakeCooldownMs = 200,
    this.triggerCooldownMs = 1000,
  });

  /// Ngưỡng gia tốc (m/s^2) coi là một chuyển động lắc mạnh.
  final double threshold;

  /// Số lần vượt ngưỡng tối thiểu cần thiết để kích hoạt "đã lắc đủ".
  final int minShakes;

  /// Cửa sổ thời gian (ms) tích lũy các lần lắc.
  final int windowMs;

  /// Khoảng cách thời gian tối thiểu (ms) giữa 2 đỉnh lắc liên tiếp (chống đếm trùng).
  final int shakeCooldownMs;

  /// Khoảng thời gian nghỉ (ms) sau khi kích hoạt thành công.
  final int triggerCooldownMs;

  final List<int> _shakeTimestamps = [];
  int? _lastPeakTimeMs;
  int? _lastTriggerTimeMs;

  /// Đưa một mẫu gia tốc vào.
  /// Trả về true nếu tại thời điểm [timestampMs] người chơi "đã lắc đủ".
  bool addSample(double x, double y, double z, int timestampMs) {
    // Nếu đang trong cooldown sau lần trigger trước, bỏ qua
    if (_lastTriggerTimeMs != null &&
        timestampMs - _lastTriggerTimeMs! < triggerCooldownMs) {
      return false;
    }

    final magnitude = sqrt(x * x + y * y + z * z);
    if (magnitude >= threshold) {
      // Chống nhận nhầm: phải cách lần lắc trước ít nhất shakeCooldownMs
      if (_lastPeakTimeMs == null ||
          timestampMs - _lastPeakTimeMs! >= shakeCooldownMs) {
        _lastPeakTimeMs = timestampMs;
        _shakeTimestamps.add(timestampMs);

        // Loại bỏ mẫu quá hạn ngoài cửa sổ windowMs
        _shakeTimestamps.removeWhere((t) => timestampMs - t > windowMs);

        if (_shakeTimestamps.length >= minShakes) {
          _lastTriggerTimeMs = timestampMs;
          _shakeTimestamps.clear();
          return true;
        }
      }
    }
    return false;
  }

  /// Đưa một danh sách mẫu gia tốc vào để đánh giá.
  /// Trả về true nếu trong chuỗi mẫu có thời điểm đạt "đã lắc đủ".
  bool evaluateSamples(List<ShakeSample> samples) {
    reset();
    for (final s in samples) {
      if (addSample(s.x, s.y, s.z, s.timestampMs)) {
        return true;
      }
    }
    return false;
  }

  /// Reset toàn bộ bộ nhớ và trạng thái nhận diện.
  void reset() {
    _shakeTimestamps.clear();
    _lastPeakTimeMs = null;
    _lastTriggerTimeMs = null;
  }
}

/// Cấu hình cảm biến lắc cho môi trường test / emulator.
class ShakeSensorConfig {
  ShakeSensorConfig._();

  /// Override tính khả dụng của cảm biến trong test hoặc môi trường emulator:
  /// - null: tự động kiểm tra (mặc định thử kết nối cảm biến thật).
  /// - true: ép cảm biến khả dụng.
  /// - false: ép cảm biến không khả dụng (hiện nút "Lắc giả lập").
  static bool? isSensorAvailableOverride;

  /// Stream gia tốc tuỳ chỉnh cho test nếu cần mô phỏng sự kiện từ Stream.
  static Stream<UserAccelerometerEvent>? customStream;

  /// Reset cấu hình cảm biến về mặc định.
  static void reset() {
    isSensorAvailableOverride = null;
    customStream = null;
  }
}
