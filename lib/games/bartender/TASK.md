# TASK.md — Bartender

> Nhật ký vận hành. Cập nhật khi làm việc. Xem AGENTS.md để hiểu cách dùng file này.

## Đang làm / In progress

- **Giai đoạn 3: Single-device playable loop với `FakeRoomRepository`** ⏳
  - Tạo `bartender_config.dart`
  - Cập nhật `Room` và `Round` model (inbox, results, copyWith)
  - Cài đặt `RoomRepository` (interface) và `FakeRoomRepository` (in-memory, simulated bots, round loop, station processing, item passing)
  - Cài đặt `BartenderController` (state management, timer tick, swipe, submit)
  - Cài đặt các widget: `station_widget`, `order_tray_widget`, `item_card_widget`, `trash_bin_widget`, `timer_bar_widget`, `ring_neighbors_widget`
  - Cài đặt các screen: `bartender_lobby_screen`, `bartender_match_screen`, `bartender_results_screen`
  - Nối vào `BartenderScreen`
  - Viết unit & widget tests cho playable loop, kiểm tra `flutter test` và `flutter analyze`

## Đã xong / Done

- **Giai đoạn 2: Models** ✅ — 10 model files trong `models/` + 42 unit tests đều pass. Ring math, round completion, station assignment, recipe pool, timer, order, player, room, match result, game item. Logic tổng quát cho N người. `flutter analyze` sạch. _(2026-10-01)_
- **Giai đoạn 1: Khung tính năng** ✅ — Tạo thư mục `models/`, `services/`, `controllers/`, `widgets/`, `screens/` và `BartenderScreen` placeholder. `flutter analyze` sạch. Chưa đụng file dùng chung. _(2026-10-01)_

## Chưa làm / Backlog

1. ~~Giai đoạn 1: Khung tính năng~~ _(đã hoàn thành)_
2. ~~Giai đoạn 2: Models~~ _(đã hoàn thành)_
3. ~~Giai đoạn 3: Single-device playable loop với `FakeRoomRepository`~~ _(đang làm)_
4. **Giai đoạn 4: Firebase project setup** — Tạo project Firebase, chạy FlutterFire CLI, thêm config Android. Báo nhóm trước.
5. **Giai đoạn 5: `FirebaseRoomRepository`** — Cài đặt repository thật theo schema trong API.md. Test 2 rồi 3-4 thiết bị thật.
6. **Giai đoạn 6: Cảm biến và rung** — Thêm `sensors_plus` cho trạm bình lắc + haptic feedback. Chỉ test trên thiết bị thật.
7. **Giai đoạn 7: Nối vào lobby** — Sửa đúng 1 dòng `onBartenderTap` trong `lobby_screen.dart`. Commit riêng.
8. **Giai đoạn 8: Hoàn thiện và màn hình kết quả** — Kết quả cuối trận, bảng xếp hạng, chỉnh giao diện.

## Vướng mắc / Blocked

_(chưa có)_

## Ghi chú kỹ thuật

- Logic ring/round/station viết tổng quát cho N người bất kỳ (không hard-code 4), nhưng chỉ demo/test cho 2-4 người theo PROJECT_SPEC.md.
- Quy ước đặt tên thư mục theo Rubik: `models/`, `services/`, `controllers/`, `widgets/`, `screens/`.
- `BartenderScreen` là điểm vào duy nhất lộ ra ngoài `lib/games/bartender/`.
