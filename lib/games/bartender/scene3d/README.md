# Bartender 3D — isolated presentation / giao diện tách biệt

## Khởi động đồng bộ — 2026-10-31

- Người dùng đã duyệt thay đổi logic: chờ mọi máy tải xong quầy, đếm chung
  3–2–1, rồi mới dùng đủ 60 giây. Nút host gọi `startMatch(waitForScene: true)`.
- Trong snapshot, `timer.preparing: true` giữ đồng hồ ở 60; `readyPlayers` chứa
  ID các máy đã tải xong. WebGL báo `sceneReady` sau khi làm nóng shader và vẽ
  xong cảnh/vật phẩm đầu tiên. Fallback báo sau frame Flutter đầu tiên.
- `POST /rooms/:code/scene-ready` dùng Bearer token và JSON `{preparationId}`;
  `preparationId` là `timer.startedAt` của lượt chuẩn bị. Báo trễ từ trận cũ hoặc
  báo trùng không khởi động lại đồng hồ. Sau máy cuối cùng, backend đặt
  `startedAt = now + 3000`, `endTime = startedAt + 60000` và phát cùng snapshot
  cho cả phòng. Thao tác, bot và spawn chờ tới mốc bắt đầu.
- Nếu peer rời phòng, vẫn áp dụng luật kết thúc khi dưới hai người; từ hai
  người trở lên thì chỉ chờ những người còn kết nối. Giữ nguyên luồng mọi
  player quay về lobby và host bắt đầu trận mới.
- Fake, API/server và Firebase đều có luồng này. API cần khởi động lại/deploy
  **server đã cập nhật** cùng client; server cũ chưa có endpoint báo tải xong.
  Không nâng dependencies hay thay backend mặc định `fake`.
- Tối ưu renderer: chỉ đổi kích thước bộ đệm khi viewport/chất lượng đổi;
  snapshot busy/order không xếp lại pile; bỏ cập nhật nhãn ẩn mỗi frame;
  tái dùng bộ nhớ cho bóng và chỉ cập nhật bóng khi có chuyển động. Làm nóng
  geometry/shader trong bước chuẩn bị, giới hạn độ phân giải để giảm tải GPU.
- Kiểm tra: 134 test Flutter Bartender (gồm ba test chuẩn bị mới), 14 test
  server (gồm hai WebSocket cùng nhận mốc bắt đầu, tải chậm và rời phòng);
  WebGL kiểm tra barrier, canvas không cấp lại khi cập nhật, pile ngủ khi đứng yên.
  Android emulator đã thử cảnh tải giữ 01:00, ghi lại 3 → 2 → 1 và mở khóa vẫn
  01:00 (`test-output/android-ready-6..9.png`); chưa đo FPS
  bản profile/release trên điện thoại thật hoặc chạy Firebase nhiều máy thật.
- Bản APK cũ bên dưới chưa chứa thay đổi khởi động này; dùng hot restart hoặc
  build/run lại từ mã hiện tại.

## English

The user requested warm cartoon 3D gameplay on 2026-10-30. The existing menu,
game rules, controller, room schema and repositories remain the integration base.
This is a first playable 3D implementation, not a claim of release readiness.

- `scene.mjs`: procedural meshes, real 3D dragging, station/pass/trash/submit zones,
  one random stack containing every inbox item, demand rendering, a lower resolution option,
  pause/resume and GPU resource disposal.
- `build_scene.cjs`: bundles the installed Three.js into `scene_bundle.dart`.
  Rebuild after editing JS. Commit source and generated Dart together. No CDN,
  new Flutter asset declaration, package upgrade or Firebase paths are needed.
- `../services/bartender_scene_bridge.dart`: validates current round, owned item,
  station, product and pending order before calling the existing controller.
- `../widgets/bartender_scene_view.dart`: offline Android WebView, state coalescing,
  sensor handling, lifetime management and fallback when WebGL fails.
- `../screens/bartender_3d_match_screen.dart`: presentation shell. Existing match
  status and order widgets are supplied by `BartenderMatchScreen`; it retains
  its original lightweight screen for unsupported platforms/failures.

```powershell
node lib/games/bartender/scene3d/build_scene.cjs
node lib/games/bartender/scene3d/verify_scene.cjs
flutter test lib/games/bartender/tests/bartender_scene_bridge_test.dart
```

`verify_scene.cjs` uses the installed Codex Playwright runtime and Chrome. Its
software WebGL checks are functional tests, not Android FPS measurements.
Screenshots and reports go in ignored `test-output/`.

## Tiếng Việt

### Giao diện mới và đống vật phẩm — 2026-10-30

- Phát triển trên `dev/Zhoufen` theo quy ước người dùng. Controller, model,
  repository và các luồng đã merge không bị sửa.
- Một bàn chứa toàn bộ inbox: không phân trang, không giới hạn/xóa bớt vật phẩm.
  Vị trí rơi ngẫu nhiên, lăn ngắn tới vị trí nghỉ thấp hơn ở gần; tiếp xúc được
  xấp xỉ bằng khoảng cách để tạo đống nhiều lớp. Kéo món đỡ bên dưới hoặc mất
  item theo snapshot sẽ làm các món phía trên hạ xuống. Đây là mô phỏng trình
  bày nhẹ, không dùng physics engine hoặc đồng bộ tọa độ lên server.
