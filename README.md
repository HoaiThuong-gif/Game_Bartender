# Nhóm Bar — Flutter frontend + HTTP backend

Frontend và backend chạy thành hai tiến trình độc lập, giao tiếp bằng REST API
JSON. Swagger cho giảng viên xem endpoint, dữ liệu, xác thực và thử request.

```text
nhom_bar/                     # Thư mục dự án lớn, một Git repository
├── backend/                  # REST API, Swagger, server quét 3D
│   ├── src/
│   ├── test/
│   ├── tools/
│   └── firebase/              # Cloud Functions và cấu hình backend cũ
└── nhombar/                  # Frontend Flutter
    ├── lib/
    ├── android/
    ├── assets/
    ├── test/
    └── pubspec.yaml
```

`backend/` và `nhombar/` là hai folder ngang hàng trong cùng thư mục dự án lớn.
Frontend gọi HTTP `/api/v1` của backend. Mỗi phần có dependency và test riêng.
Tên package Dart vẫn là `nhom_bar`; tên folder frontend là `nhombar`.

## Chạy demo

App hiện yêu cầu đăng nhập Firebase trước khi vào Lobby. Cần bật Email/Google,
cấu hình SHA và quyền truy cập Firestore/Storage trong Firebase project hiện có.

Yêu cầu Flutter/Dart theo `nhombar/pubspec.yaml`, Node.js 22+, điện thoại Android có USB
debugging hoặc Android emulator.

Terminal 1, ở thư mục gốc:

```powershell
npm --prefix backend ci
npm --prefix backend start
```

Mở **http://localhost:3000/docs** để xem/thử API. Hợp đồng máy đọc được ở
http://localhost:3000/openapi.json, kiểm tra server ở
http://localhost:3000/api/v1/health.

Terminal 2, từ thư mục dự án lớn, Android qua USB/emulator:

```powershell
cd nhombar
adb reverse tcp:3000 tcp:3000
flutter pub get
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000/api/v1
```

Nếu nhiều thiết bị: `adb devices` rồi chạy
`adb -s <serial> reverse tcp:3000 tcp:3000` cho **từng máy**. Mỗi máy chạy app
cùng `API_BASE_URL` ở trên. Máy thứ nhất tạo phòng, máy thứ hai nhập mã tham gia.
`127.0.0.1` trên điện thoại trỏ vào máy tính nhờ `adb reverse`; chỉ chạy backend
mà không reverse cổng sẽ không kết nối được. Nếu `adb` chưa có trong PATH, dùng
`platform-tools/adb.exe` của Android SDK.

Chạy Flutter Windows trên chính máy server không cần `adb reverse`.
Dùng Wi-Fi/triển khai từ xa: đặt `API_BASE_URL=https://<host>/api/v1` qua HTTPS
reverse proxy/tunnel. Cấu hình Android hiện tại chỉ cho HTTP loopback, nên không
đổi thẳng sang `http://<IP-LAN>:3000`. API client hiện dùng `dart:io` cho
mobile/desktop; chưa hỗ trợ Flutter Web. Cấu hình iOS/ATS chưa được kiểm thử.

Chơi Bartender offline với bot khi cần:

```powershell
flutter run --dart-define=BARTENDER_OFFLINE=true
```

Mặc định Bartender và Rubik online dùng HTTP backend. Nút thử một máy của Rubik
vẫn dùng mock riêng. Chế độ offline không dùng để chứng minh kết nối API.

## Phân chia trách nhiệm

| Phần | Trách nhiệm |
|---|---|
| `nhombar/lib/screens`, `nhombar/lib/games/*/screens`, widgets | Giao diện, điều hướng, cảm biến, thao tác người dùng |
| `nhombar/lib/core/api/api_client.dart` | HTTP, Bearer session, timeout, polling, bù lệch giờ |
| `ApiRoomRepository`, `ApiRubikChallengeRepository` | Đổi JSON API sang model Flutter |
| `backend/src/server.js` | Endpoint, xác thực, heartbeat, cập nhật định kỳ |
| `backend/src/bartender.js` | Phòng, trạm, vật phẩm, đơn, timer, vòng chơi, điểm |
| `backend/src/rubik.js` | Máy trạng thái thách đấu Rubik |
| `backend/src/store.js` | Lưu trạng thái trên máy server |
| `backend/src/openapi.js` | Swagger/OpenAPI schemas và request/response |

API phòng chơi mới không cần `json-server` hoặc deploy Cloud Functions.
Firebase Authentication quản lý tài khoản vào Lobby; Firestore/Storage lưu hồ sơ
và ảnh đại diện. Các repository Firebase game cũ trong frontend và
`backend/firebase/` vẫn được giữ tham khảo; entry game online hiện dùng HTTP API.
Các tài liệu Bartender có quyết định
D20/D21 ghi nhận kiến trúc và cấu trúc folder mới.

Rubik giải đơn, camera, lobby và quét 3D vẫn là chức năng trên thiết bị/dịch vụ
quét riêng; lần tách này chuyển phần dữ liệu phòng chơi multiplayer sang API.

## Kiểm thử

```powershell
npm --prefix backend test
cd nhombar
flutter analyze
flutter test
```

`nhombar/test/api_repositories_test.dart` tự mở backend cục bộ, dùng repository Flutter
thật để kiểm tra hai người tạo/vào phòng, timer/round/results và Rubik countdown.
Cần Node.js trên PATH; không cần server chạy sẵn hay dữ liệu Firebase.

Backend hiện lưu file JSON, phù hợp demo một tiến trình; chưa dùng CSDL SQL.
Dữ liệu ở `backend/data/state.json` không commit. Chưa xác minh nhiều điện thoại
thật, mạng Wi-Fi/HTTPS và cảm biến sau khi chuyển API.
Xem [hướng dẫn backend và demo Swagger](backend/README.md) để biết giới hạn,
cấu hình và cách dùng token.

Server quét 3D cũng thuộc backend: chạy
`.\backend\tools\start-scan-server.ps1` từ thư mục dự án lớn, hoặc mở
`backend/Mo-may-quet.cmd`. Xem [kết nối máy quét](backend/tools/SCAN_CONNECTIONS.md).
Runtime Python/khóa ghép nối nằm ở `backend/.scan-runtime/`; phiên quét nằm ở
`backend/build/scan-jobs/`. Nếu server quét đang chạy trước khi chuyển folder,
dừng và mở lại từ đường dẫn mới.

VS Code có cấu hình chạy frontend/backend trong `.vscode/launch.json`;
có thể mở thư mục dự án lớn và chọn cấu hình tương ứng để debug.
