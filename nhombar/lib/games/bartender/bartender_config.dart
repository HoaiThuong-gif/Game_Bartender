/// Cấu hình runtime cho tính năng Bartender.
///
/// Cho phép chuyển đổi giữa FakeRoomRepository (offline)
/// và ApiRoomRepository (backend HTTP độc lập).
///
/// Hướng dẫn hiện tại ở README gốc và backend/README.md (D20).
class BartenderConfig {
  const BartenderConfig._();

  /// Mặc định online qua API. Chỉ bật bot bằng BARTENDER_OFFLINE=true.
  static const bool useFakeRepository = bool.fromEnvironment(
    'BARTENDER_OFFLINE',
  );

  /// Cấu hình cũ chỉ dùng cho FirebaseRoomRepository, không dùng ở luồng API.
  /// URL của Firebase Realtime Database dùng chung với dự án nhom-bar (D18).
  ///
  /// Lấy từ --dart-define=DATABASE_URL khi chạy:
  ///   flutter run --dart-define=DATABASE_URL=https://nhom-bar-default-rtdb.asia-southeast1.firebasedatabase.app
  /// Fallback: dùng RUBIK_DATABASE_URL nếu có, cuối cùng dùng giá trị cứng.
  /// Không có dấu '/' cuối URL.
  static const String databaseUrl = String.fromEnvironment(
    'DATABASE_URL',
    defaultValue: String.fromEnvironment(
      'RUBIK_DATABASE_URL',
      defaultValue:
          'https://nhom-bar-default-rtdb.asia-southeast1.firebasedatabase.app',
    ),
  );

  /// Số giây khởi đầu của đồng hồ chung. Mặc định 60 giây.
  /// Xem PROJECT_SPEC.md: "đồng hồ đếm ngược chung, bắt đầu ở 60 giây".
  static const int initialTimerSeconds = 60;

  /// Số giây cộng thêm khi hoàn thành một đơn hàng.
  /// Xem PROJECT_SPEC.md: "+5 giây vào đồng hồ chung".
  static const int orderCompletionBonusSeconds = 5;

  /// Chu kỳ xuất hiện nguyên liệu mới (giây).
  /// Xem PROJECT_SPEC.md: "khoảng 3 giây một lần".
  static const int ingredientSpawnIntervalSeconds = 3;

  /// Số đơn hàng mỗi người chơi cần hoàn thành trong một round.
  /// Xem PROJECT_SPEC.md: "mục tiêu: 3".
  static const int ordersPerPlayer = 3;

  /// Số lượng người chơi tối đa trong một phòng.
  static const int maxPlayers = 4;
}
