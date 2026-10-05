/// Cấu hình runtime cho tính năng Bartender.
///
/// Cho phép chuyển đổi giữa [FakeRoomRepository] (chạy offline / dev local)
/// và [FirebaseRoomRepository] (chạy online qua RTDB nhiều máy thật).
///
/// Xem DEVELOPMENT.md mục "Phát triển local (bước 1-3, chưa cần Firebase)".
class BartenderConfig {
  const BartenderConfig._();

  /// true = dùng FakeRoomRepository trong bộ nhớ (mặc định cho giai đoạn 1-3).
  /// false = dùng FirebaseRoomRepository thật (bắt đầu từ giai đoạn 5).
  static const bool useFakeRepository = true;

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
