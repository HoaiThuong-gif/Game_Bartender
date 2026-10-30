# TASK.md — Bartender

> Nhật ký vận hành. Cập nhật khi làm việc. Xem AGENTS.md để hiểu cách dùng file này.

## Nhánh phát triển giao diện

- Theo yêu cầu người dùng ngày 2026-10-30, từ sau merge `90a5774`, các thay đổi giao diện tiếp theo được thực hiện trên `dev/Zhoufen`.
- `dev/Abu.ui` giữ snapshot UI trước merge; không tiếp tục phát triển giao diện trên nhánh này trừ khi người dùng đổi yêu cầu.

## Đang làm / In progress

- Hoàn tất lượt UI đống vật phẩm/máy ép hai trạng thái trên `dev/Zhoufen`; chờ người dùng thử cảm giác kéo và độ khó trên máy thật. Chưa commit/push lượt UI này.

## Đã xong — đồng hồ chờ cảnh / giảm khựng, 2026-10-31

- Người dùng duyệt bổ sung backend: chờ tất cả máy tải xong, đếm chung 3–2–1,
  rồi mới chạy 60 giây. Thực hiện trên `dev/Zhoufen`, chưa commit/push.
- Nối readiness từ frame 3D đã render (hoặc frame fallback) tới controller,
  Fake/API/Firebase và server. Chặn thao tác, bot, spawn trong chuẩn bị/countdown;
  readiness gắn đúng lượt trận, báo trùng không reset thời gian. Có thử lại khi báo lỗi.
- Giữ đồng hồ nguyên 60 trong loading/countdown; hiển thị giây bằng làm tròn lên.
  Firebase xuất bản snapshot khởi động nguyên tử, tránh lộ timer trận cũ.
- Renderer không reset canvas mỗi snapshot/thả đồ, không xếp lại pile khi chỉ
  busy/order đổi, không cập nhật nhãn DOM ẩn mỗi frame. Cache biến bóng, shader,
  geometry và chỉ render/cập nhật bóng khi cần. Controller chỉ phát tick khi giây đổi.
- Qua 123 test hồi quy ở `test/bartender*` (trừ navigation cũ đã ghi bên dưới),
  11 test trong module, 14 test server và WebGL offline. Test mới gồm loading
  lâu không hao thời gian, 3–2–1, khóa thao tác, báo stale/trùng, peer rời phòng
  và hai WebSocket nhận cùng mốc đồng hồ. Analyze mã thay đổi không error/warning;
  còn lint info về braces/const trong module và script kiểm tra bỏ qua Git.
- Đã thử hot restart trên Android emulator: tải cảnh giữ 01:00, ghi lại 3 → 2 → 1,
  cảnh 3D mở khóa vẫn 01:00 (ảnh `scene3d/test-output/android-ready-6..9.png`),
  hết giờ ghi 60s. Chưa đo FPS profile/release trên máy thật, chưa thử nhiều máy
  Firebase. API cần restart/deploy server cập nhật; APK cũ chưa chứa thay đổi này.

## Cần kiểm tra thủ công (2–4 thiết bị thật với Backend Server Local / VPS)

### Thiết lập môi trường thử nghiệm với Local Server:
- **Khởi động server**: Trên máy tính, chạy lệnh `dart run server/bin/server.dart` (mặc định lắng nghe trên cổng 8080).
- **Cách 1 (Cùng mạng Wi-Fi)**: Kết nối điện thoại và máy tính vào cùng một mạng Wi-Fi. Xác định IP nội bộ của máy tính (ví dụ `192.168.1.15`). Chạy/build app với:
  `flutter run --dart-define=BARTENDER_BACKEND=api --dart-define=API_BASE_URL=http://192.168.1.15:8080`
- **Cách 2 (Cáp USB + adb reverse)**: Cắm điện thoại qua USB và bật gỡ lỗi USB, chạy lệnh:
  `adb reverse tcp:8080 tcp:8080`
  Chạy/build app với:
  `flutter run --dart-define=BARTENDER_BACKEND=api --dart-define=API_BASE_URL=http://127.0.0.1:8080`

