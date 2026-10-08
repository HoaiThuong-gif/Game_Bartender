# Nâng cấp xé giấy và đánh giá Three.js — 2026-10-03

## Three.js: giữ renderer hiện tại cho Gacha

Đã kiểm tra code thực tế:

- `package.json`: Three.js ^0.186.1; package nằm trong `node_modules/three/`.
- Có bản module trong `assets/rubik/three.module.js`. Rubik hiện chạy bundle
  `assets/rubik/rubik.js`, build từ `rubik-src.js` bằng esbuild; `index.html`
  nhúng bundle này, không trực tiếp import file three.module.js.
- `lib/games/rubik/widgets/rubik_3d_view.dart` mount WebView;
  `services/rubik_preview_bridge.dart` đồng bộ Flutter → `window.setCubeState`.
- Gacha dùng `model_viewer_plus: 1.10.0`, kiểm tra manifest asset trước khi
  mount đúng một GLB; `GachaModelStatus` báo loaded/error. Các phần này được giữ.

| Phương án | Lợi ích trong Gacha | Quyết định |
|---|---|---|
| Giữ model_viewer_plus | Đã có GLB local, camera controls, một lần xoay 20°, fade/scale Flutter, PNG fallback và cleanup | Dùng cho nhu cầu hiện tại |
| Scene Three.js riêng trong result | Hữu ích khi cần điều khiển transform của item độc lập: bay lên/hạ xuống, choreography camera/light, contact plane, Mixer hoặc raycasting | Chưa có lợi ích đủ rõ để thêm một renderer/bridge và lifecycle thứ hai |

