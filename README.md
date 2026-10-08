# HƯỚNG DẪN TẢI, CÀI ĐẶT VÀ CHẠY DỰ ÁN GAME BARTENDER

Tài liệu này hướng dẫn từng bước cách tải mã nguồn, cài đặt các công cụ cần thiết và chạy dự án Game Bartender trên máy tính Windows bằng Flutter.

## Yêu cầu hệ thống

| Hạng mục | Yêu cầu |
| --- | --- |
| Hệ điều hành | Windows 10 hoặc 11, 64-bit |
| Cấu hình | RAM từ 8 GB, Card đồ họa hỗ trợ OpenGL/WebGL |
| Công cụ 3D | **Blender 4.x** (Bắt buộc để sinh và điều chỉnh mô hình 3D) |
| Môi trường Build| **Node.js LTS** (Bắt buộc để đóng gói thư viện Three.js) |
| Flutter SDK | Bản **stable** mới nhất |
| IDE | Android Studio (kèm SDK), VS Code |
| Thiết bị chạy | Máy ảo Android hoặc điện thoại thật (Ưu tiên điện thoại để render 3D mượt hơn) |

## Bước 1. Cài đặt Flutter SDK

1. Truy cập trang chính thức: https://docs.flutter.dev/install
2. Chọn hệ điều hành Windows.
3. Tải và cài đặt Flutter SDK theo hướng dẫn trên trang.
4. Cấu hình biến môi trường PATH để máy tính nhận diện lệnh Flutter.
5. Mở PowerShell và nhập:

```bash
flutter --version
```

Nếu màn hình hiển thị phiên bản Flutter, quá trình cài đặt đã thành công.

## Bước 2. Cài đặt Android Studio

1. Truy cập: https://developer.android.com/studio
2. Tải Android Studio dành cho Windows.
3. Mở tệp cài đặt và làm theo hướng dẫn.
4. Khởi động Android Studio.
5. Kiểm tra và cài đặt Android SDK cùng các công cụ cần thiết trong SDK Manager.
6. Mở PowerShell và nhập:

```bash
flutter doctor -v
```

Kiểm tra mục Android toolchain và xử lý các thông báo yêu cầu bổ sung thành phần.

Nếu Flutter yêu cầu chấp nhận giấy phép Android, chạy:

```bash
flutter doctor --android-licenses
```

Sau đó làm theo hướng dẫn trên màn hình.

## Bước 3. Cài đặt Visual Studio Code

1. Truy cập: https://code.visualstudio.com/download
2. Tải và cài đặt Visual Studio Code.
3. Mở Visual Studio Code.
4. Chọn Extensions ở thanh công cụ bên trái.
5. Tìm kiếm và cài đặt tiện ích Flutter do Dart Code phát hành. Tiện ích Dart sẽ được cài đặt kèm nếu cần.

## Bước 4. Tải mã nguồn dự án từ GitHub

1. Truy cập kho lưu trữ GitHub của nhóm: https://github.com/HoaiThuong-gif/Game_Bartender.git
2. Nhấn nút Code.
3. Chọn Download ZIP.
4. Sau khi tải hoàn tất, giải nén tệp ZIP.
5. Mở Visual Studio Code.
6. Chọn File → Open Folder.
7. Chọn thư mục dự án vừa giải nén, là thư mục chứa tệp "pubspec.yaml".

## Bước 5. Cài đặt các thư viện của dự án

1. Trong Visual Studio Code, chọn Terminal → New Terminal.
2. Đảm bảo cửa sổ dòng lệnh đang ở thư mục gốc của dự án.
3. Nhập:

```bash
flutter pub get
```

4. Chờ quá trình tải các thư viện hoàn tất.

Nếu lệnh thực hiện thành công và không xuất hiện lỗi, chuyển sang bước tiếp theo.

## Bước 6. Tạo máy ảo Android

1. Mở Android Studio.
2. Chọn Device Manager.
3. Chọn Create Virtual Device.
4. Chọn một thiết bị điện thoại, ví dụ Pixel 7.
5. Chọn phiên bản Android có sẵn hoặc tải một ảnh hệ thống tương thích.
6. Hoàn tất quá trình tạo máy ảo.
7. Nhấn nút khởi động để mở máy ảo.

Chờ đến khi máy ảo hiển thị màn hình chính Android.

## Bước 7. Kiểm tra kết nối thiết bị

Quay lại Visual Studio Code, mở cửa sổ dòng lệnh và nhập:

```bash
flutter devices
```

Nếu danh sách xuất hiện máy ảo Android, thiết bị đã được Flutter nhận diện.

## Bước 8. Chạy ứng dụng

Trong cửa sổ dòng lệnh tại thư mục dự án, nhập:

```bash
flutter run
```

Chờ Flutter biên dịch và cài đặt ứng dụng lên máy ảo.

Sau khi hoàn tất, ứng dụng Game Bartender sẽ được mở trên thiết bị.

## Bước 9. Kiểm tra chức năng Rubik 3D

1. Tại giao diện ứng dụng, truy cập chức năng Rubik.
2. Kiểm tra khối Rubik 3D có hiển thị đầy đủ hay không.
3. Chạm và kéo trên màn hình để xoay góc nhìn.
4. Thử phóng to và thu nhỏ khối Rubik.
5. Kiểm tra các nút chức năng và điều hướng.

Nếu khối Rubik hiển thị và phản hồi thao tác bình thường, phần hiển thị 3D đã hoạt động.

## Bước 10. Xử lý một số lỗi thường gặp

| Lỗi | Cách khắc phục |
| --- | --- |
| Không nhận diện lệnh "flutter" | Kiểm tra biến môi trường PATH và mở lại cửa sổ dòng lệnh |
| Thiếu Android SDK | Mở SDK Manager trong Android Studio để cài đặt |
| Không tìm thấy thiết bị | Kiểm tra máy ảo đã khởi động và chạy lại "flutter devices" |
| Thiếu thư viện | Chạy lại "flutter pub get" |
| Rubik không hiển thị | Kiểm tra các tệp JavaScript, nội dung web nhúng và thông báo lỗi |
| Ứng dụng chạy chậm | Thử trên thiết bị Android thật và kiểm tra tài nguyên máy |