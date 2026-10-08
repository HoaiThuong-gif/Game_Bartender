# Game Bartender (nhom_bar)

Đây là một dự án ứng dụng Flutter.

## Yêu cầu hệ thống (Prerequisites)

Trước khi bắt đầu, hãy đảm bảo bạn đã cài đặt các công cụ sau trên máy tính:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Khuyến nghị sử dụng phiên bản stable mới nhất)
- Android Studio hoặc VS Code (có cài đặt các extension cho Flutter & Dart)
- Máy ảo (Android Emulator / iOS Simulator) hoặc thiết bị di động thật để chạy ứng dụng.

## Cách cài đặt (Installation)

1. Mở terminal (hoặc command prompt) và di chuyển vào thư mục dự án:
   ```bash
   cd Game_Bartender
   ```

2. Tải các thư viện (dependencies) cần thiết cho dự án:
   ```bash
   flutter pub get
   ```

## Cách chạy ứng dụng (Running the app)

1. Khởi động máy ảo (Android Emulator / iOS Simulator) hoặc kết nối thiết bị thật của bạn vào máy tính.

2. (Tùy chọn) Kiểm tra xem Flutter đã nhận diện thiết bị của bạn chưa:
   ```bash
   flutter devices
   ```

3. Chạy ứng dụng ở chế độ debug:
   ```bash
   flutter run
   ```
   *Lưu ý: Bạn cũng có thể mở dự án bằng VS Code hoặc Android Studio và nhấn nút "Run/Debug".*

## Khắc phục sự cố thường gặp (Troubleshooting)

Nếu gặp lỗi trong quá trình chạy ứng dụng (ví dụ: lỗi cache, thư viện), bạn có thể thử các lệnh sau:

```bash
# Xóa thư mục build và cache của dự án
flutter clean

# Tải lại các thư viện
flutter pub get

# Chạy lại ứng dụng
flutter run
```

Để kiểm tra xem môi trường Flutter của bạn đã được thiết lập đúng cách chưa, hãy chạy:
```bash
flutter doctor
```

## Tài nguyên học tập Flutter (Resources)

Nếu đây là dự án Flutter đầu tiên của bạn, một số tài liệu sau sẽ rất hữu ích:
- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter API reference](https://docs.flutter.dev/reference/)
