# Rubik 1v1

## Chạy thử

Vào **Rubik → Thách đấu**. Bản debug có công tắc **Thử một máy**:
tạo phòng, đối thủ mô phỏng vào sau 1 giây, sẵn sàng, tải đề, countdown,
đối thủ hoàn thành sau khoảng 20 giây kể từ GO. Giải cube rồi bấm Hoàn thành;
kết quả và chơi lại dùng cùng repository interface với online. Demo không cộng cá thật.
Nếu không giải trong 5 phút, người chơi được đánh dấu DNF.

## Cấu hình online còn cần

Project đã có `lib/firebase_options.dart`, `android/app/google-services.json`,
Google Services Gradle plugin, `firebase_core` và `firebase_database`.
Đã thêm `firebase_auth: ^6.7.0`; chưa có hệ thống đăng nhập riêng nên dùng Anonymous Auth.
Không tạo/thay credential. Firebase chỉ được khởi tạo khi mở challenge online;
các module khác vẫn khởi động bình thường khi chưa cấu hình RTDB.

1. Trong Firebase project `nhom-bar`, tạo Realtime Database, lấy **đúng URL** từ console.
2. Bật Authentication → Sign-in method → Anonymous.
3. Kiểm tra region trong `functions/index.js` khớp region RTDB, mặc định `asia-southeast1`.
4. Dùng Node 22, chạy `npm ci` trong thư mục `functions`.
5. Triển khai backend và rules sau khi kiểm tra phạm vi rules hiện có:

```powershell
firebase deploy --project nhom-bar --only functions:rubik,database
flutter run --dart-define=RUBIK_DATABASE_URL=https://YOUR-DATABASE-URL
```

