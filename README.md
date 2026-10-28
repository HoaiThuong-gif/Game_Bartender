# Object 3D Scanner — Flutter + FastAPI + COLMAP

Ứng dụng Android hỗ trợ quay video vật thể, gửi video tới máy tính để tái dựng **đám mây điểm 3D (Point Cloud)** bằng COLMAP, sau đó hiển thị kết quả trên điện thoại.

> **Lưu ý:** Kết quả hiện tại là Point Cloud (`.ply`) và dữ liệu camera (`.json`), **chưa phải mô hình mesh 3D kín hoặc file GLB**. Ứng dụng có màn hình xem GLB để tương thích, nhưng pipeline COLMAP hiện tại chỉ xuất Point Cloud.

## 1. Công nghệ

| Thành phần | Công nghệ | Chức năng |
| --- | --- | --- |
| Ứng dụng Android | Flutter / Dart | Quay video, upload, xem kết quả |
| Backend | Python 3.12 / FastAPI / Uvicorn | Nhận video, chạy pipeline nền, cung cấp API |
| Trích xuất ảnh | FFmpeg | Lấy frame từ video (mặc định 2 fps) |
| Tái dựng 3D | COLMAP 4.2.1 | SIFT, matching, Structure-from-Motion (SfM) |
| Viewer | Three.js trong Flutter WebView | Hiển thị PLY có màu và vị trí camera |

## 2. Yêu cầu trước khi cài đặt

- Windows 11 (môi trường phát triển đã kiểm thử), Git và Android Studio hoặc VS Code.
- Flutter SDK, Android SDK, thiết bị Android thật hoặc emulator.
- Python 3.12 và `pip`.
- FFmpeg hoạt động trong `PATH` (kiểm tra bằng `ffmpeg -version`).
- COLMAP có thể chạy từ file `.bat` trên Windows.
- Điện thoại và máy tính cần kết nối mạng sao cho điện thoại truy cập được FastAPI của máy tính.
- Máy tính cần đủ dung lượng lưu video, frame và các file tái dựng COLMAP.

## 3. Cấu trúc dự án

```text
object_3d_scanner/
├── lib/
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── scanner_screen.dart
│   │   ├── processing_screen.dart
│   │   ├── pointcloud_viewer_screen.dart
│   │   └── model_viewer_screen.dart
│   ├── services/
│   │   └── scan_service.dart
│   └── main.dart
├── backend/
│   ├── main.py
│   ├── colmap_pipeline.py
│   ├── uploads/             # sinh khi chạy; không commit video
│   ├── colmap_workspace/    # sinh khi chạy; không commit mô hình
│   ├── scan_status/         # sinh khi chạy
│   └── models/              # mô hình GLB nếu có
├── android/
└── pubspec.yaml
```

## 4. Cài đặt

### 4.1. Flutter

Tại thư mục gốc dự án:

```powershell
flutter doctor
flutter pub get
flutter devices
```

Nếu dùng điện thoại Android thật, bật **Developer options** và **USB debugging**, rồi kết nối với máy tính.

### 4.2. Backend Python

Mở terminal tại thư mục `backend`:

```powershell
python -m pip install fastapi "uvicorn[standard]" python-multipart
```

> Có thể tạo môi trường ảo Python riêng để tránh xung đột thư viện. Lệnh trên cài các gói cần thiết cho backend hiện tại.

### 4.3. FFmpeg và COLMAP

Kiểm tra:

```powershell
ffmpeg -version
& "D:\COLMAP\COLMAP.bat" -h
```

Trong `backend/colmap_pipeline.py`, sửa đường dẫn `COLMAP_EXE` cho đúng nơi cài COLMAP trên máy:

```python
COLMAP_EXE = r"D:\COLMAP\COLMAP.bat"
FFMPEG_EXE = "ffmpeg"
FRAME_FPS = 2
MAX_IMAGE_SIZE = 1600
```

Pipeline hiện đang đặt `--FeatureExtraction.use_gpu 0` và `--FeatureMatching.use_gpu 0` để chạy SIFT/matching bằng CPU. Đây là cấu hình đã thử thành công trên máy phát triển; COLMAP mapper vẫn có thể dùng tài nguyên tính toán đáng kể.

## 5. Chạy ứng dụng

### Bước 1 — Khởi động FastAPI

Trong terminal tại `backend`:

```powershell
python -m uvicorn main:app --host 0.0.0.0 --port 8000
```

Kiểm tra trên laptop:

- `http://127.0.0.1:8000/health`
- `http://127.0.0.1:8000/docs` (Swagger UI)

Giữ terminal backend mở trong lúc xử lý.

### Bước 2 — Cấu hình IP backend trong Flutter

Xem IPv4 của laptop bằng `ipconfig`. Trong `lib/services/scan_service.dart`, sửa:

```dart
static const String baseUrl = 'http://192.168.100.116:8000';
```

Thay `192.168.100.116` bằng **IPv4 hiện tại của laptop**. Đây chỉ là IP ví dụ trong môi trường phát triển, có thể thay đổi khi đổi mạng Wi-Fi.

Nếu điện thoại không truy cập được API, kiểm tra hai thiết bị có cùng mạng, Windows Firewall cho phép cổng 8000 và quyền truy cập HTTP trên Android. Không mở cổng 8000 ra Internet công cộng vì API hiện chưa có xác thực người dùng.

