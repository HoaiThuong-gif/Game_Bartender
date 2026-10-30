/// Các loại backend khả dụng cho game Bartender.
enum BartenderBackend {
  /// Giả lập in-memory hoàn toàn offline (mặc định cho test và dev).
  fake,

  /// Firebase Realtime Database.
  firebase,

  /// Server API HTTP + WebSocket tự host.
  api,
}

/// Cấu hình runtime cho tính năng Bartender.
///
/// Cho phép chuyển đổi giữa [FakeRoomRepository] (chạy offline / dev local),
/// [FirebaseRoomRepository] (chạy online qua RTDB) và [ApiRoomRepository] (HTTP + WebSocket server).
///
/// Xem DEVELOPMENT.md mục "Phát triển local (bước 1-3, chưa cần Firebase)".
class BartenderConfig {
  const BartenderConfig._();

  /// Phân giải backend từ chuỗi cấu hình (ví dụ từ environment).
  /// Bất kỳ giá trị nào không xác định đều fallback về [BartenderBackend.fake].
  static BartenderBackend parseBackend(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'firebase':
        return BartenderBackend.firebase;
      case 'api':
        return BartenderBackend.api;
      case 'fake':
      default:
        return BartenderBackend.fake;
    }
  }

  /// Bộ chọn backend hiện tại.
  /// Khởi tạo từ --dart-define=BARTENDER_BACKEND=fake|firebase|api (mặc định 'fake').
  /// MẶC ĐỊNH LUÔN LÀ fake KHI KHÔNG CÓ DEFINE theo quy tắc bất biến.
  static BartenderBackend backend = parseBackend(
    const String.fromEnvironment(
      'BARTENDER_BACKEND',
      defaultValue: 'fake',
    ),
  );

  /// Cờ tương thích ngược: true nếu backend == BartenderBackend.fake.
  static bool get useFakeRepository => backend == BartenderBackend.fake;
  static set useFakeRepository(bool value) {
    backend = value ? BartenderBackend.fake : BartenderBackend.firebase;
  }

  /// URL của Bartender HTTP + WebSocket API backend.
  /// Mặc định: http://10.0.2.2:8080 (Android emulator tới localhost của máy host).
  /// Có thể ghi đè khi chạy bằng: `--dart-define=API_BASE_URL=http://192.168.1.x:8080`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

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