### Danh sách các bước kiểm tra thủ công:
1. **2 máy tạo/vào phòng bằng mã**: Host tạo phòng nhận mã 4 chữ số, máy thứ hai nhập mã vào phòng thành công. Cả 2 máy cập nhật danh sách người chơi ngay lập tức qua WebSocket snapshot.
2. **Chỉ chủ phòng mới bắt đầu được**: Khách thấy thông báo chờ chủ phòng, nút Bắt đầu chỉ bấm được trên máy chủ phòng khi đủ >= 2 người.
3. **Cấp nguyên liệu & chuyền đồ**: Nhận nguyên liệu ban đầu, vuốt sang người bên cạnh và quan sát đồ bay sang khay của máy kia theo thời gian thực.
4. **Chế biến tại trạm**: Đúng trạm (dao/thớt, máy ép, máy xay, bình lắc) chế biến ra sản phẩm mới; lắc điện thoại thật ở trạm bình lắc.
5. **Nộp đơn và tăng điểm / cộng giờ**: Hoàn thành đơn hàng, kiểm tra thanh thời gian được cộng +5s và tiến độ đơn tăng.
6. **Hết round 1 chuyển sang round 2**: Khi tất cả người chơi hoàn thành đơn, round tự động tăng tuần tự, đổi trạm và làm mới danh sách đơn.
7. **Một máy ngắt kết nối**: Tắt app trên 1 máy, máy còn lại nhận cờ `connected=false`; nếu còn dưới 2 người thì trận đấu kết thúc ngay lập tức và hiển thị bảng xếp hạng kết quả.
8. **Quay lại phòng sau khi thua**: Bấm "QUAY LẠI PHÒNG", người chơi trở về lobby phòng cũ, sẵn sàng cho trận kế tiếp.


## Đề xuất sửa docs

1. **`DECISIONS.md` - D17 & D18 superseded**:
   - D17 (loại bỏ vai trò host, chống race condition bằng RTDB transaction) và D18 (dùng chung Firebase RTDB dự án `nhom-bar` tại `bartender/rooms`) được thay thế hoàn toàn bằng backend server tự host độc lập (Dart Shelf + WebSocket). Game loop và quản lý trạng thái phòng chạy in-memory đồng bộ trên server, loại bỏ nhu cầu client-side RTDB transactions.
2. **`API.md` & `ARCHITECTURE.md` - Deployment Target**:
   - Loại bỏ hoàn toàn Render khỏi tài liệu theo chỉ đạo của giảng viên; server sẽ chạy local trong giai đoạn dev và deploy lên máy chủ VPS tự thuê sau này.
   - Đề xuất cập nhật Base URL trong `API.md` từ `https://<service>.onrender.com` sang `http://localhost:8080` (hoặc domain VPS).
3. **`API.md` - Room snapshot (`players` & `results.ranking`)**:
   - Đề xuất bổ sung trường `readyInLobby: bool` (mặc định `true`) vào schema `players` cho luồng quay lại phòng sau khi kết thúc trận.
   - Đề xuất bổ sung trường `ringIndex: int` vào `ranking` trong `results`.
4. **Báo cáo mã nguồn Firebase không còn sử dụng nhưng được giữ nguyên**:
   - File `lib/games/bartender/services/firebase_room_repository.dart` và cấu hình Firebase trong `pubspec.yaml` hiện không còn là backend mặc định. Toàn bộ mã này được giữ nguyên an toàn, có thể chuyển đổi kích hoạt lại bất kỳ lúc nào qua `BartenderConfig.backend = BartenderBackend.firebase` mà không ảnh hưởng đến server API mới.

## Đã xong / Done

- **Làm mới quầy và kết quả (2026-10-30, sau merge, chưa commit):** bỏ phân trang, toàn bộ item rơi ngẫu nhiên/tiếp xúc/chồng lớp, dọn món đỡ thì đống hạ; bắt/thả giữa lúc rơi; mesh màu gộp theo loại và bóng instanced để giảm draw calls. Máy ép rỗng/nạp/cần nhấn + mức nước tăng; vẫn bốn nhấn mới chế biến. HUD/phiếu đơn và màn kết quả xanh–kem/vàng có cúp Canvas. 16 test Flutter, 3 ảnh bố cục, WebGL với 80 item qua; analyze UI sạch. Android máy ảo xác nhận quầy mới, kéo cam vào máy ép và kết quả bằng Hot Restart/Hot Reload. Không thay backend/controller/model/luồng lobby. TEMP/TMP test dùng ổ D do ổ C thiếu chỗ; chưa build APK mới hoặc đo máy thật. Xem `scene3d/README.md`.


