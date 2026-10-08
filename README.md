# Game Bartender (`nhom_bar`)

Ứng dụng Flutter gồm nhiều trò chơi mini trong một sảnh (lobby). Hiện tại chức năng hoàn chỉnh nhất là **Rubik Solver**: quét hoặc nhập màu khối Rubik, giải bằng thuật toán và hướng dẫn từng bước với khối Rubik 3D.

> Tài liệu này hướng dẫn **từ máy tính trống** đến khi chạy được ứng dụng trên Windows. Mỗi bước đều có ba phần: **Thao tác** → **Kết quả mong đợi** → **Nếu không thành công**.

## Mục lục

1. [Giới thiệu dự án và chức năng chính](#1-giới-thiệu-dự-án-và-chức-năng-chính)
2. [Yêu cầu hệ thống](#2-yêu-cầu-hệ-thống)
3. [Cài đặt Flutter SDK từ đầu](#3-cài-đặt-flutter-sdk-từ-đầu)
4. [Cài đặt Android Studio và Android SDK](#4-cài-đặt-android-studio-và-android-sdk)
5. [Kiểm tra môi trường bằng `flutter doctor`](#5-kiểm-tra-môi-trường-bằng-flutter-doctor)
6. [Tải mã nguồn từ GitHub](#6-tải-mã-nguồn-từ-github)
7. [Mở dự án bằng VS Code](#7-mở-dự-án-bằng-vs-code)
8. [Tải thư viện bằng `flutter pub get`](#8-tải-thư-viện-bằng-flutter-pub-get)
9. [Cấu hình các dịch vụ cần thiết](#9-cấu-hình-các-dịch-vụ-cần-thiết)
10. [Tạo và khởi động máy ảo Android](#10-tạo-và-khởi-động-máy-ảo-android)
11. [Kết nối điện thoại Android thật](#11-kết-nối-điện-thoại-android-thật)
12. [Chạy ứng dụng bằng `flutter run`](#12-chạy-ứng-dụng-bằng-flutter-run)
13. [Kiểm tra các chức năng sau khi chạy](#13-kiểm-tra-các-chức-năng-sau-khi-chạy)
14. [Các lỗi thường gặp và cách khắc phục](#14-các-lỗi-thường-gặp-và-cách-khắc-phục)

---

## 1. Giới thiệu dự án và chức năng chính

**Game Bartender** là ứng dụng di động viết bằng Flutter. Màn hình đầu tiên là sảnh với ba điểm chạm:

| Điểm chạm trong sảnh | Trạng thái |
| --- | --- |
| **Chơi Rubik** | Hoàn chỉnh – xem mô tả bên dưới |
| **Máy arcade** | Đang phát triển (hiện thông báo "đang phát triển") |
| **Quầy Bartender** | Đang phát triển (hiện thông báo "đang phát triển") |

**Chức năng Rubik Solver:**

- **Nhập màu thủ công**: tự nhập màu của 6 mặt, khối 3D phía trên đổi màu theo thời gian thực.
- **Quét bằng camera** (Android): chụp lần lượt 6 mặt, nhận diện màu, cho phép sửa lại từng ô trước khi giải.
- **Kiểm tra hợp lệ và giải**: kiểm tra trạng thái khối có thể xảy ra thật, sau đó tìm lời giải bằng thư viện `cuber`.
- **Hướng dẫn từng bước**: nút *Bước trước / Bước tiếp*, khối 3D cập nhật theo trạng thái sau mỗi bước.
- **Khối Rubik 3D** (phần công nghệ 3D của nhóm): mô hình tạo bằng **Blender** (Polygon Modeling), xuất ra **glTF/GLB**, hiển thị bằng **Three.js (WebGL)** trong `WebView` của Flutter.
- **Thách đấu**: đang phát triển.

**Công nghệ:** Flutter/Dart · `webview_flutter` · `camera` · `image` · `cuber` · Three.js · Blender.

**Cấu trúc thư mục chính:**

```text
lib/games/rubik/    Mã Dart của game Rubik (màn hình, bộ giải, nhận diện camera)
lib/screens/home/   Sảnh (lobby)
assets/rubik/       Trang 3D: rubik.glb (model), rubik-src.js (nguồn), rubik.js (bản đã build), demo.html
tools/blender/      make_rubik.py (script Blender), rubik.blend (file Blender)
docs/               Tài liệu chi tiết từng phần
test/               Test tự động
```

---

## 2. Yêu cầu hệ thống

| Hạng mục | Yêu cầu |
| --- | --- |
| Hệ điều hành | Windows 10 hoặc 11, 64-bit |
| Cấu hình khuyến nghị | RAM từ 8 GB, ổ đĩa trống từ 10 GB (Flutter + Android Studio + Android SDK + máy ảo) |
| Flutter SDK | Bản **stable** mới (Flutter 3.47 trở lên, cần **Dart SDK ≥ 3.13.3** – xem `pubspec.yaml`) |
| Android Studio | Bản mới nhất, kèm Android SDK, Command-line Tools, Platform-Tools |
| VS Code | Bản mới nhất, cài extension **Flutter** và **Dart** |
| Git | Bản mới nhất |
| Thiết bị chạy | Máy ảo Android **hoặc** điện thoại Android thật, Android 7.0 (API 24) trở lên |
| Camera | Nên dùng điện thoại thật để thử chức năng quét Rubik |
| *(Tuỳ chọn)* Node.js LTS, Blender 4.x | Chỉ cần nếu muốn sửa mô hình 3D (xem [mục 9](#9-cấu-hình-các-dịch-vụ-cần-thiết)); **không cần** để chạy ứng dụng |

Tải công cụ từ trang chính thức:

1. [Flutter SDK](https://docs.flutter.dev/install)
2. [Android Studio](https://developer.android.com/studio)
3. [Visual Studio Code](https://code.visualstudio.com/download)
4. [Git](https://git-scm.com/downloads)

> Nên tải từ trang chính thức để đảm bảo an toàn và tính tương thích.

---

## 3. Cài đặt Flutter SDK từ đầu

**Thao tác**

1. Cài **Git** trước (Flutter dùng Git để quản lý SDK).
2. Vào <https://docs.flutter.dev/install>, chọn Windows → Android và tải file `.zip` của Flutter SDK bản stable.
3. Giải nén vào một đường dẫn **không có dấu cách và không cần quyền admin**, ví dụ `C:\src\flutter` (không dùng `C:\Program Files`).
4. Thêm Flutter vào `PATH`: mở *Start* → gõ **Edit the system environment variables** → *Environment Variables* → chọn `Path` của user → *Edit* → *New* → nhập `C:\src\flutter\bin` → OK.
5. **Đóng và mở lại** terminal (PowerShell hoặc CMD), chạy:

   ```bash
   flutter --version
   ```

**Kết quả mong đợi:** terminal in ra phiên bản Flutter (kênh `stable`) và phiên bản Dart từ 3.13.3 trở lên.

**Nếu không thành công**

- Báo `'flutter' is not recognized`: `PATH` chưa đúng hoặc chưa mở lại terminal. Kiểm tra đúng đường dẫn đến thư mục `bin`.
- Dart thấp hơn 3.13.3 (lỗi ở [mục 8](#8-tải-thư-viện-bằng-flutter-pub-get)): chạy `flutter upgrade`. Nếu đang ở kênh khác, chạy `flutter channel stable` rồi `flutter upgrade`.
- Báo thiếu Git: cài Git rồi mở lại terminal.

---

## 4. Cài đặt Android Studio và Android SDK

**Thao tác**

1. Tải và cài [Android Studio](https://developer.android.com/studio). Lần mở đầu tiên, chọn **Standard** trong *Setup Wizard* để nó tự tải Android SDK.
2. Mở *More Actions* (hoặc *Tools*) → **SDK Manager**:
   - Tab **SDK Platforms**: tick một bản Android mới nhất.
   - Tab **SDK Tools**: tick **Android SDK Command-line Tools (latest)**, **Android SDK Build-Tools**, **Android SDK Platform-Tools**, **Android Emulator** → *Apply*.
3. Chấp nhận giấy phép Android:

   ```bash
   flutter doctor --android-licenses
   ```

   Nhập `y` cho tất cả câu hỏi.
4. *(Khuyến nghị)* Trong Android Studio: *Settings → Plugins*, cài **Flutter** và **Dart**.

**Kết quả mong đợi:** SDK Manager hiển thị các mục trên ở trạng thái *Installed*; lệnh `--android-licenses` kết thúc với dòng `All SDK package licenses accepted`.

**Nếu không thành công**

- `cmdline-tools component is missing`: quay lại SDK Manager → SDK Tools, cài *Android SDK Command-line Tools*.
- `Unable to locate Android SDK`: chỉ đường dẫn thủ công, ví dụ `flutter config --android-sdk "C:\Users\<tên>\AppData\Local\Android\Sdk"`.
- Tải SDK chậm hoặc treo: kiểm tra mạng, thử lại; nếu dùng proxy, cấu hình trong *Settings → HTTP Proxy*.

---

## 5. Kiểm tra môi trường bằng `flutter doctor`

**Thao tác**

```bash
flutter doctor -v
```

**Kết quả mong đợi:** các mục sau có dấu `[✓]`:

- Flutter (channel stable)
- Windows Version
- Android toolchain – develop for Android devices
- Android Studio
- VS Code
- Connected device *(chỉ có khi đã bật máy ảo hoặc cắm điện thoại ở mục 10–11)*
- Network resources

> Mục **Visual Studio – develop Windows apps** hoặc **Chrome** có thể báo lỗi. Có thể bỏ qua vì nhóm chỉ chạy ứng dụng trên Android.

**Nếu không thành công**

- `[✗] Android toolchain`: làm theo dòng gợi ý ngay dưới mục đó (thường là thiếu Command-line Tools hoặc chưa chấp nhận license, xem [mục 4](#4-cài-đặt-android-studio-và-android-sdk)).
- `[!] Android Studio` báo thiếu plugin: cài plugin Flutter và Dart trong Android Studio.
- Sau khi sửa, chạy lại `flutter doctor -v` cho đến khi các mục ở trên đều xanh.

---

## 6. Tải mã nguồn từ GitHub

**Thao tác**

```bash
cd C:\
mkdir projects
cd projects
git clone https://github.com/HoaiThuong-gif/Game_Bartender.git
cd Game_Bartender
git checkout rubik/3d_update
```

> Cách khác không cần Git: trên trang GitHub, chọn đúng nhánh → **Code → Download ZIP** → giải nén.

**Kết quả mong đợi:** thư mục `Game_Bartender` chứa `pubspec.yaml`, `lib/`, `assets/`, `android/`. Lệnh `git branch` hiển thị nhánh đang dùng.

**Nếu không thành công**

- `'git' is not recognized`: cài Git và mở lại terminal.
- Lỗi mạng hoặc `repository not found`: kiểm tra Internet và đường dẫn; nếu repo ở chế độ private, nhờ chủ repo thêm tài khoản của bạn.
- Lỗi đường dẫn quá dài trên Windows: clone vào thư mục ngắn như `C:\projects`.

---

## 7. Mở dự án bằng VS Code

**Thao tác**

1. Mở VS Code → *File → Open Folder…* → chọn thư mục `Game_Bartender` (thư mục chứa `pubspec.yaml`), hoặc chạy `code .` trong terminal.
2. Cài extension **Flutter** và **Dart** nếu VS Code gợi ý (hoặc vào tab *Extensions* tìm hai tên này).
3. Mở file `lib/main.dart` để VS Code nhận diện dự án.

**Kết quả mong đợi:** cột *Explorer* hiện `lib`, `assets`, `android`...; thanh trạng thái phía dưới bên phải hiển thị tên thiết bị (hoặc `No Device`); `main.dart` không bị gạch lỗi đỏ về `package:flutter`.

**Nếu không thành công**

- Không thấy thanh chọn thiết bị: chưa cài extension Flutter. Cài rồi chạy lại *Developer: Reload Window*.
- Báo lỗi không tìm thấy Flutter SDK: bấm *Locate SDK* và chọn `C:\src\flutter`, hoặc kiểm tra lại `PATH` ([mục 3](#3-cài-đặt-flutter-sdk-từ-đầu)).
- Mở nhầm thư mục cha: đóng và mở lại đúng thư mục có `pubspec.yaml`.

---

## 8. Tải thư viện bằng `flutter pub get`

**Thao tác:** trong thư mục dự án, chạy:

```bash
flutter pub get
```

Các thư viện chính được tải: `cuber`, `webview_flutter`, `camera`, `image`, `cupertino_icons`.

**Kết quả mong đợi:** kết thúc với dòng `Got dependencies!` (có thể kèm thông báo có phiên bản mới hơn, bỏ qua được).

**Nếu không thành công**

- `version solving failed` / `requires SDK version ^3.13.3`: Flutter của bạn cũ. Chạy `flutter upgrade`, sau đó chạy lại.
- Lỗi mạng khi tải gói (`Could not resolve host`, `timeout`): kiểm tra Internet, tắt VPN/proxy, thử lại.
- Vẫn lỗi: chạy `flutter clean` rồi `flutter pub get`.

---

## 9. Cấu hình các dịch vụ cần thiết

Ứng dụng **không cần** tài khoản, API key, Firebase hay file cấu hình bí mật nào để chạy. Chỉ cần lưu ý:

**9.1. Quyền camera (đã khai báo sẵn)**

- **Thao tác:** không cần chỉnh gì. `AndroidManifest.xml` đã khai báo quyền `CAMERA`. Khi lần đầu vào chức năng quét, chọn **Cho phép / Allow**.
- **Kết quả mong đợi:** màn hình quét hiển thị hình xem trước từ camera.
- **Nếu không thành công:** nếu đã lỡ từ chối, ứng dụng hiện hướng dẫn mở Cài đặt. Vào *Cài đặt → Ứng dụng → nhom_bar → Quyền → Camera → Cho phép*. Nếu không có camera, vẫn dùng được *Nhập màu thủ công*.

**9.2. Sửa mô hình 3D (tuỳ chọn – không cần để chạy ứng dụng)**

Mô hình sẵn dùng nằm tại `assets/rubik/rubik.glb`, và `assets/rubik/rubik.js` là bản đã build sẵn. Chỉ làm bước này khi muốn thay đổi hình dạng hoặc code 3D.

- **Thao tác:**
  1. Cài [Node.js LTS](https://nodejs.org/) và [Blender 4.x](https://www.blender.org/download/).
  2. *(Chỉ khi sửa hình dạng khối)* Tạo lại model: `blender --background --python tools/blender/make_rubik.py` (nếu `blender` chưa có trong `PATH`, dùng đường dẫn đầy đủ tới `blender.exe`).
  3. Build lại trang 3D:

     ```bash
     npm install
     npm run build:rubik
     ```
- **Kết quả mong đợi:** lệnh Blender in ra dòng `wrote ...rubik.glb`; lệnh build tạo lại `assets/rubik/rubik.js` không báo lỗi. Có thể mở `assets/rubik/demo.html` bằng trình duyệt để xem nhanh khối 3D (có nút đổi trạng thái và bật/tắt lưới polygon).
- **Nếu không thành công:** `blender` hoặc `npm` không nhận → dùng đường dẫn đầy đủ hoặc thêm vào `PATH`; `npm install` lỗi mạng → thử lại. Script Blender chỉ chạy **bên trong Blender** nên **không có** `requirements.txt` và không cần cài thư viện Python.

---

## 10. Tạo và khởi động máy ảo Android

**Thao tác**

1. Mở Android Studio → *More Actions → Virtual Device Manager* (hoặc *Tools → Device Manager*).
2. Bấm **Create Device**, chọn một điện thoại (ví dụ *Pixel*) → *Next*.
3. Chọn **System Image** (tab *Recommended*, kiểu `x86_64`, Android 7.0 / API 24 trở lên; nên chọn bản có *Google APIs*) → tải về nếu chưa có → *Next* → *Finish*.
4. Bấm nút ▶ (**Start**) cạnh máy ảo vừa tạo.
5. Kiểm tra:

   ```bash
   flutter devices
   ```

**Kết quả mong đợi:** máy ảo khởi động đến màn hình chính Android; `flutter devices` liệt kê một thiết bị dạng `sdk gphone... (mobile) • emulator-5554`.

**Nếu không thành công**

- Báo cần bật ảo hoá / `VT-x` / `AMD-V`: vào BIOS bật *Virtualization*, và trong Windows bật tính năng *Windows Hypervisor Platform* (*Turn Windows features on or off*), rồi khởi động lại máy.
- Máy ảo rất chậm hoặc treo: giảm độ phân giải, tăng RAM cho máy ảo trong *Advanced Settings*, hoặc dùng điện thoại thật ([mục 11](#11-kết-nối-điện-thoại-android-thật)).
- Chức năng quét camera trên máy ảo chỉ thấy cảnh giả lập, nên không phản ánh đúng khi thử nhận diện màu. Hãy thử quét trên điện thoại thật.

---

## 11. Kết nối điện thoại Android thật

**Thao tác**

1. Trên điện thoại: *Cài đặt → Giới thiệu điện thoại* → bấm **Số bản dựng (Build number)** 7 lần để bật *Tuỳ chọn nhà phát triển*.
2. *Cài đặt → Tuỳ chọn nhà phát triển* → bật **Gỡ lỗi USB (USB debugging)**.
3. Cắm điện thoại vào máy tính bằng cáp **có truyền dữ liệu**. Khi điện thoại hỏi *Cho phép gỡ lỗi USB?* → chọn **Luôn cho phép / Allow**.
4. Kiểm tra:

   ```bash
   flutter devices
   ```

**Kết quả mong đợi:** điện thoại xuất hiện trong danh sách, ví dụ `SM-A546E (mobile) • RF8... • android-arm64 • Android 14`.

**Nếu không thành công**

- Không thấy thiết bị: thử đổi cáp (nhiều cáp chỉ sạc), đổi cổng USB, chọn chế độ *Truyền tệp (File transfer)* trên điện thoại.
- Trạng thái `unauthorized`: rút cáp, cắm lại và bấm *Allow* trên điện thoại. Nếu không hiện hộp thoại, vào *Tuỳ chọn nhà phát triển → Thu hồi quyền gỡ lỗi USB* rồi cắm lại.
- Windows không nhận máy: cài USB driver của hãng điện thoại (Samsung, Xiaomi, Oppo...).

---

## 12. Chạy ứng dụng bằng `flutter run`

**Thao tác:** trong thư mục dự án, với máy ảo đang chạy hoặc điện thoại đang cắm:

```bash
flutter run
```

Nếu có nhiều thiết bị, chọn thiết bị bằng `flutter run -d <device-id>` (lấy `<device-id>` từ `flutter devices`). Trong VS Code, có thể nhấn **F5** hoặc *Run → Start Debugging*.

**Kết quả mong đợi:** lần chạy đầu tiên build lâu (vài phút do Gradle tải thành phần). Sau đó terminal hiện `Built build\app\outputs\flutter-apk\app-debug.apk` và ứng dụng mở ra ở **sảnh (lobby)**. Khi đang chạy: nhấn `r` để hot reload, `R` để hot restart, `q` để thoát.

**Nếu không thành công**

- Dừng ở bước `Running Gradle task 'assembleDebug'` quá lâu: bình thường ở lần đầu; nếu quá 15–20 phút, kiểm tra mạng và thử lại.
- Lỗi Gradle hoặc build cache: chạy theo thứ tự `flutter clean` → `flutter pub get` → `flutter run`.
- Báo `Building with plugins requires symlink support`: bật **Developer Mode** của Windows (chạy `start ms-settings:developers`, bật *Developer Mode*), rồi chạy lại.
- Báo `No supported devices connected`: quay lại [mục 10](#10-tạo-và-khởi-động-máy-ảo-android) hoặc [mục 11](#11-kết-nối-điện-thoại-android-thật).
- Các lỗi khác: xem [mục 14](#14-các-lỗi-thường-gặp-và-cách-khắc-phục).

---

## 13. Kiểm tra các chức năng sau khi chạy

Làm lần lượt các bước sau trên ứng dụng đang chạy:

| # | Thao tác | Kết quả mong đợi | Nếu không đúng |
| --- | --- | --- | --- |
| 1 | Mở ứng dụng | Hiện sảnh với 3 điểm chạm: Máy arcade, Quầy Bartender, Chơi Rubik | Chạy lại `flutter clean` → `flutter run` |
| 2 | Chạm **Máy arcade** hoặc **Quầy Bartender** | Hiện thông báo "... đang phát triển." | — (chức năng chưa làm) |
| 3 | Chạm **Chơi Rubik** | Màn hình **RUBIK** hiện khối Rubik 3D bo cạnh với 6 màu. Kéo một ngón để xoay, chụm hai ngón để thu/phóng | Xem mục 14 (khối 3D không hiện) |
| 4 | Chạm **THÁCH ĐẤU** | Hiện màn hình giới thiệu "đang phát triển" | — |
| 5 | Chạm **GIẢI RUBIK** | Hiện hai lựa chọn: **QUÉT RUBIK BẰNG CAMERA** và **NHẬP MÀU THỦ CÔNG** | — |
| 6 | Chọn **NHẬP MÀU THỦ CÔNG**, nhập màu cho từng ô | Khối 3D phía trên **đổi màu theo đúng ô vừa nhập** | Xem mục 14 (màu 3D không đổi) |
| 7 | Nhập đủ 54 ô hợp lệ rồi bấm nút giải | Chuyển sang màn **HƯỚNG DẪN GIẢI**, hiển thị "Bước 1 / N" | Nếu báo "Chưa tìm được lời giải", kiểm tra lại màu: mỗi màu đúng 9 ô, 6 ô tâm khác nhau |
| 8 | Bấm **Bước tiếp** / **Bước trước** | Số bước thay đổi, khối 3D cập nhật màu theo trạng thái sau mỗi bước; hết bước hiện "Rubik đã được giải!" | Xem mục 14 |
| 9 | Chọn **QUÉT RUBIK BẰNG CAMERA** *(nên dùng điện thoại thật)* | Hỏi quyền camera; sau khi cho phép, chụp lần lượt các mặt, có thể **Chụp lại**, sửa màu từng ô, **Xác nhận mặt**, rồi **Kiểm tra & Giải** | Xem mục 9.1 và mục 14 |

> Hiện tại khối 3D **cập nhật màu theo từng bước**; hiệu ứng xoay từng lớp khi bấm *Bước tiếp* chưa có.

**Kiểm tra tự động (tuỳ chọn):**

```bash
flutter analyze
flutter test
node --test test/rubik_render_test.cjs
```

Kết quả mong đợi: không có lỗi; các test đều **pass** (lệnh `node --test` cần đã chạy `npm install`).

---

## 14. Các lỗi thường gặp và cách khắc phục

| Lỗi / Hiện tượng | Nguyên nhân thường gặp | Cách khắc phục |
| --- | --- | --- |
| `'flutter' is not recognized` | Chưa thêm `flutter\bin` vào `PATH`, hoặc chưa mở lại terminal | Thêm vào `PATH` ([mục 3](#3-cài-đặt-flutter-sdk-từ-đầu)), mở lại terminal |
| `version solving failed` / yêu cầu SDK `^3.13.3` | Flutter/Dart quá cũ | `flutter upgrade`, rồi `flutter pub get` |
| `cmdline-tools component is missing` | Chưa cài Android SDK Command-line Tools | SDK Manager → SDK Tools → cài *Command-line Tools* |
| `Android license status unknown` / chưa chấp nhận license | Chưa đồng ý giấy phép | `flutter doctor --android-licenses`, nhập `y` |
| `Unable to locate Android SDK` | Flutter không biết đường dẫn SDK | `flutter config --android-sdk "<đường dẫn SDK>"` |
| `No supported devices connected` | Chưa bật máy ảo / chưa cắm điện thoại | Làm theo mục 10 hoặc 11, kiểm tra bằng `flutter devices` |
| Điện thoại hiện `unauthorized` | Chưa bấm cho phép gỡ lỗi USB | Rút cắm lại cáp, bấm *Allow* trên điện thoại |
| `Building with plugins requires symlink support` | Windows chưa bật Developer Mode | `start ms-settings:developers` → bật *Developer Mode* |
| Gradle build rất lâu hoặc thất bại | Lần đầu tải phụ thuộc, mạng yếu, cache hỏng | Đợi lần đầu, kiểm tra mạng; thử `flutter clean` → `flutter pub get` → `flutter run` |
| Máy ảo không khởi động / rất chậm | Chưa bật ảo hoá, máy yếu | Bật *Virtualization* trong BIOS và *Windows Hypervisor Platform*; hoặc dùng điện thoại thật |
| Không quét được camera | Chưa cấp quyền camera | *Cài đặt → Ứng dụng → nhom_bar → Quyền → Camera → Cho phép*; dùng *Nhập màu thủ công* nếu máy không có camera |
| **Khối Rubik 3D trống / không hiện** | WebView không tải được trang 3D | Thử máy thật hoặc cập nhật *Android System WebView*; chạy `flutter clean` rồi chạy lại; mở `assets/rubik/demo.html` trên trình duyệt để biết lỗi nằm ở model hay ở ứng dụng; xem log trong terminal `flutter run` |
| **Màu khối 3D không đổi** | `assets/rubik/rubik.js` hoặc `rubik.glb` là bản cũ không khớp nhau | Chạy `npm install` rồi `npm run build:rubik` để build lại; đảm bảo `rubik.glb` là bản mới nhất của nhánh; chạy lại ứng dụng bằng `flutter run` (không chỉ hot reload) |
| Sửa file trong `assets/rubik/` mà ứng dụng không đổi | Asset được đóng gói lúc build | Dừng ứng dụng, chạy lại `flutter run` |

Nếu vẫn lỗi, chạy `flutter doctor -v` và `flutter run -v`, rồi gửi phần log lỗi cho nhóm.

---

## Tài liệu thêm

Xem thư mục `docs/`: `rubik-foundation.md` (nền tảng và luồng dữ liệu Rubik), `rubik-camera.md` (nhập bằng camera), `lobby.md` (bố cục sảnh).