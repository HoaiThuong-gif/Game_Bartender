# TASK.md — Bartender

> Nhật ký vận hành. Cập nhật khi làm việc. Xem AGENTS.md để hiểu cách dùng file này.

## Đang làm / In progress

- **Giai đoạn 5, Bước 2: Interface & hằng số** — Thêm `endMatch` + `localPlayerId` vào `RoomRepository`. Cập nhật Fake/Firebase/Controller/Test. Tách `_asMap` → `rtdb_utils.dart`. Giới hạn createRoom 20 lần thử.

## Đã xong / Done

- **Giai đoạn 5, Bước 1: Durability cho RTDB reads/writes** ✅ — Thêm `_asMap` helper (→ `rtdb_utils.dart`), `createRoom` dùng transaction tránh ghi đè, `joinRoom` chặn phòng full/đã bắt đầu + tìm ringIndex an toàn, `watchRoom` cleanup đầy đủ, `maxPlayers = 4`. _(2026-10-05)_
- **Giai đoạn 4: Firebase project setup** ✅ — Project `mobile-app-project-52a1d`, RTDB `mobile-app-project-52a1d-default-rtdb`. `firebase_options.dart` + `google-services.json` tạo bởi FlutterFire CLI. Security Rules deploy OK (read/write trên `rooms/`). `BartenderScreen` wire `DefaultFirebaseOptions`. `.gitignore` cập nhật (không commit API key). `flutter analyze` sạch, 59 tests pass. _(2026-10-02)_
- **Giai đoạn 3: Single-device playable loop** ✅ — FakeRoomRepository (in-memory, bot simulation, round loop), BartenderController (ChangeNotifier), 6 widgets (TimerBar, RingNeighbors, OrderTray, Station, ItemCard, TrashBin), 3 screens (Lobby, Match, Results) nối qua BartenderScreen. 59 unit tests (42 model + 17 controller) pass. `flutter analyze` sạch. _(2026-10-02)_
- **Giai đoạn 2: Models** ✅ — 10 model files trong `models/` + 42 unit tests đều pass. Ring math, round completion, station assignment, recipe pool, timer, order, player, room, match result, game item. Logic tổng quát cho N người. `flutter analyze` sạch. _(2026-10-01)_
- **Giai đoạn 1: Khung tính năng** ✅ — Tạo thư mục `models/`, `services/`, `controllers/`, `widgets/`, `screens/` và `BartenderScreen` placeholder. `flutter analyze` sạch. Chưa đụng file dùng chung. _(2026-10-01)_

## Chưa làm / Backlog

1. ~~Giai đoạn 1: Khung tính năng~~ _(đã hoàn thành)_
2. ~~Giai đoạn 2: Models~~ _(đã hoàn thành)_
3. ~~Giai đoạn 3: Single-device playable loop với `FakeRoomRepository`~~ _(đã hoàn thành)_
4. ~~Giai đoạn 4: Firebase project setup~~ _(đã hoàn thành)_
5. **Giai đoạn 5: `FirebaseRoomRepository`** — Đang làm. Bước 1 ✅, Bước 2 đang làm, Bước 3–8 chưa.
6. **Giai đoạn 6: Cảm biến và rung** — Thêm `sensors_plus` cho trạm bình lắc + haptic feedback. Chỉ test trên thiết bị thật.
7. **Giai đoạn 7: Nối vào lobby** — Sửa đúng 1 dòng `onBartenderTap` trong `lobby_screen.dart`. Commit riêng.
8. **Giai đoạn 8: Hoàn thiện và màn hình kết quả** — Kết quả cuối trận, bảng xếp hạng, chỉnh giao diện.

## Vướng mắc / Blocked

_(chưa có)_

## Rủi ro đã biết

- **Race condition join/start**: Phòng có thể vừa bắt đầu (`status` chuyển từ `lobby` → `playing`) giữa lúc `joinRoom` kiểm tra status và lúc transaction trên `players` chạy xong. Hiện tại chấp nhận rủi ro này (xác suất rất thấp với 4 người). Giải pháp triệt để cần Security Rules hoặc Cloud Function validate trên server.

## Ghi chú kỹ thuật

- Logic ring/round/station viết tổng quát cho N người bất kỳ (không hard-code 4), nhưng chỉ demo/test cho 2-4 người theo PROJECT_SPEC.md.
- Quy ước đặt tên thư mục theo Rubik: `models/`, `services/`, `controllers/`, `widgets/`, `screens/`.
- `BartenderScreen` là điểm vào duy nhất lộ ra ngoài `lib/games/bartender/`.
