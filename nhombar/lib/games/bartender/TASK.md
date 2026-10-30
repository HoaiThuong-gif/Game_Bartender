# TASK.md — Bartender

> Nhật ký vận hành. Cập nhật khi làm việc. Xem AGENTS.md để hiểu cách dùng file này.

## Đang làm / In progress

- 2026-10-30: Phần chuyển API đã hoàn tất kiểm thử tự động; cần demo trên 2 điện thoại thật qua adb reverse theo README gốc.

- Chờ tôi kiểm tra thủ công trên 2–4 thiết bị thật (xem mục 'Cần kiểm tra thủ công'). Chưa có việc code nào đang làm.

## Cần kiểm tra thủ công (2–4 thiết bị thật)

1. **2 máy tạo/vào phòng bằng mã**: Kiểm tra tạo phòng, vào phòng bằng mã 4 chữ số, cập nhật danh sách người chơi trong lobby.
2. **Hết round 1 thì lên round 2 (không nhảy cóc)**: Kiểm tra hoàn thành đơn ở round 1 chuyển sang round 2 tuần tự, không bị nhảy cóc round.
3. **Nộp đơn xong món biến khỏi inbox và không nộp lại được**: Xác nhận item đã nộp biến mất khỏi khay đồ (inbox) ngay lập tức và không thể tái nộp.
4. **Tắt mạng một máy giữa trận thì các máy còn lại tiếp tục và đồ không lạc**: Ngắt kết nối 1 máy, máy còn lại tiếp tục chơi; sang round sau đồ của người bị ngắt/loại không làm tắc nghẽn hoặc thất lạc (D14).
5. **Lắc điện thoại ở trạm bình lắc (shaker)**: Cảm biến gia tốc nhận diện lắc thật trên thiết bị thực tế; nút "Lắc giả lập" chỉ hiện khi không có cảm biến.
6. **Thử phòng 2 người, 3–4 người**: Kiểm tra luồng chơi và phân bổ trạm công thức mỏ neo/khả thi ở quy mô 2 người, 3 người, 4 người.
7. **Người cuối rời phòng thì trận kết thúc đúng**: Khi chỉ còn dưới 2 người chơi connected hoặc người cuối rời phòng, trận kết thúc đúng quy trình và chuyển sang kết quả.
8. **Xem màn hình kết quả**: Hiển thị bảng xếp hạng, số đơn mỗi người, tổng đơn toàn đội, thời gian sống sót, thông báo kết thúc sớm nếu có; nút quay về lobby hoạt động mượt mà.

*(Lưu ý: Chưa sẵn sàng production, cần hoàn tất kiểm tra thủ công trên thiết bị vật lý và nghiệm thu Firebase RTDB).*

## Đã xong / Done

- 2026-10-30 (D21): Chuyển toàn bộ frontend vào `nhombar/` ngang hàng `backend/` trong cùng repo. Chuyển server/công cụ quét và Firebase backend cũ vào `backend/`; sửa đường dẫn integration test, dò Android SDK, VS Code và hướng dẫn. Sau chuyển: analyze sạch, 170 test Flutter, 5 test REST API và 11 test scanner đều qua. Build APK debug từ `nhombar/` thành công; chưa cài lại trên thiết bị thật sau chuyển folder.

- 2026-10-30: Thêm ApiRoomRepository, chọn HTTP mặc định, bỏ khởi động Firebase ở entry, thêm form tham gia phòng và nhãn đồng đội online. Backend Node.js giữ luật chơi/timer/round/inbox/results, phiên Bearer và Swagger; lưu file JSON trên server.
- Xác minh 2026-10-30: Dart analyze toàn dự án không có lỗi/cảnh báo; 170 kiểm thử Flutter qua (gồm 2 kiểm thử repository gọi backend HTTP thật); 5 kiểm thử backend qua. Chưa kiểm thử thiết bị thật sau khi đổi API. Hướng dẫn hiện hành: README gốc và backend/README.md.