- **Merge UI vào logic Zhoufen (2026-10-30):** local `dev/Zhoufen`, logic nguồn `2b50690`, UI nguồn `aac84ce`. Ba conflict được người dùng duyệt riêng: readiness theo Room, host bấm SẴN SÀNG khi mọi người trở lại; 3D dùng submitOrder mới và banner reconnect; kết quả QUAY LẠI PHÒNG/THOÁT theo controller Zhoufen. Giữ nguyên controller/model/repository/server/config/lockfile. 131 test Flutter Bartender, 11 test server, WebGL và build APK debug qua. Chưa push, chưa kiểm chứng hai máy Android online.



- **Phóng lớn và làm sống động quầy (2026-10-30):** camera theo chiều rộng, mesh trái cây 1.25/trạm 1.35, 8 món/trang; bỏ hướng dẫn và hàng đồng đội, HUD lớn. Vật phẩm mới rơi/nảy/lăn 1.25 giây rồi dừng, bắt kéo được; không đồng bộ vị trí. Kết quả đổi sang gỗ/kem, hai cột khi ngang và chữ lớn. WebGL qua kiểm tra spawn/idle/tương tác/phân trang/dispose, 6 test kết quả và ảnh bố cục 800×360 qua. Cần kiểm tra lại bản này bằng Hot Restart trên Android và đo máy thật. Không merge hoặc thay controller/repository/schema.

- **Sửa tương tác 3D theo phản hồi (2026-10-30):** bỏ nhãn vật phẩm và nút chuyền/nộp; đơn phía trên; kéo lên nộp, xuống bỏ, hai bên chuyền. Máy ép/xay cần 4 nhấn sau khi đặt nguyên liệu; thớt cần 4 đường rạch, tap không tính. WebGL test qua các ngưỡng và thao tác; chưa kiểm chứng bản sửa trên Android thật/máy ảo. Không merge, không đổi controller/repository/schema.

- **Gameplay 3D đầu tiên (2026-10-30, chưa commit):** renderer Three.js offline, quầy góc chéo màu ấm, bốn model trạm, nguyên liệu/thành phẩm 3D, kéo/chuyền/chế biến/nộp đúng dữ liệu controller, cảm biến shaker, phân trang 12 món, nút hình nhẹ, pause/dispose và màn dự phòng. Tách file mới; giữ nguyên model/controller/repository/schema. 90 test Dart qua; file mới analyze sạch; WebGL Chrome kiểm tra chức năng qua; build bundle và APK debug qua. Máy ảo Android xác nhận kéo chanh → ép → nộp (+5s, 1/3) → kết quả bằng hot restart. Lỗi Java loopback được xử lý bằng thư mục tạm ngắn/heap 2 GB trong tiến trình, không sửa Gradle. Chưa đo hiệu năng máy thật. Đã fetch và đối chiếu `dev/Zhoufen` tại `5994178`, KHÔNG merge/checkout/rebase/stash/commit/push. Xem `scene3d/README.md` cho điểm nối và lưu ý xung đột.


- **Sửa lỗi nộp đơn hàng sau khi chế biến (2026-10-30):**
  - Khắc phục lỗi ITEM_NOT_FOUND khi nộp đơn: Server và Repository trước đây có sự không đồng nhất giữa it.id (instance id) và it.itemId (catalog id như 'orange_juice').
  - Server RoomService.submitOrder: cho phép tìm vật phẩm trong inbox theo cả it.id == itemId lẫn it.itemId == itemId, đồng thời kiểm tra công thức linh hoạt.
  - Client BartenderController.submitOrder: truyền đúng product.id.isNotEmpty ? product.id : product.itemId.
  - Đồng bộ FakeRoomRepository và FirebaseRoomRepository xử lý an toàn cả 2 định dạng id.
  - Bổ sung DragTarget<GameItem> vào OrderTrayWidget: hỗ trợ kéo thả trực tiếp ly nước vào đơn hàng bên cạnh nút bấm 'NỘP ĐƠN (+5s) ✨'.
  - Bổ sung unit test nộp đơn trên server (
oom_service_test.dart) và client (artender_api_room_repository_test.dart).

