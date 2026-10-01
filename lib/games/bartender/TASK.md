# TASK.md — Bartender

> Nhật ký vận hành. Cập nhật khi làm việc. Xem AGENTS.md để hiểu cách dùng file này.

## Đang làm / In progress

_(chưa có)_

## Đã xong / Done

- **Giai đoạn 2: Models** ✅ — 10 model files trong `models/` + 42 unit tests đều pass. Ring math, round completion, station assignment, recipe pool, timer, order, player, room, match result, game item. Logic tổng quát cho N người. `flutter analyze` sạch. _(2026-10-01)_
- **Giai đoạn 1: Khung tính năng** ✅ — Tạo thư mục `models/`, `services/`, `controllers/`, `widgets/`, `screens/` và `BartenderScreen` placeholder. `flutter analyze` sạch. Chưa đụng file dùng chung. _(2026-10-01)_

## Chưa làm / Backlog

1. ~~Giai đoạn 1: Khung tính năng~~ _(đã chuyển lên Đang làm)_
2. **Giai đoạn 2: Models** — Cài đặt models và luật trong `models/` (ring math, round completion, station assignment, recipe/difficulty pool) bằng Dart thuần + unit tests. Logic viết tổng quát cho N người, demo/test chỉ 2-4.
3. **Giai đoạn 3: Single-device playable loop với `FakeRoomRepository`** — Nối `widgets/`/`screens/` với repository giả trong bộ nhớ. Toàn bộ vòng lặp round chạy được trên một máy.
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