- Raycast chọn mesh thực sự phía trước; không có chọn xuyên qua vật che bằng
  cách tìm tâm gần nhất. Có thể bắt vật đang rơi; thả/hủy kéo thì nó tiếp tục rơi.
- Geometry màu gộp/cached theo loại: một mesh/vật phẩm. Bóng mềm trên mặt bàn
  dùng chung một InstancedMesh; tài nguyên được giải phóng khi đóng cảnh.
- Camera tự lấy khung cho đống cao, giữ toàn bộ item trong scene và dừng vẽ
  khi rơi/nhấn xong. Đồ vẫn có thể che nhau như người dùng yêu cầu.
- Máy ép có khay/côn/cần ép/ly riêng: trạng thái rỗng, đã nạp, nhấn cần ép.
  Trái cây nằm trong khay, cần hạ và mực nước tăng theo từng nhấn; đủ bốn nhấn
  mới gửi action chế biến cho Dart. Dao có chuyển động theo đường cắt.
- Màn chơi dùng khung xanh/gỗ/vàng, đồng hồ lớn, phiếu đồ uống SVG phía trên;
  không tên nguyên liệu, hướng dẫn vuốt hoặc nút chuyền/nộp.
- Kết quả có nền xanh, cúp vẽ bằng Canvas, thẻ thống kê kem và hạng đầu màu vàng.
  QUAY LẠI PHÒNG/THOÁT vẫn dùng returnToLobby/leaveRoom của Zhoufen.

### Cách chơi

- Đặt nguyên liệu lên máy rồi nhấn 4 lần để ép; thớt cần 4 đường rạch riêng.
- Kéo thành phẩm lên vùng trên để nộp đơn khớp, xuống dưới để bỏ, hai bên chuyền.
- Bình lắc dùng cảm biến; nút giả lập chỉ hiện khi không có cảm biến.
- Nút ◈/◇ đổi độ phân giải. Không có trang 2; dọn/chuyền đồ để tìm món bị che.

### Kiểm chứng lượt giao diện này

- 16 test Flutter về kết quả, entry/lobby/restart, bridge/nộp đơn và reconnect qua.
  Ba ảnh kiểm tra bố cục kết quả 1100×420, 800×360, 390×844 qua.
- Analyze ba file Dart UI mới/sửa: không issue.
- WebGL qua kiểm tra máy ép rỗng/nạp/4 nhấn, cắt, nộp/chuyền/bỏ, bắt/thả khi rơi,
  80 item không phân trang, snapshot không xáo đống đồ, mất vật đỡ, idle/pause/dispose.
  Mẫu 80 item khoảng 134 draw calls và 108,260 tam giác; không phải đo FPS Android.
- Android `emulator-5554` chạy code mới qua attach + Hot Restart/Hot Reload:
  xác nhận HUD/quầy, kéo cam vào máy ép làm cần hạ/hiện trái cây và màn kết quả.
  Ảnh `test-output/android-pile-live.png`, `android-pile-loaded.png`,
  `android-pile-results.png`. Máy ảo không có hai thiết bị online trong lần này.
- Ổ C thiếu chỗ cho file test, nên TEMP/TMP của tiến trình kiểm tra đặt tại
  `<repo>/build/test-tmp` trên ổ D. Không xóa dữ liệu người dùng hay đổi env hệ thống.
- Chưa đo độ mượt trên máy Android thật. APK tại đường dẫn build thuộc bản merge
  trước; code giao diện mới đã chạy bằng Hot Reload, chưa đóng gói APK mới lần này.

### Tích hợp UI vào logic Zhoufen — 2026-10-30

- Nguồn logic: `origin/dev/Zhoufen` tại `2b50690979039741ca651380269089199595223e`.
  Đã kiểm tra remote lần nữa trước khi chốt, chưa có commit mới hơn.
- Nguồn UI: snapshot `aac84ce` trên `dev/Abu.ui`. Tích hợp bằng merge vào local
  `dev/Zhoufen`. Không push lên remote trong tác vụ này.
- Người dùng đã duyệt riêng ba conflict trước khi sửa:
  1. Lobby dùng `readyInLobby` và `room.canStart`; mọi người quay lại phòng cũ,
     chỉ host bấm SẴN SÀNG để mở trận mới. Bỏ node ready Firebase riêng của UI.
  2. Giữ 3D và thao tác hiện có; nộp qua `controller.submitOrder` mới của Zhoufen
     bằng ID instance. Giữ banner nối lại/mất kết nối trong 3D và màn dự phòng;
     màn dự phòng có thể cuộn khi hẹp.
  3. Kết quả giữ giao diện gỗ–kem: QUAY LẠI PHÒNG gọi `returnToLobby()` và giữ
     mã phòng; THOÁT gọi `leaveRoom()`.
