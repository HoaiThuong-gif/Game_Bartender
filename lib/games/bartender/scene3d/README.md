# Bartender 3D — isolated presentation / giao diện tách biệt

## English

The user requested warm cartoon 3D gameplay on 2026-10-30. The existing menu,
game rules, controller, room schema and repositories remain the integration base.
This is a first playable 3D implementation, not a claim of release readiness.

- `scene.mjs`: procedural meshes, real 3D dragging, station/pass/trash/submit zones,
  bounded item pages (8 visible), demand rendering, a lower resolution option,
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

### Bản chỉnh hình ảnh ngày 2026-10-30

- Camera lấy chiều rộng quầy làm chuẩn trên điện thoại ngang; vật phẩm scale
  1.25 thay vì 0.9, trạm scale 1.35. Tối đa 8 món/trang để giữ mục tiêu kéo rõ.
- Không hiển thị hướng dẫn, tên nguyên liệu hoặc thanh đồng đội. HUD lớn chỉ
  còn vòng, giờ và tổng đơn; đơn chờ nằm trên cảnh.
- Vật phẩm mới rơi/nảy/lăn trong 1.25 giây rồi dừng. Có thể bắt kéo giữa lúc
  rơi; cập nhật cùng ID không phát lại hiệu ứng. Không thêm physics engine hay
  lưu vị trí vào Firebase. Idle/pause/dispose vẫn được kiểm tra bằng WebGL.
- Màn kết quả dùng gỗ/kem/xanh lá, thống kê lớn và danh sách cuộn; ngang chia
  hai cột, dọc xếp trên dưới. Giữ controller và các hành động lobby/chơi lại.
- Test kết quả hiện có: 6 test qua; ảnh kiểm tra bố cục ngang 800×360 qua.
  Chưa chạy bản chỉnh hình ảnh này trên Android; dùng Hot Restart để nhận code.

### Cách chơi

- Không hiện nhãn tên dưới vật phẩm hoặc nút chuyền/nộp trong cảnh 3D.
- Kéo nguyên liệu vào trạm để đặt lên máy; máy ép/máy xay cần nhấn 4 lần.
- Thớt cần 4 đường rạch ngang riêng trên trạm; chạm đơn thuần không cắt.
- Đơn chờ nằm phía trên quầy. Kéo thành phẩm lên vùng trên (22% chiều cao)
  để nộp đơn khớp; kéo xuống mép dưới (14%) để bỏ. Cần kéo ít nhất 45 px.
- Vuốt trái/phải để chuyền. Bình lắc vẫn dùng cảm biến, chỉ có nút giả lập
  khi thiếu cảm biến. Tiến độ chế biến gắn với vật phẩm trong cảnh hiện tại;
  chỉ khi đủ 4 thao tác mới gọi controller. Không đổi API/schema của nhánh kia.
- Nút Hình đổi độ phân giải. Mỗi trang tối đa 8 món.
- Kiểm chứng bản sửa: WebGL test kiểm tra đặt vào máy chưa chế biến, đủ 4 lần
  nhấn mới hoàn thành, 4 đường cắt (tap không tính), kéo lên/xuống/trái/phải,
  không nhãn/nút nộp, cùng phân trang/pause/dispose. Cần thử lại trên Android.

### Khả năng merge về sau — đã đối chiếu, CHƯA merge

Đối chiếu ngày 2026-10-30:

- Nhánh làm việc: `dev/Abu.ui`, HEAD `1df812b`.
- Nhánh tham chiếu: `origin/dev/Zhoufen`, commit `5994178db00ee3888d4d9cc5c0a4055ddd028870`.
- Đã fetch để đọc; không merge, checkout, rebase, stash, commit hoặc push.
- API mà 3D sử dụng vẫn có trên nhánh Zhoufen: `myItems`, `myStation`,
  `myOrders`, `room`, `myPlayerId`, `leftNeighbor`, `rightNeighbor`,
  `isMatchPlaying`, `isBusy`, `swipeItemLeft/Right`, `trashItem`,
  `processItemAtStation`, `submitOrder` và các getter của HUD.
- Không thêm implementation `RoomRepository`, không sửa model hoặc schema.
  Vì vậy phần `readyInLobby`, quyền host, sinh nguyên liệu Firebase và quay lại
  phòng của Zhoufen không cần được viết lại để dùng renderer này.
- Màn 3D, bridge và renderer nằm trong các file mới. Điểm nối với UI hiện tại
  là `BartenderMatchScreen` cung cấp status/order panel và màn dự phòng.
- **Vẫn có vùng dễ xung đột:** hai nhánh đều sửa `bartender_match_screen.dart`,
  `bartender_lobby_screen.dart` và `TASK.md`. Giao diện lobby/main/pubspec đã có
  thay đổi chưa commit từ trước tác vụ 3D. Không thể hứa merge tự động sạch.
- **Cần thống nhất trạng thái sẵn sàng ở lobby:** UI hiện tại dùng node riêng
  `bartender_ready/{code}`, còn Zhoufen dùng `players/{uid}/readyInLobby` và
  `returnToLobby()`. Khi merge phải giữ một cơ chế theo logic mới; không mang
  nguyên cơ chế ready của UI cũ sang rồi kỳ vọng online hoạt động tự động.
- Khi thực sự merge, giữ logic/controller/repository mới của Zhoufen; áp dụng
  điểm nối màn 3D lên UI đã giải quyết xung đột. Không ghi đè cả file bằng bản
  cũ của nhánh này. Giữ cấu hình repository mà nhóm chọn; renderer dùng được
  với Fake hoặc Firebase qua cùng controller.

### Hiệu năng và kiểm chứng

- Một WebView, cảnh nhỏ, hình học/material dùng lại; gộp nền tĩnh theo material.
- Vẽ khi kéo/thay đổi trạng thái; không vòng RAF liên tục khi bàn đứng yên.
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