- **Bước C.7: Tăng cường tính bền bỉ cho WebSocket trong ApiRoomRepository (2026-10-30):**
  - Tự động kết nối lại (auto-reconnect) khi socket bị ngắt hoặc lỗi giữa trận với exponential backoff (1s, 2s, 4s, tối đa 5s), tổng thời gian tối đa ~30s, giữ nguyên playerToken.
  - Sau mỗi lần nối lại thành công, tự động gọi GET /rooms/{code} một lần, thay thế hoàn toàn local room state bằng snapshot mới (không merge), rồi tiếp tục nhận snapshot qua WebSocket.
  - Dừng thử lại ngay lập tức và phát lỗi rõ ràng nếu server trả về UNAUTHORIZED hoặc ROOM_NOT_FOUND.
  - Định nghĩa enum RoomConnectionState (connected / reconnecting / lost) trên RoomRepository và BartenderController.
  - Hiển thị banner nhỏ 'Đang nối lại...' trên BartenderMatchScreen mà không làm thay đổi bố cục giao diện.
  - Bộ test đầy đủ: 7 test trong test/bartender_api_room_repository_test.dart, test/bartender_reconnect_banner_test.dart; 227/227 Flutter tests và 10/10 server tests pass 100%.

- **Bước C.5: Triển khai Flutter `ApiRoomRepository` và tích hợp bộ chọn Backend (2026-10-30):**
  - Viết `ApiRoomRepository` (`lib/games/bartender/services/api_room_repository.dart`) cài đặt trọn vẹn interface `RoomRepository`:
    - Giao tiếp với HTTP server (`createRoom`, `joinRoom`, `leaveRoom`, `startMatch`, `sendItem`, `trashItem`, `processItemAtStation`, `submitOrder`).
    - Lắng nghe WebSocket thời gian thực, tự động giải mã snapshot phòng và cập nhật `Stream<Room> watchRoom(code)`.
    - Phản hồi `pong` khi nhận `ping` từ server.
    - Ánh xạ toàn bộ mã lỗi từ server sang tiếng Việt thân thiện qua `mapApiError`.
  - Bổ sung enum `BartenderBackend` (`fake`, `firebase`, `api`) và `BartenderConfig.apiBaseUrl` (mặc định `http://10.0.2.2:8080`, override được qua `--dart-define=API_BASE_URL`).
  - Mặc định `BartenderConfig.backend` giữ nguyên là `BartenderBackend.fake` đảm bảo 100% test offline không bị ảnh hưởng.
  - Cập nhật `BartenderController` tự động chọn repository theo `BartenderConfig.backend`.
  - Cấu hình cho phép cleartext HTTP (`android:usesCleartextTraffic="true"`) DUY NHẤT trong bản debug (`android/app/src/debug/AndroidManifest.xml`), không mở trong release.
  - Thêm unit test toàn diện `test/bartender_api_room_repository_test.dart` (3 tests pass) kiểm tra HTTP REST và WebSocket giả lập.
  - Toàn bộ 222 test Flutter pass 100%; `flutter analyze` 0 lỗi 0 cảnh báo; server test 10/10 pass 100%.

- **Bước C.4: Công cụ kiểm tra khói tự động hóa `server/tool/smoke.dart` (2026-10-30):**
  - Viết script `server/tool/smoke.dart` nhận tham số `baseUrl` (mặc định `http://localhost:8080`).
  - Kiểm tra toàn bộ vòng đời trận đấu từ bên ngoài qua HTTP và WebSocket:
    1. Kiểm tra sức khỏe `/health`.
    2. Tạo phòng mới `POST /rooms` (Host: "Người chơi 1").
    3. Người chơi 2 tham gia phòng `POST /rooms/{code}/join`.
    4. Mở WebSocket thời gian thực cho cả 2 người chơi, nhận snapshot phòng.
    5. Bắt đầu trận đấu `POST /rooms/{code}/start`.
    6. Chuyền nguyên liệu giữa 2 người `POST /rooms/{code}/items/send`.
    7. Bỏ vật phẩm vào thùng rác `POST /rooms/{code}/items/trash`.
    8. Người chơi rời phòng `POST /rooms/{code}/leave` -> kết thúc trận và nhận kết quả xếp hạng.
  - In tiến trình từng bước `[OK]` / `[FAIL]` bằng tiếng Việt rõ ràng, thoát mã 0 khi hoàn thành hoặc mã 1 khi có lỗi.
  - Đã chạy thử nghiệm trên `localhost:8080`: toàn bộ 8 bước kiểm tra khói vượt qua 100%.

