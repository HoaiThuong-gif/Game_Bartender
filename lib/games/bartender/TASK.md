# TASK.md — Bartender

> Nhật ký vận hành. Cập nhật khi làm việc. Xem AGENTS.md để hiểu cách dùng file này.

## Đang làm / In progress

- _(Đã hoàn thành 3 bản vá A, B, C)_

## Cần kiểm tra thủ công khi thử 2 điện thoại

1. Hết round 1 thì số round lên 2, không lên 3.
2. Tắt mạng một máy giữa trận, sang round sau những người còn lại vẫn nhận đủ đồ của mình.

## Đã xong / Done

- **Việc 5 (Phần 1) — Thêm dependency sensors_plus (2026-10-15):** Đã thêm `sensors_plus: ^6.1.1` vào pubspec.yaml và cập nhật pubspec.lock.
- **Việc 4 — Test cho RoundSetup.generate (2026-10-15):** Thêm test suite cho `RoundSetup.generate` trong `test/bartender_round_setup_test.dart` chạy 200 seed cố định cho 2, 3, 4 người và round 1..4, kiểm tra đủ 4 điều kiện (a, b, c, d); expose `anchor` trên `RoundSetup` (commit `6947f76`).
- **Việc 4a — Dọn comment lỗi thời về processItem (D19) (2026-10-15):** Sửa comment trong `recipe.dart` và `recipe_pool.dart` thành "dùng processItem() trong models/processing_rules.dart (D19)" (commit `3be90e6`).
- **Việc 3 — Một bảng luật chế biến duy nhất (D19) (2026-10-15):** Tạo `models/processing_rules.dart` chứa hàm thuần `processItem`, chuyển Fake/Firebase/StationWidget sang dùng chung, hoàn thiện hiển thị `item_card_widget.dart` cho toàn bộ itemId, thêm unit test `test/bartender_processing_test.dart`.
- **Việc 2 — Sửa 2 test hỏng và trả lại thớt (D16/D19) (2026-10-15):** Cập nhật test `totalSurvivalSeconds` theo logic mới, trả `strawberry_smoothie` về 2 bước (thớt + xay), cập nhật doc comment `recipe_pool.dart` (commit `f6b7d8d`).
- **Bản vá C — Đồ trong inbox đi theo người khi dồn ringIndex (D14) (2026-10-15):** Đọc inbox cũ và chuyển toàn bộ items của các người chơi còn sống sang `ringIndex` mới, sinh 1 nguyên liệu mới cho mỗi ring còn lại, ghi đè toàn bộ node `inbox` để dọn sạch người bị loại.
- **Bản vá B — Đơn khả thi theo trạm đã ghi lên Firebase (D15) (2026-10-15):** Thêm hàm thuần `RoundSetup.feasibleFor`, thay thế lần gọi `RoundSetup.generate` thứ hai trong `_tryAdvanceRound` bằng `feasibleFor` từ phân trạm thực tế vừa commit lên Firebase, thêm unit test cho `feasibleFor` (commit `62be7ac`).
- **Bản vá A — Chống chuyển round hai lần (2026-10-15):** Trong transaction `_tryAdvanceRound`, kiểm tra `progress` của mọi người chơi đang connected đã nộp đủ đơn (`done >= needed`) trước khi tạo round mới (commit `472b7b3`).
- **Bước 0 — Dọn TASK.md (2026-10-15):** Sửa mục "Đang làm" (Bước 2 đã xong, commit 73433ed). Xoá ghi chú lỗi thời về FirebaseRoomRepository và flag useFakeRepository.
- **Sửa tràn bố cục màn hình trận Bartender trên 360x640 (2026-10-12):** nguyên nhân do Column phần dưới bị thiếu chiều cao; cách sửa: dùng LayoutBuilder cho phần giữa cuộn được khi màn hình thấp (<720).
- **Giai đoạn 5, Bước 2: Interface & hằng số** ✅ — commit 73433ed _(2026-10-05)_
- **Giai đoạn 5, Bước 1: Durability cho RTDB reads/writes** ✅ _(2026-10-05)_
- **Giai đoạn 4: Firebase project setup** ✅ — Project `nhom-bar`, RTDB `nhom-bar-default-rtdb`. `flutter analyze` sạch, 59 tests pass. _(2026-10-02)_
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
- `BartenderConfig.useFakeRepository = true` trong mọi commit (quy tắc chung).
- `RoundSetup.generate()` là hàm thuần (models/) dùng chung cho Fake và Firebase (D15).
- `_roomsRoot = 'bartender/rooms'` — tất cả đường dẫn Firebase đều bắt đầu từ đây (D18).
- `sensors_plus` thêm như dependency riêng; shake detection tách thành class thuần `ShakeDetector` để test được.

## Đề xuất sửa docs

- **API.md**: Root structure hiển thị `rooms/` nhưng theo D18 đường dẫn thực tế là `bartender/rooms/`.
- **ARCHITECTURE.md**: Ghi chú "No other feature in this repo uses Firebase yet" đã lỗi thời.
- **DECISIONS.md**: Cần thêm **D19** (bảng luật chế biến duy nhất `processItem` và danh sách công thức cuối cùng).
