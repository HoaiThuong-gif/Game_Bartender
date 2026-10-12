# TASK.md — Bartender

> Nhật ký vận hành. Cập nhật khi làm việc. Xem AGENTS.md để hiểu cách dùng file này.

## Đang làm / In progress

- **Giai đoạn 5, Bước 2: Interface & hằng số** — Thêm `endMatch` + `localPlayerId` vào `RoomRepository`. Cập nhật Fake/Firebase/Controller/Test. Tách `_asMap` → `rtdb_utils.dart`. Giới hạn createRoom 20 lần thử.

## Đã xong / Done

- **Giai đoạn 5, Bước 1: Durability cho RTDB reads/writes** ✅ — Thêm `_asMap` helper (→ `rtdb_utils.dart`), `createRoom` dùng transaction tránh ghi đè, `joinRoom` chặn phòng full/đã bắt đầu + tìm ringIndex an toàn, `watchRoom` cleanup đầy đủ, `maxPlayers = 4`. _(2026-10-05)_
- **Giai đoạn 4: Firebase project setup** ✅ — Project `mobile-app-project-52a1d`, RTDB `mobile-app-project-52a1d-default-rtdb`. `firebase_options.dart` + `google-services.json` tạo bởi FlutterFire CLI. Security Rules deploy OK (read/write trên `rooms/`). `BartenderScreen` wire `DefaultFirebaseOptions`. `.gitignore` cập nhật (không commit API key). `flutter analyze` sạch, 59 tests pass. _(2026-10-02)_
- **Giai đoạn 3: Single-device playable loop** ✅ — FakeRoomRepository (in-memory, bot simulation, round loop), BartenderController (ChangeNotifier), 6 widgets (TimerBar, RingNeighbors, OrderTray, Station, ItemCard, TrashBin), 3 screens (Lobby, Match, Results) nối qua BartenderScreen. 59 unit tests (42 model + 17 controller) pass. `flutter analyze` sạch. _(2026-10-02)_
- **Tích hợp sau merge (2026-10-02):** callback mặc định của quầy trong lobby
  chính mở `BartenderScreen`, giữ callback được truyền vào và route game khác.
  Entry này quản lý controller và chuyển lobby → match → results theo trạng thái
  phòng. Không thêm package, không thay model/controller/repository hay luật chơi.
- Sửa 2 unused import, 14 `withOpacity` deprecated; giới hạn chiều rộng/xuống dòng
  cho phần chọn số người, đồng đội, trạm, timer và tiêu đề đơn hàng để tránh overflow
  trên điện thoại. `flutter analyze`: 0 error / 0 warning / 0 info.
- **49 test liên quan đạt:** 42 model Bartender, 2 test navigation ở 390×844 và
  360×640, 5 test lobby hiện có. Navigation kiểm tra bấm quầy → entry → tạo phòng
  với bot → mở trận → pop về lobby và dispose tài nguyên. Build Android debug,
  cài và chạy trên CPH1969 thành công; đã xác nhận entry, trận và kết quả 60s
  trên thiết bị thật.

- **Giai đoạn 2: Models** ✅ — 10 model files trong `models/` + 42 unit tests đều pass. Ring math, round completion, station assignment, recipe pool, timer, order, player, room, match result, game item. Logic tổng quát cho N người. `flutter analyze` sạch. _(2026-10-01)_
- **Giai đoạn 1: Khung tính năng** ✅ — Tạo thư mục `models/`, `services/`, `controllers/`, `widgets/`, `screens/` và `BartenderScreen` placeholder. `flutter analyze` sạch. Chưa đụng file dùng chung. _(2026-10-01)_

## Chưa làm / Backlog

1. ~~Giai đoạn 1: Khung tính năng~~ _(đã hoàn thành)_
2. ~~Giai đoạn 2: Models~~ _(đã hoàn thành)_
3. ~~Giai đoạn 3: Single-device playable loop với `FakeRoomRepository`~~ _(đã hoàn thành)_
4. ~~Giai đoạn 4: Firebase project setup~~ _(đã hoàn thành)_
5. **Giai đoạn 5: `FirebaseRoomRepository`** — Đang làm. Bước 1 ✅, Bước 2 đang làm, Bước 3–8 chưa.
6. **Giai đoạn 6: Cảm biến và rung** — Thêm `sensors_plus` cho trạm bình lắc + haptic feedback. Chỉ test trên thiết bị thật.
7. ~~Giai đoạn 7: Nối vào lobby~~ _(đã nối sau merge 2026-10-02; thay đổi callback tách biệt trong diff lobby)_
8. **Giai đoạn 8: Hoàn thiện và màn hình kết quả** — Kết quả cuối trận, bảng xếp hạng, chỉnh giao diện.

## Vướng mắc / Blocked

_(chưa có)_

## Rủi ro đã biết

- **Race condition join/start**: Phòng có thể vừa bắt đầu (`status` chuyển từ `lobby` → `playing`) giữa lúc `joinRoom` kiểm tra status và lúc transaction trên `players` chạy xong. Hiện tại chấp nhận rủi ro này (xác suất rất thấp với 4 người). Giải pháp triệt để cần Security Rules hoặc Cloud Function validate trên server.

## Ghi chú kỹ thuật

- Logic ring/round/station viết tổng quát cho N người bất kỳ (không hard-code 4), nhưng chỉ demo/test cho 2-4 người theo PROJECT_SPEC.md.
- Quy ước đặt tên thư mục theo Rubik: `models/`, `services/`, `controllers/`, `widgets/`, `screens/`.
- `BartenderScreen` là điểm vào duy nhất lộ ra ngoài `lib/games/bartender/`.
- Các docs lobby/Rubik ở `docs/` gốc mà AGENTS.md dẫn đến không còn trong checkout
  sau merge; không tạo lại hoặc sửa tài liệu ngoài module trong task này.
- **Phần chưa hoàn thiện, chỉ ghi nhận:** chưa có `FirebaseRoomRepository`, UI
  nhập mã phòng hay cảm biến lắc; controller mặc định tạo `FakeRoomRepository`
  và chưa sử dụng flag `useFakeRepository`. Không cần thêm Firebase/sensors
  để chạy flow offline hiện có.
- Bot hiện chỉ chế biến/chuyền vật phẩm, chưa tự nộp đơn, nên round không tự
  hoàn thành khi có bot. Xử lý công thức nhiều nguyên liệu còn đơn giản hóa;
  `strawberry_lemonade` chưa có nhánh tạo sản phẩm. Không đổi gameplay trong
  task integration này; để thành viên phụ trách hoàn thiện riêng.