- **Bước C.3: Triển khai toàn bộ backend game HTTP + WebSocket trên server (2026-10-30):**
  - Xây dựng `RoomService` in-memory (`server/src/room_service.dart`) đồng bộ 100% không `await` giữa đọc-ghi để triệt tiêu race condition:
    - `POST /rooms`, `POST /rooms/{code}/join`, `POST /rooms/{code}/leave`, `POST /rooms/{code}/start`.
    - `GET /rooms/{code}`, `POST /rooms/{code}/items/send`, `POST /rooms/{code}/items/trash`, `POST /rooms/{code}/items/process`, `POST /rooms/{code}/orders/submit`.
    - `GET /rooms/{code}/ws?token=...` nâng cấp WebSocket, phát snapshot thời gian thực ngay khi có thay đổi, gửi ping định kỳ mỗi 25s, tự động cập nhật cờ `connected` khi socket mở/đóng.
    - Chuyển round tự động khi mọi người chơi connected hoàn thành đơn: loại bỏ người disconnect và dồn `ringIndex` về `0..k-1` (D14), phân trạm ngẫu nhiên đảm bảo đơn khả thi (D15), tối đa 3 trạm (D16), tuân thủ bảng luật chế biến duy nhất `processItem` (D19).
    - Kết thúc trận khi hết giờ hoặc còn dưới 2 người: ghi `results` trước khi chuyển `status = ended`.
    - Dọn dẹp phòng cũ (phòng ended xóa sau 10 phút, phòng lobby trống xóa sau 30 phút).
    - Quản lý mã lỗi chuẩn API.md (`INVALID_REQUEST`, `UNAUTHORIZED`, `ROOM_NOT_FOUND`, `ITEM_NOT_FOUND`, `ROOM_FULL`, `ROOM_NOT_JOINABLE`, `NOT_ENOUGH_PLAYERS`, `INVALID_STATE`, `INVALID_MOVE`, `ORDER_MISMATCH`).
  - Viết bộ unit test game rules `server/test/room_service_test.dart` (8 tests) và test tích hợp End-to-End `server/test/e2e_match_test.dart` giả lập 2 người chơi qua HTTP + WebSocket in-process (toàn bộ 10 server tests pass 100%).
  - `dart analyze` (server) 0 lỗi, `flutter analyze` 0 lỗi 0 cảnh báo.

- **Bước B: Khung server Dart thuần tại `server/`, GET /health, Dockerfile và .dockerignore cho VPS (2026-10-30):**
  - Tạo package Dart thuần `bartender_server` trong thư mục `server/` (dùng `shelf`, `shelf_router`, `shelf_web_socket`, `web_socket_channel`).
  - Tái sử dụng trực tiếp các models từ `lib/games/bartender/models/` qua relative import mà không di chuyển file.
  - Cung cấp endpoint `GET /health` trả về JSON theo contract `{ "status": "ok", "rooms": 0, "timeMs": ... }`.
  - Đọc cổng từ biến môi trường `PORT` (mặc định 8080) và lắng nghe trên `0.0.0.0`.
  - Thêm `server/Dockerfile` (multi-stage build từ `dart:stable` -> `scratch` tối giản cho VPS) và `.dockerignore` tại thư mục gốc.
  - Không chứa bất kỳ cấu hình hay file liên quan đến Render (`render.yaml` không tồn tại, Dockerfile độc lập nền tảng).
  - Viết unit test cho `/health` (`server/test/health_test.dart` pass 100%).
  - Kiểm tra xác minh: `curl.exe http://localhost:8080/health` trả về 200 OK; `dart analyze` (server) 0 lỗi, `dart test` (server) 2/2 pass; `flutter analyze` 0 lỗi 0 cảnh báo.

