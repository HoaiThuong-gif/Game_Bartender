# Kết nối server quét 3D

Frontend Flutter nằm ở `nhombar/`; server và công cụ quét nằm ở `backend/`.
Chạy hai terminal tại thư mục dự án lớn chứa cả hai folder:

Người dùng Windows có thể nhấp đúp `backend/Mo-may-quet.cmd` để mở server mà không nhập lệnh.

```powershell
.\backend\tools\start-scan-server.ps1
```

```powershell
cd nhombar
flutter run
```

## USB khi phát triển

Cắm cáp truyền dữ liệu, bật USB debugging và chấp nhận quyền của PC trên điện thoại.
Server tự tìm ADB từ PATH, Android SDK hoặc `nhombar/android/local.properties`, tạo `adb reverse`
và gửi cấu hình ghép nối cho bản debug đã cài. Có thể chạy server trước hoặc sau `flutter run`;
server thử lại mỗi 3 giây, kể cả khi rút rồi cắm cáp. Windows hỗ trợ tự chọn một thiết bị USB;
với nhiều thiết bị, khả năng nhận diện phụ thuộc thông tin `usb:` từ ADB.

App tự kiểm tra khi bấm Quét; nếu chưa kết nối, hiện hướng dẫn và tự thử lại mỗi 4 giây.
Khi nhận được cấu hình qua USB, app nhớ cả địa chỉ LAN và mã ghép nối của PC nếu có.
Vì vậy có thể rút cáp và quét không dây cùng mạng mà không nhập lại địa chỉ hay mã.
Nếu PC đổi IP/mạng, cắm cáp lại để cập nhật. Ô nhập thủ công nằm trong mục nâng cao.

USB không cần điện thoại hay PC kết nối Wi-Fi. Server lắng nghe HTTPS tại `127.0.0.1`
để nhận dữ liệu qua cáp. Ghép nối tự động chỉ có trong bản debug và chỉ nhận cấu hình từ
ADB shell/system qua receiver được bảo vệ bằng quyền Android DUMP.

## Wi-Fi

Điện thoại và PC cần cùng mạng LAN/Wi-Fi có thể truy cập nhau. Trong màn hình Kết nối PC,
nhập địa chỉ HTTPS và nguyên mã ghép nối hiện trên terminal server. Giữ server chạy và cho
phép Python qua Windows Firewall trên mạng Private nếu được hỏi. Không tắt Firewall.

App ưu tiên đường USB đã ghép nối nếu tunnel đang hoạt động; nếu không, dùng địa chỉ Wi-Fi
đã lưu. App kiểm tra server và xác thực trước khi mở phiên quét. Khi không truy cập được PC
qua Wi-Fi, app nhắc kiểm tra cùng mạng, địa chỉ server và Firewall; lỗi kết nối không chứng
minh chắc chắn hai thiết bị đang ở khác mạng.

Lựa chọn đường kết nối áp dụng khi bắt đầu phiên/gửi hoặc nhận mô hình. Phiên đang truyền
không tự chuyển sang đường khác khi rút cáp; kết nối lại rồi thử lại để tiếp tục phiên.

## Kiểm tra

```powershell
.\backend\.scan-runtime\Scripts\python.exe -B -m unittest discover -s backend/tools -p test_scan_network.py
cd nhombar
flutter test --no-pub test/spatial_screen_test.dart
```

Kiểm tra thực tế: cài lại bản debug, tắt Wi-Fi điện thoại và quét qua USB; sau đó bật lại
Wi-Fi cùng mạng PC, lưu cấu hình Wi-Fi, rút cáp và xác nhận quét được. Thử địa chỉ PC không
truy cập được để xác nhận thông báo xuất hiện trước khi mở camera.
