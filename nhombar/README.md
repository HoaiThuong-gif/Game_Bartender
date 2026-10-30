# Nhombar frontend

Ứng dụng Flutter. Backend nằm bên cạnh tại `../backend/`.
Chạy lệnh Flutter tại folder này, không chạy từ thư mục dự án lớn.

```powershell
flutter pub get
adb reverse tcp:3000 tcp:3000
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000/api/v1
```

Mở terminal khác tại folder dự án lớn và chạy `npm --prefix backend start`.
Swagger: http://localhost:3000/docs.

```powershell
flutter analyze
flutter test
```

Test API cần Node.js và backend sibling `../backend/`. Test tự mở server riêng,
không cần chạy sẵn backend. Assets và lệnh npm build Rubik nằm tại folder này:
`npm ci`, `npm run build:rubik`, `npm run build:rubik-toy`.

Tên package Dart vẫn là `nhom_bar`, Android applicationId vẫn là
`com.example.nhom_bar`; chỉ vị trí thư mục frontend đổi thành `nhombar/`.
Firebase trong frontend là tích hợp cũ; online mới dùng HTTP API.
Xem [hướng dẫn dự án](../README.md) và
[kết nối server quét](../backend/tools/SCAN_CONNECTIONS.md).
