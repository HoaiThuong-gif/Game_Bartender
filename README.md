# Nhóm Bar — Cài đặt và chạy trên Android

Hướng dẫn dùng Windows PowerShell và điện thoại Android kết nối USB, ví dụ
Samsung A52s. Cần đăng nhập Firebase trước khi vào Lobby.

```text
nhom_bar/
├── backend/
│   ├── src/                   API game Node.js
│   ├── bartender_ws/          Module HTTP/WebSocket Dart của Zhoufen (tùy chọn)
│   ├── tools/                 Máy xử lý quét 3D Python
│   ├── photo3d/               API TripoSR: một ảnh thành 3D
│   └── firebase/              Backend Firebase game cũ, không cần chạy cho API HTTP
└── nhombar/                   Ứng dụng Flutter, Android và asset
```

| Thành phần | Cổng mặc định | Khi nào cần mở |
|---|---|---|
| API Node.js | 3000 | Tài khoản/OTP, Bartender và Rubik online |
| Máy xử lý quét 3D | 8765, HTTPS | Tạo mô hình 3D |
| API TripoSR | 8766, HTTP qua USB | Tạo mô hình 3D từ một ảnh |

Ba dịch vụ chạy riêng. Chỉ mở dịch vụ cần dùng; không cài thư viện TripoSR vào môi
trường máy quét 3D. Trong các bước dưới, mỗi terminal mới bắt đầu ở thư mục gốc
`nhom_bar/`, trừ chỗ có lệnh `cd` khác.

`nhombar/` là Flutter project duy nhất. Màn hình chờ mèo và asset nằm tại
`nhombar/lib/shared/widgets/cozy_loading.dart` và `nhombar/assets/loading/`.
Thư mục con `source/` giữ asset nguồn của mèo, không được đóng gói thêm lần nữa.
`backend/bartender_ws/` giữ giao thức HTTP/WebSocket gốc của Zhoufen; không cần
chạy module này cho cấu hình Node.js mặc định bên dưới. Không chuyển URL Node.js
sang cổng 8080 vì hai module có hợp đồng API khác nhau.

Nếu cần kiểm tra riêng module Dart, từ thư mục gốc chạy `cd backend/bartender_ws`,
`dart pub get`, `dart test`, rồi `dart run bin/server.dart`. Health ở
http://127.0.0.1:8080/health; module chỉ lưu trong RAM và dùng adapter
`ZhoufenApiRoomRepository`, không chung phòng với Node. Docker dùng context gốc:
`docker build -f backend/bartender_ws/Dockerfile .`.

## 1. Chuẩn bị môi trường

Cài các công cụ sau và cho phép sử dụng chúng từ PowerShell:

- Git và Node.js 22 trở lên, kèm npm.
- Flutter có Dart tương thích `sdk: ^3.13.3` trong `nhombar/pubspec.yaml`.
  Cấu hình hiện tại đã dùng Flutter 3.47.4 với Dart 3.13.3.
- Android Studio, Android SDK Platform-Tools và SDK/build tools mà Flutter yêu cầu.
  Dùng JDK đi kèm Android Studio; để Flutter quản lý việc gọi Gradle của dự án.
- Python 3.11 nếu cần quét 3D hoặc dựng hình TripoSR. Khi cài Python trên Windows,
  cài cả Python Launcher để dùng được `py -3.11`.

Mở PowerShell mới sau khi cài để nhận PATH. Xem môi trường còn thiếu gì:

Nếu chưa có môi trường:

1. Cài [Git for Windows](https://git-scm.com/downloads/win). Cài Node.js 22+
   bằng Windows Installer từ [trang Node.js](https://nodejs.org/en/download),
   giữ lựa chọn thêm vào PATH và npm.
2. Tải SDK tương thích từ [Flutter SDK archive](https://docs.flutter.dev/install/archive),
   giải nén vào `C:\src\flutter`; thêm `C:\src\flutter\bin` vào **User PATH**
   trong Environment Variables. Không đặt SDK trong Program Files. Xem
   [cách cài Flutter](https://docs.flutter.dev/install/manual) nếu cần thao tác chi tiết.
3. Cài [Android Studio](https://developer.android.com/studio/install), hoàn tất
   Setup Wizard. Trong SDK Manager cài Android SDK Platform, Build-Tools,
   Platform-Tools và Command-line Tools. Cài plugin Flutter (kèm Dart).
4. Mở terminal mới rồi chạy các lệnh kiểm tra dưới đây. Chỉ cần Google Chrome
   khi muốn chạy test WebGL/Swagger headless, không bắt buộc để chạy app.

```powershell
git --version
node --version
npm.cmd --version
flutter --version
flutter doctor
```

Chấp nhận giấy phép Android SDK nếu Flutter yêu cầu:

```powershell
flutter doctor --android-licenses
```

Nếu cần Python, xác nhận đúng phiên bản:

```powershell
py -3.11 --version
```

## 2. Tải mã nguồn

Chạy trong thư mục bạn muốn chứa dự án:

```powershell
git clone --branch Thuong https://github.com/HoaiThuong-gif/Game_Bartender.git nhom_bar
cd nhom_bar
```

Nếu repository yêu cầu đăng nhập, dùng tài khoản GitHub đã được cấp quyền.
Mở thư mục `nhom_bar` trong IDE; không chỉ mở riêng `backend` hoặc `nhombar`.

## 3. Chuẩn bị Firebase và thư viện Flutter

Các file cấu hình Firebase không được lưu trong Git. Xin người quản lý project
`nhom-bar` hai file tương ứng với Android package `com.example.nhom_bar`, rồi đặt
đúng vị trí:

```text
nhombar/lib/firebase_options.dart
nhombar/android/app/google-services.json
```

Không lấy file từ Firebase project khác hoặc tự đổi package name. Ứng dụng hiện
được cấu hình Firebase cho Android; hướng dẫn này không dùng Flutter Web/desktop.

Người quản lý Firebase cần hoàn tất các bước sau trong Firebase Console:

1. **Authentication → Sign-in method:** bật Email/Password và Google. Kiểm tra
   chính sách một tài khoản cho mỗi email; khai báo email hỗ trợ cho Google.
2. **Project settings → Android app:** thêm SHA-1/SHA-256 của khóa ký APK sẽ cài.
   Sau đó tải lại `google-services.json` của đúng app và thay file tại đường dẫn
   trên. Nếu `oauth_client` còn rỗng, cấu hình Google chưa đầy đủ.
3. **Cloud Firestore:** bật database và cấp quyền phù hợp cho hồ sơ
   `players/{uid}`. Tài khoản chỉ được truy cập hồ sơ của chính UID đó; giữ các
   trường định danh/ngày tạo và dữ liệu game khỏi bị ghi đè tùy ý.
4. **Cloud Storage:** bật bucket của project, kiểm tra điều kiện gói dịch vụ và
   cấp quyền cho ảnh của chính UID tại `players/{uid}/avatars/{fileName}`.
   App tải JPEG tối đa 2 MB và tạo tên tệp mới khi đổi ảnh.

Nhờ người quản lý kiểm tra Rules thực tế trước khi chạy. Các mẫu Rules tài khoản
ở `backend/firebase/` cần ghép với Rules đang dùng theo phần Admin bên dưới;
Rules Realtime Database cũ không thay thế Firestore/Storage. Không mở toàn bộ
database bằng `allow read, write: if true`. Thiếu quyền sẽ làm hồ sơ/ảnh không đồng bộ được.

Cài dependency Flutter từ thư mục gốc:

```powershell
cd nhombar
flutter pub get
cd ..
```

Nếu cần lấy SHA cho bản debug, sau lần build/chạy đầu tiên hãy mở terminal tại
`nhombar/android` và dùng JDK đi kèm Android Studio:

```powershell
$env:JAVA_HOME = "$env:ProgramFiles\Android\Android Studio\jbr"
.\gradlew.bat signingReport
```

Nếu Android Studio được cài ở nơi khác, sửa đường dẫn `JAVA_HOME` cho đúng.
Lấy SHA của biến thể debug từ kết quả và bổ sung vào Firebase Console. Mỗi thành
viên có thể dùng khóa debug khác nhau; SHA trên máy người khác không thay thế SHA
của khóa bạn đang dùng. Sau khi thay cấu hình Google, chạy lại app để build lại.

### Firebase Admin và OTP email Brevo

Tài khoản vẫn dùng Firebase Authentication; hồ sơ ở Firestore `players/{uid}`,
ảnh ở Firebase Storage. Game ID do backend cấp duy nhất qua transaction và chỉ
bổ sung khi hồ sơ chưa có ID. Tên hiển thị được phép trùng. API game Node.js vẫn
lưu phòng/trận trong `backend/data/state.json`; module Dart WebSocket dùng bộ
nhớ riêng. Không có yêu cầu cài thêm MySQL/PostgreSQL hoặc chuyển dữ liệu cũ.

Backend cần Firebase Admin để kiểm tra phiên và OTP. Trong Firebase Console của
đúng project `nhom-bar`: **Project settings → Service accounts → Firebase Admin
SDK → Generate new private key → Generate key**. Đặt file JSON tải về ngoài repo,
ví dụ `C:/private/nhom-bar-admin.json` (sửa theo nơi bạn lưu file). Không thay `google-services.json`
bằng file này, không gửi khóa vào chat và không commit khóa lên Git.

Nếu đã có `backend/.env`, mở và sửa file hiện có. Nếu chưa có, tại thư mục gốc:

```powershell
Copy-Item backend/.env.example backend/.env
```

Điền cấu hình local:

```dotenv
FIREBASE_PROJECT_ID=nhom-bar
GOOGLE_APPLICATION_CREDENTIALS=C:/private/nhom-bar-admin.json
BREVO_API_KEY=API_KEY_CUA_BAN
BREVO_SENDER_EMAIL=EMAIL_SENDER_DA_XAC_MINH
OTP_HMAC_KEY=KHOA_NGAU_NHIEN_CUA_BAN
```

Tạo khóa HMAC một lần bằng lệnh dưới, chép kết quả vào `.env`, không đổi khóa
giữa lúc đang xác thực OTP:

```powershell
node -e "console.log(require('node:crypto').randomBytes(32).toString('hex'))"
```

Trên Brevo, xác minh sender/domain và cấp cho API key quyền gửi transactional
email. Dùng API key, không dùng SMTP key. Key chỉ có quyền gửi có thể bị từ chối
khi gọi API đọc `account`/`senders`; điều đó không xác nhận hoặc phủ nhận việc
gửi email thành công. Backend gọi `POST https://api.brevo.com/v3/smtp/email`.

Trong Firebase Console:

1. **Authentication → Sign-in method:** giữ Email/Password và Google hiện có;
   không xóa tài khoản cũ hoặc tạo project khác.
2. **Firestore Database:** dùng database `(default)` đang có. Nếu chưa có mới
   tạo database ở Production mode. Không xóa collection để chạy lại.
3. **Firestore Database → Rules** và **Storage → Rules:** lưu bản Rules hiện tại
   trước khi thay đổi. Các mẫu `backend/firebase/account.firestore.rules` và
   `account.storage.rules` chỉ bao phủ tài khoản. Cần ghép với Rules thực tế,
   giữ các collection khác và xử lý rule `allow` rộng chồng lên `players`.
   Không triển khai nguyên file mẫu để ghi đè Rules chưa được kiểm tra.

Rules tài khoản cần kiểm tra claim `account_session` và phiên `_accountSessions`
còn hạn, chỉ cho chủ UID sửa tên/ảnh. UID, Game ID và ngày tạo không được sửa
từ client. `_accountChallenges`, `_accountSessions`, `gameIds` chỉ backend Admin
được ghi. Storage dùng Firestore trong Rules có thể yêu cầu cấp quyền truy cập
chéo dịch vụ khi publish; làm theo thông báo của Firebase Console. Không thay
Rules Realtime Database game cũ bằng các mẫu này.

Kiểm tra Firestore thật sau khi đặt đúng file khóa, tại thư mục gốc:

```powershell
node backend/tools/check-account-database.js
```

Công cụ chỉ tạo, đọc, cập nhật rồi dọn document ngẫu nhiên trong
`_accountDiagnostics`; không sửa hồ sơ người chơi. Thành công ở đây xác nhận
CRUD của Admin, chưa xác nhận Rules client, email tới hộp thư hoặc sinh trắc học.

Sau khi khởi động Node ở bước 4, đăng ký/đăng nhập trên điện thoại rồi chọn gửi
mã email. Mã có hạn 10 phút, tối đa 5 lần nhập; gửi lại cách nhau ít nhất 60 giây,
tối đa 5 lần/giờ. Mã chỉ lưu dạng HMAC và không được ghi log. Chỉ sau khi backend
kiểm tra đúng mã mới cấp phiên Firebase đã xác thực. Hồ sơ cũ chỉ được bổ sung
trường còn thiếu, không đặt lại điểm/bộ sưu tập hay UID.

Sau OTP thành công, bật sinh trắc học trong hồ sơ trên Android hỗ trợ sinh trắc
học mạnh. Khóa phiên được Android Keystore bảo vệ và chỉ giải mã sau xác thực
HĐH; không lưu mặt/vân tay. Lần mở app sau dùng nút sinh trắc học hoặc đăng nhập
thông thường và OTP. Đăng xuất thu hồi phiên hiện tại và tắt khóa đăng nhập nhanh
trên thiết bị; nếu offline, xóa phiên cục bộ trước và báo lỗi thu hồi từ server.
Phiên hết hạn hoặc đổi/reset mật khẩu yêu cầu xác thực lại. Khởi động lại Node
sau khi chỉnh `.env`; không đưa API key Brevo/Admin vào Flutter.

## 4. Khởi động API game

Terminal thứ nhất, ở thư mục gốc:

```powershell
npm.cmd --prefix backend ci
npm.cmd --prefix backend start
```

Giữ terminal mở trong lúc dùng game online. Các địa chỉ trên PC:

- Swagger: http://localhost:3000/docs
- Trạng thái API: http://localhost:3000/api/v1/health
- OpenAPI: http://localhost:3000/openapi.json

`npm.cmd` giúp tránh lỗi PowerShell chặn `npm.ps1`. Chỉ mở một tiến trình server
cho cùng file dữ liệu `backend/data/state.json`; không xóa file này để sửa lỗi cổng.

## 5. Kết nối điện thoại và chạy ứng dụng

### Điện thoại thật qua USB

Bật Tùy chọn nhà phát triển và **Gỡ lỗi USB** trên điện thoại. Cắm cáp có truyền
dữ liệu, mở khóa máy và chọn **Cho phép** khi được hỏi về máy tính.

Terminal thứ hai, ở thư mục gốc. Đường dẫn dưới dùng vị trí SDK mặc định của
Android Studio trên Windows; sửa nếu bạn cài SDK ở nơi khác:

```powershell
$adb = "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe"
& $adb devices -l
```

Copy mã ở cột đầu của dòng có trạng thái `device`. Thay chuỗi bên dưới bằng mã
thật, không giữ nguyên chữ `MA_THIET_BI`:

```powershell
$deviceId = 'MA_THIET_BI'
& $adb -s $deviceId reverse tcp:3000 tcp:3000
& $adb -s $deviceId reverse tcp:8766 tcp:8766
```

Cổng 3000 dùng cho game; 8766 dùng khi bạn mở thêm TripoSR ở bước 6. `adb reverse`
giúp `127.0.0.1` trên điện thoại truy cập dịch vụ trên máy tính qua USB.

Chạy bản debug trên đúng điện thoại đó:

```powershell
cd nhombar
flutter run -d $deviceId --dart-define=API_BASE_URL=http://127.0.0.1:3000/api/v1 --dart-define=PHOTO3D_API_URL=http://127.0.0.1:8766
```

Đăng ký hoặc đăng nhập để vào Lobby. Hai điện thoại chơi online cần được reverse
cổng 3000 riêng cho từng mã thiết bị; dùng cùng một backend, một máy tạo phòng
và máy kia nhập mã. Giữ các terminal server đang cần dùng mở.

Nếu rút/cắm lại cáp hoặc khởi động lại ADB, thực hiện lại các lệnh reverse.
Khi sửa phần Android/native hoặc thay cấu hình Firebase, dừng rồi chạy lại app;
hot reload không cập nhật được phần đó.

### Android Studio hoặc máy ảo

Trong Android Studio chọn **Open → nhom_bar/nhombar** (thư mục có pubspec.yaml),
trỏ Flutter SDK về `C:\src\flutter`. Mở **Run → Edit Configurations**, chọn
Flutter với entrypoint `lib/main.dart`, thêm vào **Additional run args**:

```text
--dart-define=API_BASE_URL=http://127.0.0.1:3000/api/v1 --dart-define=PHOTO3D_API_URL=http://127.0.0.1:8766
```

Chọn điện thoại đã reverse cổng rồi nhấn Run. Để dùng máy ảo, tự mở **Device
Manager → Create Device**, chọn Android image có Google Play phù hợp máy tính,
hoàn tất rồi nhấn nút Start của thiết bị. Không cần tạo Flutter project mới.

Chạy `adb devices -l` bằng biến `$adb` ở trên, lấy mã máy ảo (ví dụ
`emulator-5554`), đặt lại `$deviceId` và chạy hai lệnh reverse cổng cho mã đó.
Sau đó chọn máy ảo trong Android Studio hoặc chạy lệnh `flutter run -d $deviceId`
với cùng hai dart-define đã nêu. Cả máy ảo và điện thoại đều cần Internet để
đăng nhập Firebase/gửi OTP, dù API game chạy local.

Máy ảo không thay thế kiểm thử camera/cảm biến/sinh trắc học thật. Để thử sinh
trắc học cần điện thoại đã đăng ký vân tay/khuôn mặt mạnh trong cài đặt Android.

Trong Lobby, nhấn avatar góc trên trái để mở hồ sơ, cài đặt, màu/cỡ chữ hoặc
chỉnh bố cục. Bartender dùng giao diện 3D và quay về giao diện nhẹ nếu cảnh 3D
không khởi tạo được. Mèo chờ chỉ xuất hiện khi có tác vụ tải/xử lý thật.

Các bundle WebView đã được lưu trong Git; không cần npm ở frontend chỉ để chạy
Flutter. Khi sửa JavaScript của Rubik, Bartender hoặc mèo, mở terminal tại
`nhombar/` và đóng gói lại phần vừa sửa:

```powershell
npm.cmd ci
npm.cmd run build:rubik
npm.cmd run build:rubik-toy
npm.cmd run build:cozy-cat
node lib/games/bartender/scene3d/build_scene.cjs
```

Để kiểm tra mã nguồn, tại `nhombar/` chạy `flutter analyze` và `flutter test`;
tại `backend/` chạy `npm.cmd test`. Test API tự khởi động server trên cổng tạm
và không cần sửa/xóa dữ liệu đang lưu trong `backend/data/`.

## 6. Tạo mô hình 3D từ một ảnh — TripoSR

Chức năng này chạy riêng với quét đa ảnh ở bước 7. Máy ảnh trên kệ TV mở
**Ảnh thành 3D**: chụp/chọn một vật trên nền đơn giản, chờ xử lý rồi bấm
**Xem mô hình 3D**. Vuốt để xoay, chụm để phóng to. Mặt khuất được AI ước lượng,
không phải phép đo chính xác. Chưa yêu cầu texture.

Cài lần đầu từ thư mục gốc, dùng Python 3.11 và Visual Studio C++ Build Tools
(kèm Windows SDK; có thể dùng Visual Studio Community với workload Desktop
development with C++). Cần vài GB trống và Internet để tải pretrained chính thức:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\backend\photo3d\setup.ps1
```

Script tạo môi trường riêng `backend/.triposr-runtime/`, tải mã nguồn TripoSR và
trọng số `stabilityai/TripoSR` theo revision cố định, cùng model tách nền u2netp.
Trọng số và mã nguồn bên thứ ba trong runtime không đưa lên Git. Không train.
RTX 3050 4 GB của máy phát triển dùng cấu hình CPU, lưới 96 và xử lý từng yêu
cầu một để tránh vượt VRAM. CPU có thể mất vài phút mỗi ảnh.

Mỗi lần sử dụng, mở terminal ở thư mục gốc và giữ server chạy:

```powershell
.\backend\.triposr-runtime\Scripts\python.exe -m nhombar_photo3d
```

Đợi báo startup hoàn tất; kiểm tra http://127.0.0.1:8766/health. Server chỉ nghe
localhost, điện thoại dùng `adb reverse tcp:8766 tcp:8766` ở bước 5. Node.js vẫn
chạy riêng như bước 4; không đổi Firebase hoặc API game.

API `POST /api/v1/photo-models` nhận JPEG/PNG tối đa 8 MB, 16 megapixel; trả
202 kèm ID. `GET /api/v1/photo-models/{id}` trả trạng thái; khi `done`, tải
`GET /api/v1/photo-models/{id}/mesh`. Mesh SCN1 dùng viewer Android hiện có;
không tạo khối mẫu thay kết quả AI. Không lưu ảnh vào ổ đĩa; kết quả giữ trong
RAM tối đa 15 phút, tối đa 8 phiên gần nhất. Inference giới hạn 10 phút; server
khởi động lại worker khi quá hạn. Mở `/docs` trên localhost để xem API.

## 7. Quét mô hình 3D — tùy chọn

Mở terminal khác ở thư mục gốc:

```powershell
.\backend\Mo-may-quet.cmd
```

Lần đầu launcher tạo môi trường `backend/.scan-runtime/`, cài thư viện và tải
công cụ/model cần thiết. Cần Python 3.11, Internet và dung lượng trống để tải các
thư viện lớn. Đợi khởi động xong; giữ cửa sổ máy xử lý mở suốt quá trình quét.

Kết nối lần đầu bằng một trong hai cách:

- **Wi-Fi:** điện thoại và PC cùng mạng nội bộ. Trong app chọn **Quét 3D →
  Hướng dẫn kết nối → Quét mã kết nối**, quét QR hiện trên PC và xác nhận.
  Nếu thẻ QR chưa mở, mở `backend/.scan-runtime/network/Ket-noi-may-quet.html`
  sau khi server đã tạo file. Chỉ cho Python qua Windows Firewall trên mạng
  Private nếu được hỏi; không tắt Firewall hoặc chia sẻ mã ghép nối.
- **USB khi phát triển:** giữ Gỡ lỗi USB và quyền máy tính đã cấp ở bước 5.
  Launcher tự tạo tunnel/ghép nối cho bản debug đã cài; không cần nhập IP/mã.

Chờ app báo **Sẵn sàng quét**, sau đó bấm **Bắt đầu quét**. Máy xử lý dùng HTTPS
cổng 8765 và kiểm tra chứng chỉ; không bỏ qua xác thực. App nhớ máy đã ghép nối;
nếu IP/chứng chỉ đổi, dùng QR mới hoặc kết nối USB lại. TripoSR và máy quét 3D dùng
hai terminal, hai môi trường riêng, không thay thế lẫn nhau.

Khi dùng USB debug, launcher kiểm tra máy mới mỗi 3 giây. Nếu kết nối USB xong
nhưng app chưa nhận cấu hình, vào lại Quét 3D hoặc bấm Thử lại. Công việc quét
đã gửi lên một máy chủ không tự chuyển sang máy khác khi đổi kết nối.

## 8. Thử API bằng Swagger

Khi Node đang chạy, mở http://localhost:3000/docs. UI và file JavaScript được
phục vụ local, không cần CDN. Các nhóm gồm System, Session, Account, Bartender,
Rubik. Hợp đồng mô tả API Node; đăng ký/mật khẩu/ảnh qua Firebase SDK, không có
REST endpoint thay thế. API TripoSR riêng có `/docs` tại cổng 8766 khi đang chạy.

1. Mở **System → GET health → Execute**.
2. Mở **Session → POST sessions**, nhập tên và Execute. Copy token trả về.
3. **Authorize → bearerAuth**: dán token, nhấn Authorize rồi Close.
4. **Bartender → POST rooms → Execute**; copy code và dùng **GET rooms/{code}**.
5. Tạo session thứ hai để join; dùng token chủ phòng để start. GET phòng bằng
   từng token trong vòng 30 giây để giữ heartbeat; Swagger không tự polling.
   Bartender cần 2–4 người, Rubik cần 2. Các lệnh process/send/trash/submit dùng
   key vật phẩm và đơn do API trả về, không dùng tên món thay key.

API hiện dùng GET và POST. Không có PUT/PATCH/DELETE giả để thử; thao tác rời
phòng và bỏ vật phẩm dùng endpoint POST đang phục vụ Flutter. Ví dụ trong
schema chỉ minh họa cấu trúc, không phải kết quả đã xử lý.

Nhóm Account dùng **firebaseAuth**, tức Firebase ID token lấy từ phiên đăng
nhập của chính bạn trong app. Token game không dùng được; Admin/Brevo key không
phải token đăng nhập. `/account/resume` cần khóa Keystore thật. Không chia sẻ
những giá trị này. Swagger không ghi nhớ token khi tải lại trang. Chưa cấu hình
Firebase Admin thì API tài khoản trả 503 thay vì báo thành công.

## 9. Cho giảng viên xem Swagger qua HTTPS

Chỉ thực hiện khi bạn muốn mở truy cập từ Internet. Mặc định hướng dẫn dùng
Microsoft Dev Tunnels có đăng nhập, không cấp anonymous. Chỉ forward cổng API
3000; không forward Firebase/Database, máy quét hay TripoSR.

### Microsoft Dev Tunnels

Cài CLI, mở terminal mới và tự đăng nhập tài khoản Microsoft hoặc GitHub:

```powershell
winget install Microsoft.devtunnel
devtunnel user login
devtunnel create -d "NhomBar Swagger"
```

Copy Tunnel ID được trả về (bao gồm vùng nếu có), thay giá trị bên dưới:

```powershell
$tunnelId = 'TUNNEL_ID_CUA_BAN'
devtunnel port create $tunnelId -p 3000 --protocol http
devtunnel show $tunnelId
```

Tạo tunnel một lần. Những lần sau dùng lại ID/cổng này để giữ URL, không tạo
tunnel mới. Backend vẫn chạy HTTP local; dịch vụ tunnel cung cấp HTTPS bên ngoài.

Mặc định chỉ chủ tunnel được truy cập. Để giảng viên dùng tài khoản riêng, có
thể cấp quyền cho GitHub organization mà cả hai đã tham gia:

```powershell
devtunnel access create $tunnelId --org TEN_GITHUB_ORGANIZATION
```

Chủ organization cần cài **Dev Tunnels GitHub App** như trong
[hướng dẫn bảo mật](https://learn.microsoft.com/en-us/azure/developer/dev-tunnels/security).
Nếu dùng tài khoản trường Microsoft Entra, có thể chọn `--tenant` thay cho
`--org ...` để cấp quyền cùng tenant; phạm vi này bao gồm cả tenant. Không chia
sẻ mật khẩu đăng nhập. Nếu không có nhóm phù hợp, chưa cấp quyền rồi kỳ vọng
giảng viên mở được link; cần chọn phương án truy cập có kiểm soát trước.

1. Chạy Node như bước 4 và kiểm tra health, `/docs` trên localhost trước.
2. Trong terminal khác chạy:

```powershell
devtunnel host $tunnelId
```

3. Copy **Connect via browser** URL HTTPS của cổng 3000, thêm `/docs`.
4. Mở link bằng 4G/5G hoặc máy khác, đăng nhập tài khoản đã được cấp quyền;
   dùng Execute theo bước 8. Chọn server `/` để request theo đúng origin HTTPS.
5. Bấm Ctrl+C tại terminal tunnel khi xong. Giữ tunnel ID để dùng lần sau;
   không chạy delete. Dừng backend riêng bằng Ctrl+C khi không còn cần.

Đóng laptop hoặc dừng host làm link ngừng phục vụ. Không cần domain/hosting;
CLI hiện ở giai đoạn preview. Xem [lệnh chính thức](https://learn.microsoft.com/en-us/azure/developer/dev-tunnels/cli-commands)
nếu phiên bản CLI đổi tùy chọn. Các lệnh ở đây chưa thay thế kiểm thử đường
truyền thật sau khi bạn đăng nhập và cấp quyền.

### Nếu giảng viên yêu cầu đúng Conveyor CLI

[Conveyor CLI](https://conveyor.cloud/Home/How_To_Install) hỗ trợ Node HTTP;
cần .NET runtime theo trang cài đặt và tài khoản tunnel. Tải executable từ trang
chính thức vào thư mục công cụ ngoài repo, mở terminal tại đó. Chỉ bật Internet
tunnel sau khi bạn đồng ý phạm vi truy cập của dịch vụ:

```powershell
.\conveyorcli.exe config -s
.\conveyorcli.exe -p 3000i
```

Hậu tố `i` chỉ HTTP local của Node. Lấy **Access over internet** URL HTTPS,
thêm `/docs`; không dùng Remote URL LAN tự ký và không bỏ kiểm tra chứng chỉ.
Subdomain riêng phụ thuộc availability/gói dịch vụ, không mặc định URL được
giữ miễn phí. Dừng bằng Ctrl+C.

Cloudflare Quick Tunnel cũng không cần domain nhưng cấp URL ngẫu nhiên, nên
không chọn cho nhu cầu tái sử dụng URL. Xem [tài liệu Cloudflare](https://developers.cloudflare.com/tunnel/get-started/quick-tunnels/).

## 10. Kiểm tra trước khi sử dụng

Tại thư mục `nhombar/`:

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug --target-platform android-arm64 --dart-define=API_BASE_URL=http://127.0.0.1:3000/api/v1 --dart-define=PHOTO3D_API_URL=http://127.0.0.1:8766
```

APK ở `nhombar/build/app/outputs/flutter-apk/app-debug.apk`. Build không tự cài
lên điện thoại. Test web headless cần `npm.cmd ci` và Google Chrome; nếu cài
Chrome ở nơi khác, đặt `CHROME_PATH` đến executable:

```powershell
node test/swagger_ui.cjs
node test/cozy_scene_webgl.cjs
node lib/games/bartender/scene3d/verify_scene.cjs
```

Backend từ thư mục gốc: `npm.cmd --prefix backend test`. Kiểm tra Firestore
bằng công cụ ở bước 3 sau khi cấu hình Admin. Các bài policy test OTP dùng kho
riêng trong test, không xác nhận thư Brevo đến hộp thư hay thiết bị sinh trắc học.

Trên điện thoại: đăng ký/OTP đúng-sai-hết hạn/gửi lại, đăng nhập lại, đổi tên/ảnh,
Game ID không đổi, đăng xuất và sinh trắc học. Tiếp theo thử xoay/chạm/chỉnh
bố cục Lobby, vào/ra game, Bartender và Rubik trên hai máy, quét đa ảnh và TripoSR.
Giữ dữ liệu cũ để kiểm tra hồ sơ/bộ sưu tập nếu tài khoản đã có; không tạo dữ
liệu giả thay cho một chức năng chưa được tích hợp.

## 11. Khi chưa chạy được

| Hiện tượng | Cách xử lý |
|---|---|
| Không tìm thấy `flutter`, `node`, `git` hoặc `py` | Cài đúng công cụ, kiểm tra PATH rồi mở terminal mới. |
| ADB báo `unauthorized` | Mở khóa điện thoại, chấp nhận quyền USB rồi chạy lại `adb devices -l`. |
| ADB không thấy điện thoại | Kiểm tra Gỡ lỗi USB, cáp truyền dữ liệu và driver USB của hãng. |
| Backend báo `EADDRINUSE` ở cổng 3000 | Mở trang health. Nếu API đang chạy, dùng server đó; không khởi động bản thứ hai. Nếu tiến trình khác chiếm cổng, xác định đúng tiến trình trước khi dừng. |
| OTP báo dịch vụ chưa sẵn sàng/503 | Kiểm tra đủ biến `.env`, đường dẫn JSON Admin tồn tại và đúng project; khởi động lại Node. Không gửi giá trị khóa vào chat. |
| Email chưa đến | Kiểm tra Spam, sender/domain Brevo đã xác minh, key có quyền transactional email, hạn mức và log giao thư trên Brevo. Không ghi OTP vào log để chẩn đoán. |
| Link tunnel báo 401/403 hoặc yêu cầu đăng nhập | Dùng tài khoản đã được cấp quyền; kiểm tra organization/tenant. Không bật anonymous để che lỗi quyền. |
| Link tunnel không tải | Kiểm tra laptop và Node/tunnel còn chạy, đúng ID/cổng 3000, thử localhost trước. |
| App không gọi được API game/TripoSR | Kiểm tra server tương ứng còn mở và chạy lại reverse cổng 3000/8766 cho đúng mã máy. |
| Google không đăng nhập được | Kiểm tra provider, SHA của khóa ký và file JSON có OAuth client của đúng project/app. |
| Hồ sơ/ảnh báo thiếu quyền | Nhờ chủ project kiểm tra Firestore/Storage Rules theo UID; không mở quyền toàn bộ. |
| TripoSR báo thiếu model | Chạy lại `backend/photo3d/setup.ps1`; giữ đủ dung lượng và mạng cho lần tải đầu. |
| Máy quét 3D chưa sẵn sàng | Xem lỗi ở cửa sổ launcher, kiểm tra thư viện/kết nối và ghép QR/USB lại; không mở camera xử lý khi server chưa sẵn sàng. |
| Cài APK báo khác chữ ký | Dừng và dùng đúng khóa ký. Không gỡ app để chữa nhanh vì sẽ mất mô hình lưu trên điện thoại. |

Dừng server bằng `Ctrl+C` trong terminal của chính server đó. Không xóa dữ liệu,
trọng số hay cài lại toàn bộ môi trường khi chưa biết nguyên nhân lỗi.