Three.js có GLTFLoader/AnimationMixer/OrbitControls cho pipeline custom;
model-viewer đã có camera control/staging cho preview. Đây là đánh giá dựa vào
nhu cầu hiện tại, không phải benchmark khẳng định renderer nào nhanh hơn.
Tham khảo: [Three.js GLTFLoader](https://threejs.org/docs/pages/GLTFLoader.html),
[model-viewer staging/cameras](https://modelviewer.dev/examples/stagingandcameras/).

Không mount scene Three.js ở Gacha, không đổi GLB loader, không biến scene tiệm
thành WebView. Tiếp tục dành Three.js cho Rubik 3D và các tương tác Rubik sau này
vì project đã có scene/bridge phù hợp ở đó. Nếu sau này cần cinematic thực sự,
có thể làm scene result nhỏ riêng; chưa thêm code chết hoặc preload model cho nó.

## Cơ chế xé mới

- Lớp phủ texture đứng yên, trùng registration với nền; không translate/rotate
  toàn lớp phủ khi drag hoặc hoàn tất. Nền giữ viền artwork và có vùng giấy trống
  với sợi giấy nhẹ để vùng đã xé khác rõ với hình in trên lớp phủ.
- `PaperTearGeometry` tạo frontier **25 điểm cố định**. `PaperTearClipper`
  tạo path phần giấy còn lại cho `ClipPath`. Đây là progressive clip theo hướng
  kéo, không phải freehand scratch canvas lưu toàn bộ lịch sử pointer.
- Noise từ hai hàm sin theo chỉ số điểm: không Random theo frame. Finger Y
  thêm một độ cong nhỏ quanh vị trí tay. Chỉ nhận thay đổi Y trên 4 logical px.
  Giữ 25 giá trị frontier lớn nhất theo hàng: đổi vị trí tay theo chiều dọc
  cũng không che lại phần đã rách. Bộ nhớ không tăng theo số pointer event.
- `PaperTearEdgePainter` vẽ shadow 5 px, highlight 2 px và nét nâu 1 px;
  chỉ vẽ trong vùng texture, không dùng blur, ShaderMask, BlendMode hoặc saveLayer.
- `revealProgress` cộng dx/chiều rộng theo hướng kéo đầu tiên, clamp 0–1;
  tiến độ chỉ tăng. Kéo ngược không hàn vùng đã rách. Thả tay giữ tiến độ,
  kéo tiếp cùng hướng để hoàn thành. Ngưỡng gesture **65% chiều rộng**;
  đây không phải phép đo chính xác diện tích giấy.
- Vượt ngưỡng: mask mở phần còn lại trong 250 ms; bốn mảnh khác hình dạng
  rơi/xoay/fade, tự rời cây widget sau 450 ms. Lớp phủ/mép được remove khi mask
  hoàn tất. Số vẫn đọc được, bounce nhẹ; giữ flow dò bảng và kết quả 1.4 giây.
- Audio: rustle một lần khi bắt đầu mỗi gesture, tear một lần tại ngưỡng;
  không phát trong mỗi frame. Một AudioPlayer từ service hiện có.
  selectionClick ở đầu gesture, lightImpact khi hoàn tất.

## Rebuild, fallback và state

`GachaController.tearProgress` là ValueNotifier riêng. Progress repaint/rebuild
TearTicket trong RepaintBoundary; listener toàn màn chỉ nhận đổi stage.
Test 80 update liên tiếp kiểm tra identity GachaScene không đổi. Không có path
history vô hạn; số sample luôn 25, hai path nhỏ để clip và edge.

`GachaScreen(simplePaperMask: true)` bỏ độ cong theo tay, dùng frontier răng cưa
đơn giản; system disableAnimations cũng chọn geometry đơn giản. Không có bước
auto đo/xếp hạng GPU. Fallback vẫn giữ giấy đứng yên.

Random, collection, ví cá, mount/unmount viewer giữ logic hiện tại. Chuyển Lobby
khi đang xé giữ vùng rách và chuyển sang chờ kéo tiếp; lượt mới reset notifier,
direction và widget giấy. Controller/listener/animation đều dispose.

## File thay đổi

- `widgets/paper_tear_mask.dart`: geometry, clipper và edge painter mới.
- `widgets/tear_ticket.dart`: cover clip, backing paper, local finger motion,
  progress listener, hoàn tất mask và mảnh vụn.
- `controllers/gacha_controller.dart`: monotonic progress, giữ vết xé,
  notifier riêng và chỉ thông báo scene khi đổi stage.
- `widgets/gacha_scene.dart`, `screens/gacha_screen.dart`: nối notifier,
  fallback flag và haptic lightImpact.
- `test/paper_tear_mask_test.dart`: 6 test mới; các test flow/controller cũ
  cập nhật kỳ vọng giữ vết rách và clip đứng yên.
- `integration_test/gacha_device_test.dart`: xen kẽ hai hướng, chậm/nhanh,
  dừng giữa chừng và kéo ngược trước mỗi lượt; vẫn 20 vòng viewer native.
- `tool/monitor_gacha_memory.py`: thêm tham số --log/--output để lưu log từng đợt.

Không thêm/sửa dependency, không đổi pubspec hoặc Android config ở đợt này.

## Xác minh

- `flutter analyze`: No issues found.
- `flutter test`: 138 test pass, gồm 6 test mask mới và toàn bộ test trước đó.
- OPPO CPH1969 Android 11: bài native 20 lượt pass; 60 mount, 60 load Nón lá
  thành công, 60 dispose. Kiểm tra hai hướng, chậm/nhanh, giữ vết sau khi thả,
  kéo ngược, bốc tiếp, reopen và Lobby/Gacha.
- Sau chỉnh nền giấy/mép texture đã chạy thêm 4 lượt native. Bản giữ frontier
  theo hàng được kiểm tra lại bằng cùng bài 4 lượt trước khi build app bình thường.
- 22 mẫu ADB trong bài 20 lượt: PSS 308.7–441.0 MiB (gồm startup), mẫu cuối
  432.9 MiB. Đây là debug PSS; chưa đo FPS/profile hoặc chứng minh tuyệt đối
  rằng native WebView không leak. Lifecycle test không phát hiện renderer lỗi,
  timeout, random lại hoặc viewer còn trong widget tree sau đóng/đổi tab.
- Ảnh xé dở trên OPPO: `artifacts/gacha/tear-partial-device.png`.
- Log: `artifacts/gacha/tear-all-tests.txt`, `tear-device-test.txt`,
  `tear-device-final.txt`, `tear-memory-samples.jsonl`.
- APK debug app bình thường build thành công; log `tear-build-final.txt`.
  Đã cài lại và mở app bình thường trên OPPO thành công sau kiểm thử.

Chạy mặc định 20 lượt; có thể xác minh nhanh bằng
`--dart-define=GACHA_TEST_ROUNDS=4`. Ví/collection của harness tách khỏi dữ liệu thật.