- **Bước 1: Bổ sung serialization JSON (`toJson` / `fromJson`) cho toàn bộ models (2026-10-30):**
  - Cập nhật 7 model: `GameItem`, `Order`, `Player`, `MatchTimer`, `MatchResult`, `Round`, `Room`.
  - Khớp 100% contract snapshot trong `API.md` (các Map keyed theo `ringIndex` như `stationAssignment`, `progress`, `inbox` được chuyển thành String key "0", "1" trong JSON).
  - Giữ toàn bộ `models/*.dart` thuần Dart 100% (không import Flutter/`dart:ui`).
  - Viết bộ unit test `test/bartender_models_json_test.dart` (9 tests) kiểm tra độ thuần Dart và round-trip JSON serialization của từng model và snapshot phòng hoàn chỉnh.
  - Kết quả: `flutter analyze` 0 lỗi 0 cảnh báo; 219/219 tests pass 100%.

- **Cuộn giao diện trận đấu & Luồng quay lại phòng / bắt đầu lại sau khi thua (2026-10-30):**
  - **Phần 1: Cuộn dọc màn hình trận đấu (`BartenderMatchScreen`):**
    - Bọc toàn bộ khu vực thành phần trận đấu (RingNeighbors, StationWidget, OrderTrayWidget, khay đồ cá nhân, thùng rác, notices) trong `SingleChildScrollView` với `BouncingScrollPhysics` và padding dưới `24px`.
    - Cố định thanh thời gian (`TimerBarWidget`) trên cùng để người chơi luôn theo dõi được thời gian đếm ngược.
    - Đảm bảo khi có nhiều món hoặc trên màn hình nhỏ (360x640), nội dung không bị tràn xuống/đè lên thanh điều hướng (`navigation bar`).
    - Bổ sung widget test `test/bartender_match_scroll_test.dart` kiểm tra cuộn dọc và chống tràn (commit `66a6009`).
  - **Phần 2: Luồng kết thúc trận thua, quay lại phòng và chủ phòng bắt đầu lại:**
    - Cập nhật màn hình kết quả `BartenderResultsScreen`: hiển thị thông báo "BẠN ĐÃ THUA GAME 😢" khi thua; cung cấp 2 nút "THOÁT" (rời phòng về menu) và "QUAY LẠI PHÒNG" (trở về lobby phòng ban đầu).
    - Thêm cờ `readyInLobby` cho `Player` (mặc định `true` khi mới tạo/vào phòng; được reset về `false` khi trận kết thúc `ended`).
    - Thêm thuộc tính `allPlayersReadyInLobby` và `readyPlayerCount` trong `Room`; `canStart` yêu cầu `(status == RoomStatus.lobby || status == RoomStatus.ended) && connectedPlayerCount >= 2 && allPlayersReadyInLobby`.
    - Thêm `returnToLobby({required String code, required String playerId})` trên `RoomRepository`, `FakeRoomRepository` và `FirebaseRoomRepository`.
    - Khi người chơi bấm "QUAY LẠI PHÒNG":
      - Gọi `returnToLobby` cập nhật trạng thái của riêng người đó `readyInLobby = true` trên RTDB/repository.
      - Chuyển màn hình của riêng người đó về lại `BartenderLobbyScreen` (nhờ `isViewingResults = isMatchEnded && !_hasReturnedToLobby`), không ép thoát hay ảnh hưởng tới các người chơi khác còn đang xem kết quả.
    - Màn hình phòng chờ (`BartenderLobbyScreen`):
      - Hiển thị trạng thái của từng người chơi (`Sẵn sàng` vs `Đang xem kết quả...`).
      - Khi chưa đủ tất cả người chơi quay lại phòng: hiển thị thông báo chờ `"Đang chờ người chơi quay lại phòng... (X/Y)"`.
      - Khi toàn bộ người chơi connected đã quay lại phòng (`allPlayersReadyInLobby == true`): chỉ duy nhất chủ phòng (`myRingIndex == 0`) mới sáng nút "BẮT ĐẦU TRẬN ĐẤU!".
      - Khi chủ phòng bắt đầu lại: `startMatch` reset kết quả cũ, reset cờ sẵn sàng, khởi tạo round mới trên mã phòng cũ.
    - Cập nhật unit test và widget test trong `test/bartender_controller_test.dart` và `test/bartender_results_test.dart` (210/210 tests pass, `flutter analyze` 0 lỗi).

