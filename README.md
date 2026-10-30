# Nhóm Bar — Cài đặt và chạy trên Android

Hướng dẫn dùng Windows PowerShell và điện thoại Android kết nối USB, ví dụ
Samsung A52s. Cần đăng nhập Firebase trước khi vào Lobby.

```text
nhom_bar/
├── AGENTS.md                  Quy tắc làm việc chung
├── backend/
│   ├── src/                   API game Node.js
│   ├── bartender_ws/          Module HTTP/WebSocket Dart của Zhoufen (tùy chọn)
│   ├── tools/                 Máy xử lý quét 3D Python
│   ├── vision/                API nhận diện YOLO Python
│   └── firebase/              Backend Firebase game cũ, không cần chạy cho API HTTP
└── nhombar/                   Ứng dụng Flutter, Android và asset
```

| Thành phần | Cổng mặc định | Khi nào cần mở |
|---|---|---|
| API game Node.js | 3000 | Bartender và Rubik online |
| Máy xử lý quét 3D | 8765, HTTPS | Tạo mô hình 3D |
| API nhận diện YOLO | 8766, HTTP qua USB | Nhận diện đồ vật từ ảnh |

Ba dịch vụ chạy riêng. Chỉ mở dịch vụ cần dùng; không cài thư viện YOLO vào môi
trường máy quét 3D. Trong các bước dưới, mỗi terminal mới bắt đầu ở thư mục gốc
`nhom_bar/`, trừ chỗ có lệnh `cd` khác.

`nhombar/` là Flutter project duy nhất. Màn hình chờ mèo và asset nằm tại
`nhombar/lib/shared/widgets/cozy_loading.dart` và `nhombar/assets/loading/`.
Thư mục con `source/` giữ asset nguồn của mèo, không được đóng gói thêm lần nữa.
`backend/bartender_ws/` giữ giao thức HTTP/WebSocket gốc của Zhoufen; không cần
chạy module này cho cấu hình Node.js mặc định bên dưới. Không chuyển URL Node.js
sang cổng 8080 vì hai module có hợp đồng API khác nhau.

## 1. Chuẩn bị môi trường

Cài các công cụ sau và cho phép sử dụng chúng từ PowerShell:

- Git và Node.js 22 trở lên, kèm npm.
- Flutter có Dart tương thích `sdk: ^3.13.3` trong `nhombar/pubspec.yaml`.
  Cấu hình hiện tại đã dùng Flutter 3.47.4 với Dart 3.13.3.
- Android Studio, Android SDK Platform-Tools và SDK/build tools mà Flutter yêu cầu.
  Dùng JDK đi kèm Android Studio; để Flutter quản lý việc gọi Gradle của dự án.
- Python 3.11 nếu cần quét 3D hoặc nhận diện YOLO. Khi cài Python trên Windows,
  cài cả Python Launcher để dùng được `py -3.11`.

Mở PowerShell mới sau khi cài để nhận PATH. Xem môi trường còn thiếu gì:

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

Nhờ người quản lý kiểm tra Rules thực tế trước khi chạy. Repository không có
file Rules Firestore/Storage để tự triển khai; Rules Realtime Database cũ không
thay thế chúng. Không mở toàn bộ database bằng `allow read, write: if true` và
không ghi đè các Rules hiện có. Thiếu quyền sẽ làm hồ sơ/ảnh không đồng bộ được.

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
ví dụ `D:/FirebaseKeys/nhom-bar-admin.json`. Không thay `google-services.json`
bằng file này, không gửi khóa vào chat và không commit khóa lên Git.

Nếu đã có `backend/.env`, mở và sửa file hiện có. Nếu chưa có, tại thư mục gốc:

```powershell
Copy-Item backend/.env.example backend/.env
```

Điền cấu hình local:

