# Cozy Cat 🐱

Cozy Cat là dự án ứng dụng được phát triển bằng Flutter, sử dụng Dart và các tài nguyên trong thư mục `assets/`.

## 1. Yêu cầu cài đặt

- Flutter SDK
- Dart SDK (đi kèm Flutter)
- Android Studio hoặc Visual Studio Code
- Android SDK và thiết bị Android hoặc máy ảo phù hợp

## 2. Cài đặt dự án

Clone repository:

```bash
git clone -b feature/cozy-cat https://github.com/HoaiThuong-gif/Game_Bartender.git
cd Game_Bartender
```

Cài đặt dependencies:

```bash
flutter pub get
```

Kiểm tra môi trường:

```bash
flutter doctor
```

## 3. Chạy ứng dụng

Kết nối thiết bị Android hoặc mở máy ảo, sau đó chạy:

```bash
flutter devices
flutter run
```

Có thể chọn thiết bị trực tiếp trong Android Studio và nhấn Run.

## 4. Cấu trúc dự án

- `lib/main.dart`: Mã nguồn chính.
- `assets/`: Tài nguyên sử dụng trong ứng dụng.
- `android/`: Cấu hình ứng dụng Android.
- `test/`: Các bài kiểm thử.
- `pubspec.yaml`: Khai báo dependencies và tài nguyên.

## 5. Lưu ý

- Không upload các thư mục build và cache.
- Chạy `flutter pub get` sau khi clone.
- Đảm bảo tài nguyên trong `assets/` được khai báo đúng trong `pubspec.yaml`.
- Một số tính năng có thể yêu cầu cấu hình hoặc thiết bị tương thích.

## 6. Công nghệ

Flutter, Dart.