URL ở trên là placeholder; thay bằng URL console cung cấp. Không suy đoán namespace/region.
Chưa triển khai vào Firebase thật trong tác vụ này. Functions/scheduler yêu cầu
project có Blaze billing; không tự bật billing. Nguồn:
[Firebase Functions setup](https://firebase.google.com/docs/functions/get-started).
Các platform ngoài Android chưa có Firebase options; cấu hình bằng FlutterFire nếu cần.

## Schema và authority

Backend dùng **Realtime Database, không dùng Firestore**:

```text
rubikRooms/{CODE}
  hostId, creationId, createdAt, updatedAt, round
  status: waiting | ready | countdown | playing | finished
  scramble: [20 notation moves]          // có sau khi cả hai ready
  startAt                              // có sau khi cả hai loaded
  winnerId: UID | draw | none           // chỉ có khi kết thúc
  endedAt, rewards: { UID: amount }     // chỉ có khi kết thúc
  players/{UID}
    name, ready, loaded, finished, dnf, left, rematch
    finishAt, finishMs                  // chỉ có khi hoàn thành
rubikCommands/{UID}/{requestId}: action, code, round, name, at
rubikResponses/{UID}/{requestId}: ok, error?
rubikPresence/{CODE}/{UID}: online, at
rubikRewards/{UID}/{creationId_round}: amount, code, round, issuedAt
```

Client chỉ được tạo command của chính UID và cập nhật presence của chính mình.
Timestamp command/presence bắt buộc `ServerValue.timestamp` (`at == now` trong rules).
Cloud Function nhận command, chạy transaction trên một room; chỉ Admin SDK ghi
room, finishAt, winner, reward receipt. Người thứ ba bị từ chối trong transaction.
Client chỉ đọc phòng nếu thuộc phòng; chỉ đọc response/reward của chính UID.
`database.rules.json` từ chối mọi nhánh ngoài các nhánh trên. Nếu database dùng
cho tính năng khác, merge rules của chúng trước khi deploy, không mở `.write: true`.

## Đồng bộ và gameplay

- Backend sinh scramble đúng một lần khi cả hai ready; 20 bước, không lặp trục liên tiếp
  (vì vậy không có face/inverse sát nhau). Scramble không đổi trong trận.
- Hai máy áp dụng notation vào cùng engine Three.js hiện có. Không gửi move, rotation,
  cube state hoặc frame lên mạng. Reset/undo của màn Rubik chính được ẩn và vô hiệu hóa trong trận.
- Mỗi máy gửi `loaded` sau khi cube đã áp dụng đề. Sau cả hai loaded,
  backend đặt `startAt = backend server time + 5000ms`. Hai giây chuẩn bị rồi 3–2–1–GO.
- Client đọc `.info/serverTimeOffset`; đồng hồ UI cập nhật 50ms,
  `elapsed = estimatedServerNow - startAt`, định dạng `mm:ss.mmm`.
  Ticker không ghi timer vào database. Command `tick` tối đa mỗi 5 giây/client
  chỉ yêu cầu backend xét chuyển trạng thái/timeout; scheduler hỗ trợ khi cả hai offline.
- Solved được xác định local bằng màu sticker đồng nhất trên sáu hướng;
  chỉ bật Hoàn thành khi prepared + GO + solved. WebView được giữ khi vào background;
  resume giữ tiến trình cube và timer vẫn tính từ mốc chung (tiến trình chưa persist khi process bị kill).
- Backend ghi finish đúng một lần qua transaction, dùng thời gian RTDB nhận command
  làm finishAt, không dùng latency khi Function chạy hoặc số giây client gửi.
  finishMs = finishAt - startAt. Nút tắt ngay khi submit; retry không sửa finishAt.
- Cả hai tiếp tục giải để có hai thời gian. Khi cả hai finished/DNF,
  finishAt thấp hơn thắng; cùng millisecond hòa; cả hai DNF có winner `none`.
  Giới hạn toàn trận 5 phút. Thắng 50, thua có hoàn thành 10, hòa 25, DNF 0.

## Thưởng và giới hạn prototype

Backend phát receipt bất biến theo creationId + round; client chỉ đọc receipt đó.
`RubikRewardService` chuyển receipt vào ví Gacha hiện tại qua API dùng chung.
Ví v2 lưu balance + danh sách receipt trong **một JSON value**, serialize cả spend/credit,
migrate số dư v1; mở lại kết quả hoặc khởi động lại không nhận trùng.
Thưởng chưa nhận được tự thử lại khi kết quả mở, và đồng bộ lại khi vào challenge online.

Ví Gacha vẫn là local SharedPreferences: người chỉnh dữ liệu máy vẫn sửa được số dư,
xóa dữ liệu/cài lại có thể nhận lại receipt cùng tài khoản. Đây chưa phải ví chống gian lận
production. TODO chuyển **toàn bộ balance/spending** sang backend dùng ledger transaction.
UI solved check cũng không chứng minh người dùng đã giải cho server; client sửa đổi có thể
gửi finish sau GO. Prototype không gửi move/state; không quảng bá như hệ anti-cheat hoàn chỉnh.
Race với timeout khi Function xử lý command bị trì hoãn quá lâu cần authority queue/ordered
processing nếu dùng cho cuộc thi chính xác; thời gian nhận command bao gồm độ trễ mạng uplink.

## Disconnect, rematch, cleanup

`onDisconnect` đặt online=false cùng server timestamp; reconnect tự đăng ký lại.
App vào background cũng ghi offline. Grace 30 giây; backend xét qua tick (khi có đối thủ)
hoặc scheduler mỗi phút (cả hai offline), vì vậy phát hiện có thể muộn thêm tối đa khoảng 1 phút.
Rời trước GO loại player, reset waiting/readiness/scramble; người còn lại trở thành host.
Rời giữa trận đánh DNF nếu chưa finish; người còn lại cần hoàn thành để nhận thắng.
Nút Về sảnh gửi leave, cả hai rời thì xóa room. Phòng quá 24 giờ được scheduler xóa;
command/response hơn 1 giờ được xóa, reward receipts được giữ để đồng bộ lại.
Hai người phải gửi rematch, cùng round; backend tăng round, reset ready/finish/results,
chờ ready mới và sinh đề mới. Command round cũ bị từ chối.

## File thay đổi

- `challenge/models/rubik_room.dart`: room, player, enum, timer formatting.
- `challenge/services/rubik_challenge_service.dart`: interface và Firebase adapter.
- `challenge/services/mock_rubik_challenge_service.dart`: demo một máy.
- `challenge/services/rubik_reward_service.dart`: receipt → shared wallet.
- `challenge/controllers/rubik_challenge_controller.dart`: realtime subscription, ticker, actions.
- `challenge/screens/rubik_challenge_lobby_screen.dart`, `rubik_challenge_room_screen.dart`:
  sảnh, waiting/game/result theo state. Không cần tạo các route riêng cho từng trạng thái.
- `screens/rubik_screen.dart`: thay placeholder bằng lobby.
- `widgets/rubik_interactive_preview.dart`, `assets/rubik/interactive-src.js`,
  `interactive-cube.mjs`, `interactive.js`: reuse engine, scramble/lock/solved bridge.
- `lib/games/gacha/services/gacha_wallet.dart`: API receipt và lưu atomically.
  Không thay Gacha UI, solver, scan hoặc tutorial.
- `pubspec.yaml`, `pubspec.lock`: Firebase Auth.
- `functions/`: backend, dependency lock, unit tests, emulator check.
- `database.rules.json`, `firebase.json`, `firebase.emulator.json`: rules và cấu hình.
- `test/rubik_challenge_test.dart`, `test/rubik_challenge_cube_test.mjs`: tests bổ sung.

## Kiểm tra

```powershell
flutter pub get
flutter analyze
flutter test
node --test functions/test/challenge.test.js test/rubik_challenge_cube_test.mjs test/rubik_interactive_test.mjs
firebase emulators:exec --config firebase.emulator.json --project demo-rubik --only auth,database,functions "node functions/emulator-check.js"
```

Emulator check dùng REST với hai token Auth khác nhau, kiểm tra create/join, capacity,
shared scramble/start, prepared handshake, double finish, kết quả/receipt, rematch/round cũ,
không đọc phòng của người khác, không sửa winner/finish đối thủ/reward/timestamp.
Không kết nối Firebase production. Kiểm tra OPPO + máy/emulator Android thứ hai:
tạo/join → ready → so scramble → countdown → lần lượt giải xong/finish → so hai thời gian,
winner và ví → rematch → ngắt mạng 10 giây (grace), 40 giây (DNF) → rời trước GO.
Không có hai Android client đã cấu hình online trong phiên này nên chưa xác nhận realtime
trên hai thiết bị thật. Xem kết quả kiểm tra thực tế ở báo cáo cuối phiên.

Kết quả kiểm tra ngày 03/10/2026:
- `flutter pub get`: thành công.
- `flutter analyze`: không có issue (`artifacts/rubik-challenge-analyze.txt`).
- `flutter test`: 145 tests pass (`artifacts/rubik-challenge-tests.txt`).
- Node backend/cube/interactive: 23 tests pass (`artifacts/rubik-challenge-js-tests.txt`).
- Firebase Auth + RTDB + Functions emulator: hai tài khoản pass toàn bộ flow và
  security assertions (`artifacts/rubik-challenge-emulator.txt`). Scheduler không chạy
  trong emulator này; timeout/grace được kiểm tra ở unit tests, tick chạy ở online adapter.
- `flutter build apk --debug`: thành công, APK tại `build/app/outputs/flutter-apk/app-debug.apk`.
  Gradle có cảnh báo Firebase plugins hiện dùng Kotlin Gradle Plugin; không gây lỗi build.