```dotenv
FIREBASE_PROJECT_ID=nhom-bar
GOOGLE_APPLICATION_CREDENTIALS=D:/FirebaseKeys/nhom-bar-admin.json
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

Cổng 3000 dùng cho game; 8766 dùng khi bạn mở thêm YOLO ở bước 6. `adb reverse`
giúp `127.0.0.1` trên điện thoại truy cập dịch vụ trên máy tính qua USB.

Chạy bản debug trên đúng điện thoại đó:

```powershell
cd nhombar
flutter run -d $deviceId --dart-define=API_BASE_URL=http://127.0.0.1:3000/api/v1 --dart-define=DETECTION_API_URL=http://127.0.0.1:8766
```

Đăng ký hoặc đăng nhập để vào Lobby. Hai điện thoại chơi online cần được reverse
cổng 3000 riêng cho từng mã thiết bị; dùng cùng một backend, một máy tạo phòng
và máy kia nhập mã. Giữ các terminal server đang cần dùng mở.

Nếu rút/cắm lại cáp hoặc khởi động lại ADB, thực hiện lại các lệnh reverse.
Khi sửa phần Android/native hoặc thay cấu hình Firebase, dừng rồi chạy lại app;
hot reload không cập nhật được phần đó.

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

## 6. Nhận diện đồ vật YOLO — tùy chọn

Mở terminal mới ở thư mục gốc. Chỉ thực hiện phần cài đặt này lần đầu, hoặc khi
cần tạo lại môi trường YOLO:

```powershell
py -3.11 -m venv backend/.yolo-runtime
.\backend\.yolo-runtime\Scripts\python.exe -m pip install torch==2.6.0+cpu torchvision==0.21.0+cpu --index-url https://download.pytorch.org/whl/cpu
.\backend\.yolo-runtime\Scripts\python.exe -m pip install -e "./backend/vision[test]"
.\backend\.yolo-runtime\Scripts\python.exe -m nhombar_vision.download_model
```

`[test]` cài thêm thư viện phục vụ test, không chạy test. Lệnh tải model lấy
YOLO26n pretrained từ release Ultralytics chính thức và xác minh SHA-256. Không
train hoặc fine-tune. Môi trường và trọng số nằm trong `backend/.yolo-runtime/`,
được Git bỏ qua; cần Internet cho lần cài/tải đầu.

Mỗi lần cần nhận diện, chỉ chạy lệnh sau và giữ terminal mở:

```powershell
.\backend\.yolo-runtime\Scripts\python.exe -m nhombar_vision
```

Đợi server báo sẵn sàng. API chỉ nghe tại `127.0.0.1:8766` trên PC, kiểm tra
trạng thái tại http://127.0.0.1:8766/health. Ứng dụng dùng ADB reverse ở bước 5;
không đổi sang địa chỉ HTTP LAN hoặc công khai cổng ra Internet.

Trong Lobby, chạm **Máy ảnh trên kệ TV → Nhận diện đồ vật**. Chọn **Mở camera →
Chụp ảnh**, hoặc **Chọn ảnh**. Có thể bắt đầu với táo, chuối, cốc, sách, ghế và
chai. API `POST /api/v1/detect` nhận JPEG/PNG tối đa 8 MB; trả nhãn Việt/Anh,
confidence và khung theo tọa độ ảnh. Model chỉ nhận các lớp pretrained hỗ trợ.

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
nếu IP/chứng chỉ đổi, dùng QR mới hoặc kết nối USB lại. YOLO và máy quét 3D dùng
hai terminal, hai môi trường riêng, không thay thế lẫn nhau.

## 8. Khi chưa chạy được

| Hiện tượng | Cách xử lý |
|---|---|
| Không tìm thấy `flutter`, `node`, `git` hoặc `py` | Cài đúng công cụ, kiểm tra PATH rồi mở terminal mới. |
| ADB báo `unauthorized` | Mở khóa điện thoại, chấp nhận quyền USB rồi chạy lại `adb devices -l`. |
| ADB không thấy điện thoại | Kiểm tra Gỡ lỗi USB, cáp truyền dữ liệu và driver USB của hãng. |
| Backend báo `EADDRINUSE` ở cổng 3000 | Mở trang health. Nếu API đang chạy, dùng server đó; không khởi động bản thứ hai. Nếu tiến trình khác chiếm cổng, xác định đúng tiến trình trước khi dừng. |
| App không gọi được API game/YOLO | Kiểm tra server tương ứng còn mở và chạy lại reverse cổng 3000/8766 cho đúng mã máy. |
| Google không đăng nhập được | Kiểm tra provider, SHA của khóa ký và file JSON có OAuth client của đúng project/app. |
| Hồ sơ/ảnh báo thiếu quyền | Nhờ chủ project kiểm tra Firestore/Storage Rules theo UID; không mở quyền toàn bộ. |
| YOLO báo thiếu model | Tại thư mục gốc, chạy lại lệnh `python.exe -m nhombar_vision.download_model` bằng Python trong `.yolo-runtime`. |
| Máy quét 3D chưa sẵn sàng | Xem lỗi ở cửa sổ launcher, kiểm tra thư viện/kết nối và ghép QR/USB lại; không mở camera xử lý khi server chưa sẵn sàng. |
| Cài APK báo khác chữ ký | Dừng và dùng đúng khóa ký. Không gỡ app để chữa nhanh vì sẽ mất mô hình lưu trên điện thoại. |

Dừng server bằng `Ctrl+C` trong terminal của chính server đó. Không xóa dữ liệu,
trọng số hay cài lại toàn bộ môi trường khi chưa biết nguyên nhân lỗi.