- **Giai đoạn 5 — FirebaseRoomRepository (phần code) (2026-10-15):** dùng chung dự án Firebase `nhom-bar` với đường dẫn `bartender/rooms` (D18); phân trạm và công thức khả thi (D15/D16); bỏ phụ thuộc totalPlayers, dồn ringIndex (D13/D14); submitOrder bằng một multi-path update có transaction chống nộp trùng, tìm đúng món trong inbox; chuyển round không cần host bằng transaction có kiểm tra progress (D17); endMatch ghi results trước status; giờ server; một bảng luật chế biến (D19). analyze và test sạch (chưa chạy với Firebase thật).
- **Việc 6 — Màn hình kết quả và xử lý biên (Giai đoạn 8/9) (2026-10-15):**
  - Hoàn thiện `BartenderResultsScreen`: hiển thị xếp hạng người chơi, số đơn mỗi người, tổng đơn đội, thời gian sống sót theo `MatchResult` (API.md).
  - Xử lý trạng thái `results == null` (spinner "Đang tải kết quả..." + nút về lobby).
  - Hiển thị thông báo khi trận kết thúc sớm vì còn dưới 2 người connected.
  - Xử lý người chơi bị loại khỏi phòng (D14): `BartenderController` hiển thị thông báo `'Bạn đã bị loại khỏi phòng do mất kết nối.'` và đưa người chơi về lobby an toàn.
  - Thiết kế thích ứng chống tràn bố cục (không overflow) ở cả 360×640 và 390×844.
  - Viết bộ widget test toàn diện `test/bartender_results_test.dart` (6 test, pass 100%).
  - Kết quả kiểm tra: `flutter analyze` 0 lỗi 0 cảnh báo; `flutter test` toàn bộ 199 test pass (commit `181f380`).
- **Việc 5 — Cảm biến lắc và rung (Giai đoạn 6) (2026-10-15):** Tạo lớp thuần `ShakeDetector` nhận diện lắc với ngưỡng (threshold) và cooldown chống nhận nhầm; tạo `BartenderHaptics` bọc phản hồi rung cho 3 sự kiện (nộp đơn, thùng rác, hết giờ); tích hợp cảm biến lắc + nút fallback "Lắc giả lập" vào `StationWidget`, thêm test `test/bartender_shake_test.dart` (commit `46996e9`).
- **Việc 5 (Phần 1) — Thêm dependency sensors_plus (2026-10-15):** Đã thêm `sensors_plus: ^6.1.1` vào pubspec.yaml và cập nhật pubspec.lock (commit `e29496e`).
- **Việc 4 — Test cho RoundSetup.generate (2026-10-15):** Thêm test suite cho `RoundSetup.generate` trong `test/bartender_round_setup_test.dart` chạy 200 seed cố định cho 2, 3, 4 người và round 1..4, kiểm tra đủ 4 điều kiện (a, b, c, d); expose `anchor` trên `RoundSetup` (commit `6947f76`).
- **Việc 4a — Dọn comment lỗi thời về processItem (D19) (2026-10-15):** Sửa comment trong `recipe.dart` và `recipe_pool.dart` thành "dùng processItem() trong models/processing_rules.dart (D19)" (commit `3be90e6`).
- **Việc 3 — Một bảng luật chế biến duy nhất (D19) (2026-10-15):** Tạo `models/processing_rules.dart` chứa hàm thuần `processItem`, chuyển Fake/Firebase/StationWidget sang dùng chung, hoàn thiện hiển thị `item_card_widget.dart` cho toàn bộ itemId, thêm unit test `test/bartender_processing_test.dart` (commit `09c07b3`).
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
5. ~~Giai đoạn 5: FirebaseRoomRepository~~ _(code đã hoàn thành: Bước F, 3–7, bản vá A/B/C, submitOrder, startMatch; CHƯA kiểm tra trên thiết bị thật nhiều máy)_
6. ~~Giai đoạn 6: Cảm biến và rung~~ _(đã hoàn thành ShakeDetector, BartenderHaptics, fallback "Lắc giả lập" cho trạm shaker)_
7. ~~Giai đoạn 7: Nối vào lobby~~ _(đã nối sau merge 2026-10-02; thay đổi callback tách biệt trong diff lobby)_
8. ~~Giai đoạn 8: Hoàn thiện và màn hình kết quả~~ _(đã hoàn thành kết quả cuối trận, bảng xếp hạng, fallback kết thúc sớm, chống tràn 360x640 & 390x844)_

## Vướng mắc / Blocked

_(chưa có)_

## Rủi ro đã biết

- **Race condition join/start**: Phòng có thể vừa bắt đầu (`status` chuyển từ `lobby` → `playing`) giữa lúc `joinRoom` kiểm tra status và lúc transaction trên `players` chạy xong. Hiện tại chấp nhận rủi ro này (xác suất rất thấp với 4 người). Giải pháp triệt để cần Security Rules hoặc Cloud Function validate trên server.
- Client thắng transaction chuyển round có thể crash trước khi ghi xong players/orders/inbox → round mới có thể treo.
- Đồ vuốt sang người đang mất kết nối bị kẹt cho tới hết round (người đó bị loại ở ranh giới round).
- `processItemAtStation` đọc rồi ghi, không atomic.
- `survivalSeconds` bị cắt ở 600 giây.
- Bảo mật mức lớp học: mọi người đã đăng nhập đều ghi được vào mọi phòng (D18).

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