### Bước 3 — Chạy Flutter

Trong terminal tại thư mục gốc:

```powershell
flutter analyze
flutter run
```

Nếu có nhiều thiết bị, dùng `flutter devices` rồi chạy `flutter run -d <device-id>`.

## 6. Hướng dẫn sử dụng

1. Mở ứng dụng, chọn **Bắt đầu quét 3D**.
2. Quay video quanh vật thể, di chuyển chậm, giữ vật thể trong khung hình và đảm bảo ánh sáng tốt.
3. Nhấn **Gửi video lên server**.
4. Chờ ứng dụng upload; backend tự chạy FFmpeg → COLMAP Feature Extraction → Matching → Mapper.
5. Backend tự chọn bản `sparse` có nhiều ảnh được đăng ký nhất (nếu hòa thì chọn bản có nhiều điểm 3D nhất), rồi xuất `pointcloud.ply` và `cameras.json`.
6. Flutter kiểm tra trạng thái định kỳ (mỗi 3 giây) và tự mở màn hình Point Cloud Viewer khi hoàn thành.
7. Trong viewer, kéo để xoay, chụm hai ngón để phóng to/thu nhỏ; các hình chóp đỏ biểu diễn vị trí camera COLMAP.

**Mẹo quay:** Chọn vật thể có họa tiết/chi tiết rõ, tránh bề mặt trong suốt, phản chiếu mạnh hoặc quá trơn; giữ ánh sáng ổn định, hạn chế rung và thay đổi góc nhìn đột ngột. Kết quả phụ thuộc vào video và số ảnh COLMAP đăng ký thành công.

## 7. API chính

| Phương thức | Endpoint | Mục đích |
| --- | --- | --- |
| GET | `/health` | Kiểm tra backend |
| POST | `/scan/upload` | Upload video qua trường multipart `video` và bắt đầu xử lý |
| GET | `/scan/{scan_id}` | Trạng thái `processing`, `completed`, `failed` hoặc `uploaded` (video cũ) |
| GET | `/scan/{scan_id}/pointcloud` | Tải PLY |
| GET | `/scan/{scan_id}/cameras` | Tải JSON camera |

Khi xử lý thành công, API trạng thái trả `result_type: "pointcloud"`, `pointcloud_url` và `cameras_url`. Nếu thất bại, kiểm tra trường `error` và log terminal backend.

## 8. Dữ liệu sinh ra và lưu ý Git

Backend tự tạo các thư mục `uploads/`, `colmap_workspace/`, `scan_status/`, `models/`. Video, cơ sở dữ liệu COLMAP, ảnh frame, PLY và file JSON trạng thái có thể chiếm nhiều dung lượng hoặc chứa dữ liệu riêng tư; **không nên commit chúng lên GitHub**.

Dự án có thể chạy lại pipeline cho video mới, nhưng với bản quét đã có `pointcloud.ply` và `cameras.json`, pipeline sẽ bỏ qua để bảo vệ dữ liệu. Nếu gặp lỗi giữa chừng, pipeline không tự xóa dữ liệu COLMAP cũ; hãy kiểm tra trước khi xử lý lại.

## 9. Khắc phục lỗi thường gặp

| Hiện tượng | Kiểm tra |
| --- | --- |
| `No module named uvicorn` | Chạy `python -m pip install fastapi "uvicorn[standard]" python-multipart` trong đúng môi trường Python |
| Điện thoại không kết nối FastAPI | Kiểm tra IP laptop, cùng Wi-Fi, Firewall, backend đang chạy cổng 8000 |
| COLMAP lỗi tham số SIFT | Với COLMAP 4.2.1, dùng `--FeatureExtraction.max_image_size`, không dùng `--SiftExtraction.max_image_size` |
| Feature Extraction/Matching lỗi GPU | Cấu hình hiện tại dùng CPU cho hai bước này |
| COLMAP tạo nhiều thư mục `sparse/0`, `sparse/1`, ... | Pipeline tự chọn theo số camera đăng ký và số điểm 3D |
| Viewer không hiện mô hình | Kiểm tra trạng thái API, file PLY, JSON camera và kết nối Internet để tải thư viện Three.js từ CDN |
| Quét thất bại hoặc ít điểm 3D | Thử video rõ nét hơn, ánh sáng tốt, góc quay chồng lấp và vật thể có chi tiết |

## 10. Giới hạn hiện tại

- Chỉ tái dựng **Sparse Point Cloud**, chưa tạo mesh đặc hoặc texture 3D hoàn chỉnh.
- Tiến độ dựng COLMAP đang hiển thị dạng chờ, không phải phần trăm hoàn thành chính xác.
- Backend thử nghiệm xử lý một pipeline COLMAP tại một thời điểm; tác vụ nền không phải hàng đợi bền vững khi server khởi động lại.
- API chưa có đăng nhập/xác thực; chỉ nên dùng trên mạng nội bộ đáng tin cậy.
- Viewer tải Three.js từ CDN nên cần truy cập Internet để hiển thị.

## 11. Kiểm tra chất lượng mã nguồn

```powershell
flutter analyze
```

Lệnh đã cho kết quả `No issues found` trên môi trường phát triển tại thời điểm kiểm tra. Đây là kiểm tra tĩnh; kết quả dựng 3D còn phụ thuộc vào cấu hình máy và video đầu vào.