- **Phân quyền bắt đầu trận đấu & Cấp nguyên liệu định kỳ trên Firebase (2026-10-30):**
  - **Chỉ chủ phòng mới được bắt đầu trận đấu:**
    - Cập nhật giao diện `BartenderLobbyScreen`: Khi phòng đủ người (`canStart`), chỉ Host (`ctrl.myRingIndex == 0`) mới thấy nút "BẮT ĐẦU TRẬN ĐẤU!". Người chơi khác (khách) hiển thị dòng thông báo `'Đã đủ người! Đang chờ chủ phòng bắt đầu...'` cùng biểu tượng đồng hồ cát.
    - Cập nhật `BartenderController.startMatch`: chặn người chơi không phải host (`myRingIndex != 0`), báo lỗi `'Chỉ chủ phòng mới có thể bắt đầu trận đấu.'`.
    - Cập nhật `FirebaseRoomRepository.startMatch` và `FakeRoomRepository.startMatch`: chặn thực thi nếu caller không phải ringIndex 0 (host).
  - **Cấp nguyên liệu định kỳ mỗi 3s trên Firebase (multiplayer):**
    - `FirebaseRoomRepository` bổ sung logic spawn định kỳ (`_spawnTimers`, `_latestRooms`): khi `watchRoom` nhận trạng thái `playing`, tự động kích hoạt `Timer.periodic` mỗi 3s (`BartenderConfig.ingredientSpawnIntervalSeconds`).
    - Mỗi thiết bị tự động kiểm tra khay của chính mình (`myRingIndex`) từ snapshot Firebase, nếu số item < 5 thì push 1 nguyên liệu ngẫu nhiên vào `inbox/$myRing`. Do mỗi client chỉ ghi vào khay của chính mình, đảm bảo không có race condition / xung đột dữ liệu giữa các máy.
    - Dọn dẹp timer spawn an toàn khi round kết thúc, khi rời phòng (`leaveRoom`) hoặc khi stream cancel / dispose.
  - Bộ unit test bổ sung trong `test/bartender_controller_test.dart` và `test/bartender_navigation_test.dart`: 207/207 test pass 100%, `flutter analyze` 0 lỗi 0 cảnh báo.

- **Kích hoạt Firebase và gỡ bỏ hoàn toàn Bot (2026-10-30):**
  - Đổi `BartenderConfig.useFakeRepository = false` làm mặc định khi build/chạy trên máy thật để 2 thiết bị kết nối trực tiếp qua Firebase RTDB (`nhom-bar`).
  - Cấu hình `test/flutter_test_config.dart` tự bật `useFakeRepository = true` khi chạy test để toàn bộ 205 test offline vẫn pass 100%.
  - Gỡ bỏ hoàn toàn bot khi tạo phòng: đổi `totalPlayers = 1` mặc định trong `BartenderController.createRoom` (chỉ tạo duy nhất host, người thật tham gia bằng mã).
  - Xóa bỏ nhãn 'Bot' trong danh sách phòng chờ `BartenderLobbyScreen`.
  - Cập nhật test navigation kiểm tra luồng vào phòng của người chơi thật (không dùng bot).
  - Sửa lỗi lint `gacha_network_security_config.xml` (`includeSubdomains="true"`) giúp lệnh build release APK (`flutter build apk --release`) thành công hoàn toàn.