- Controller, model, repository/API/Firebase/Fake, server, backend selector và
  lockfile được giữ theo Zhoufen. Không sửa logic backend để thích nghi renderer.
- Menu vẫn dùng entry Bartender/ngang và ảnh nền của snapshot UI. Bộ chọn 2/3/4
  phục vụ Fake; API tạo phòng người thật qua server theo logic Zhoufen.
- Backend mặc định là `fake`. Để dùng server, chạy server rồi chạy Flutter với
  `--dart-define=BARTENDER_BACKEND=api --dart-define=API_BASE_URL=http://10.0.2.2:8080`
  trên emulator; máy thật cần URL/IP server truy cập được.
- Test navigation cũ `test/bartender_navigation_test.dart` mô tả entry ứng dụng
  Home/lobby chung và các nhãn trước khi UI thay đổi. Không sửa test này hay
  thay entry hiện tại để khớp nó. Test thay thế trong module:
  `../tests/bartender_merge_flow_test.dart` kiểm tra entry hiện tại, nút tạo phòng,
  vào trận, quay về cùng mã phòng, host phải chờ peer và khởi động lại, thoát menu
  ở 900×400 và 390×844.
- Kiểm chứng cuối: 131 test Flutter Bartender, 11 test server HTTP/WebSocket,
  WebGL và build APK debug đã qua. Chưa cài/chạy APK tích hợp trên máy thật hoặc
  hai máy Android online; xem `../TASK.md` cho phạm vi kiểm tra.

### Hiệu năng và kiểm chứng

- Một WebView, cảnh nhỏ, hình học/material dùng lại; gộp nền tĩnh theo material.
- Vẽ khi kéo/rơi/nhấn/thay đổi trạng thái; không vòng RAF khi bàn đứng yên.
- Không gửi tọa độ ngón tay hoặc frame 3D sang Dart/Firebase; ticker đồng hồ
  không làm tải lại WebView hoặc gửi lại cảnh không thay đổi.
- Giới hạn pixel ratio và tổng pixel; không bóng động, vật lý, postprocessing,
  texture lớn hoặc glass transmission.
- Test Chrome hiện tại: 18,300 tam giác, 93 draw calls cho fixture 8 món;
  xác nhận kéo/chế biến/nộp/chuyền, bốn trạm, phân trang, idle, pause và dispose.
- 90 test Dart về model/controller/processing/round/shake/bridge đã qua.
- Phân tích Dart các file mới: không có issue. `flutter build bundle --debug
  --no-pub` đã biên dịch thành công code/tài nguyên.
- Máy ảo Android `emulator-5554` đã chạy code mới bằng hot restart trên APK
  debug có sẵn: tạo phòng bot, vào cảnh 3D, kéo chanh vào máy ép, nộp thành phẩm
  đúng đơn (1/3, thông báo +5s, món biến khỏi bàn), hết giờ và hiện kết quả.
  Ảnh: `test-output/android-live.png`, `android-processed.png`,
  `android-submitted.png`, `android-results.png`.
- **APK debug mới đã build thành công:** `build/app/outputs/flutter-apk/app-debug.apk`.
  Đã cài và chạy trực tiếp APK này trên `emulator-5554` (không hot restart),
  xác nhận quầy 3D hiện và kéo chuyền nhận thông báo đúng.
  Ảnh: `test-output/android-apk-warm-match.png`, `android-apk-pass.png`.
  Lỗi `Unable to establish loopback connection` của Java được giải quyết bằng
  thư mục tạm ngắn trong workspace: `-Djava.io.tmpdir=<repo>/build/java-tmp`
  và `-Djdk.net.unixdomain.tmpdir=<repo>/build/java-tmp`, áp dụng qua
  `JAVA_TOOL_OPTIONS` chỉ trong tiến trình. `GRADLE_OPTS` dùng daemon riêng với
  heap 2 GB. Không sửa file Gradle hoặc thiết lập Java toàn hệ thống.
- Số liệu `gfxinfo` debug máy ảo có jank lúc khởi động/WebView warmup; không
  dùng chúng để khẳng định gameplay đạt 60 FPS. PSS của app ở một mẫu khoảng
  309 MiB, chưa bao gồm phân tích đầy đủ mọi tiến trình WebView hay release RAM.
- Cần đo frame time/RAM và cảm giác kéo trên máy Android thật. Chưa có bằng
  chứng đủ để tuyên bố 60 FPS trên mọi máy thật hoặc máy ảo.
- Cần kiểm tra hai thiết bị Firebase sau khi nhóm tích hợp nhánh. Nhánh hiện
  tại vẫn giữ `useFakeRepository = true`; không nhận thay đổi cấu hình online
  của Zhoufen chỉ bằng thao tác fetch.

Tham khảo kỹ thuật: [render khi có thay đổi](https://threejs.org/manual/pages/rendering-on-demand.html),
[giới hạn độ phân giải](https://threejs.org/manual/pages/responsive.html),
[giải phóng GPU resources](https://threejs.org/manual/pages/cleanup.html).
