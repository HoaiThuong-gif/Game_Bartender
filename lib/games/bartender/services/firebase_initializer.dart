import 'package:firebase_core/firebase_core.dart';

/// Khởi động Firebase app một lần duy nhất khi app khởi chạy.
///
/// Phải gọi trước khi dùng [FirebaseRoomRepository].
/// File này chỉ được import bởi BartenderController hoặc BartenderScreen
/// khi [BartenderConfig.useFakeRepository] == false.
///
/// firebase_options.dart được tạo tự động bởi `flutterfire configure`
/// và KHÔNG commit vào git (chứa API key) — xem .gitignore.
///
/// Để xoá Firebase hoàn toàn:
///   1. Xoá file này
///   2. Xoá firebase_room_repository.dart
///   3. Xoá 3 dòng Firebase trong pubspec.yaml
///   4. Xoá firebase_options.dart + google-services.json
class BartenderFirebaseInitializer {
  BartenderFirebaseInitializer._();

  static bool _initialized = false;

  /// Khởi động Firebase. Gọi idempotent (an toàn khi gọi nhiều lần).
  ///
  /// [options]: truyền vào từ firebase_options.dart được sinh bởi FlutterFire CLI.
  /// Ví dụ:
  /// ```dart
  /// await BartenderFirebaseInitializer.initialize(
  ///   options: DefaultFirebaseOptions.currentPlatform,
  /// );
  /// ```
  static Future<void> initialize({FirebaseOptions? options}) async {
    if (_initialized) return;

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: options);
    }

    _initialized = true;
  }
}