- **Dọn dẹp UI chuẩn bị nhiều người chơi thật (2026-10-28):** Bỏ bộ chọn số người chơi/bot (2, 3, 4 ChoiceChips) khỏi form tạo phòng trong `BartenderLobbyScreen` theo đúng kiến trúc D13 (số người do người chơi thật tham gia thực tế quyết định, không cần cấu hình trước). Cập nhật câu hướng dẫn mời bạn bè.
- **Sửa kiểm tra phòng tồn tại khi join (2026-10-28):** Sửa `FakeRoomRepository.joinRoom` để khi nhập mã phòng không tồn tại thì ném lỗi `StateError('Phòng #$code không tồn tại.')` đồng nhất với `FirebaseRoomRepository` và chuẩn `API.md:53` (thay vì tự tạo phòng mới với bot và mã ngẫu nhiên). Cập nhật unit test tương ứng trong `test/bartender_controller_test.dart`.
- **Join-by-code flow (2026-10-28):** Thêm tab "Vào phòng" vào `BartenderLobbyScreen` với TextField nhập mã 4 chữ số, nút "VÀO PHÒNG", cùng nút chuyển đổi nhanh trực tiếp trên giao diện mặc định. Sửa màu chữ AppBar "QUẦY BARTENDER" sang trắng rõ nét trên nền tối. Nút "Rời phòng" có sẵn ở màn chờ lobby. Nhãn vai trò người chơi cập nhật đúng (Bạn/Host/Đồng đội/Bot). Bộ test join flow cập nhật trong `test/bartender_controller_test.dart`. `BartenderConfig.useFakeRepository = true` giữ nguyên.

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

## Tích hợp UI vào logic — 2026-10-30

- Logic: `2b50690979039741ca651380269089199595223e` từ `origin/dev/Zhoufen`; đã xác nhận remote vẫn ở commit này khi chốt.
- UI: `aac84ce` trên `dev/Abu.ui`, snapshot lưu mọi thay đổi UI trước khi merge. Không rebase/reset/stash hoặc làm mất UI trước đó.
- Merge local trên `dev/Zhoufen`; không push remote.
- Người dùng yêu cầu duyệt riêng conflict logic, đã lần lượt đồng ý:
  1. Lobby đọc `readyInLobby`, `readyPlayerCount`, `room.canStart`; bỏ `bartender_ready` Firebase riêng. Mọi player quay lại phòng cũ, chỉ host bấm SẴN SÀNG để mở trận mới.
  2. Giữ UI/thao tác 3D; gọi controller.submitOrder mới theo ID instance; banner nối lại/mất kết nối trong 3D và fallback; fallback cuộn khi màn hẹp, sửa tràn chữ.
  3. Giữ kết quả gỗ–kem; QUAY LẠI PHÒNG gọi returnToLobby và giữ mã; THOÁT rời phòng về menu.
- Đối chiếu controller, model, RoomRepository/API/Firebase/Fake, server, backend config và lockfile: không khác Zhoufen. Không sửa backend để thích nghi UI.
- `pub get --enforce-lockfile` cho app và server; không nâng dependency.
- **131 test Flutter Bartender qua**, gồm API/WebSocket, controller, models/JSON, processing/round/shake, results, reconnect/scroll, bridge và hai test entry hiện tại (900×400, 390×844). Log: `build/merge-verify/flutter-tests.log` (không commit).
- Test navigation cũ mô tả entry Home/lobby chung và nhãn UI cũ, không nằm trong bộ 131. Không sửa entry hiện tại để khớp test cũ; test thay thế trong module kiểm tra tạo phòng → trận → kết quả → quay về cùng mã phòng → host chờ peers → trận mới → thoát menu.
- **11 test server HTTP/WebSocket qua**, gồm E2E hai client giả lập. WebGL offline drag/4 thao tác/cut/pass/submit/spawn/paging/idle/pause/dispose qua.
- Analyze module/main: không error/warning; còn lint info trong UI/snapshot và script chụp ảnh bỏ qua Git. Diff whitespace authored source sạch; bundle Three.js sinh tự động giữ whitespace trong shader strings.
- **APK debug build thành công** (`build/app/outputs/flutter-apk/app-debug.apk`, 195.8 giây). Dùng thư mục Java tạm ngắn/heap 2 GB trong tiến trình như trước; không sửa Gradle/cấu hình hệ thống.
- Chưa cài/chạy lại APK tích hợp lên máy thật hay kiểm tra hai máy Android online. Backend mặc định vẫn `fake`; API cần server và dart-define theo `scene3d/README.md`.
