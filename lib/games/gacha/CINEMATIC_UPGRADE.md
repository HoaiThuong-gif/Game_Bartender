# Giấy lớn và Three.js cinematic — 2026-10-03

Nâng cấp giữ nguyên progressive ClipPath/frontier, state machine, ví và collection.
Chạm hộp để bốc như trước; không đưa nút bốc riêng hoặc biển Gacha trở lại.

1. **Giấy cũ/mới.** Cũ bị giới hạn trong khoảng trống giữa hộp và guidance:
   `paperWidth = 1.4 * min(.60*w/1.4, guideTop-ticketTop-.006*h)`,
   với `w=min(viewportWidth, viewportHeight/2.17)`, `h=2.17*w`.
   Theo bố cục hiện tại, giấy chỉ rộng khoảng `.262*w` (khoảng 94–103 logical px
   trên portrait thường gặp). Mới dùng viewport độc lập: rộng `.82*viewportWidth`
   trên portrait, lớn hơn khoảng 3.1 lần hoặc hơn so với bố cục cũ.

2. **Responsive.** `paperWidth=min(.82*availableWidth, .72*availableHeight*1.4)`;
   `paperHeight=paperWidth/1.4`. Available là LayoutBuilder trong SafeArea,
   phía trên navigation. Giữ cách crop frame giấy/tỉ lệ 1.4 của màn đang chạy,
   không stretch sprite ba frame. Landscape giới hạn theo chiều cao để không tràn.
   Vùng gesture phủ toàn bộ giấy; delta và fingerY vẫn chia theo kích thước local
   thực tế. Frontier 25 hàng/noise đã chuẩn hóa tiếp tục giữ vết khi thả/kéo ngược.
   Giấy ở giữa viewport, dim đen alpha 0x38, shadow bằng Canvas.drawShadow,
   scale 1→1.015 khi kéo. Số dùng font theo chiều rộng giấy.
   Giữ giấy lớn 500 ms sau complete; sau đó di chuyển xuống, scale .82,
   bỏ dim để bảng highlight trong 600 ms; itemReveal fade/scale trong 300 ms.
   Tủ đồ/Tỷ lệ vẫn nhận tap khi đang xé dở.

3. **Nơi nhúng Three.js.** Chỉ `GachaResultPanel` mount
   `GachaCinematicViewer` trên Android khi result đang mở. Scene chỉ có item,
   camera, bục, hai light và bóng giả. UI/giấy/bảng/background/navigation vẫn Flutter.
   Tủ đồ tiếp tục dùng PNG; không tạo renderer hoặc preload GLB cho grid.

4. **HTML/JS.** Thêm `assets/gacha3d/index.html`, `cinematic-src.js`,
   `framing.mjs` và bundle `cinematic.js` (~642 KiB).
   `npm run build:gacha` dùng esbuild/Three.js đã có, không tải CDN/runtime.
   Khai báo thư mục asset trong pubspec; không thêm dependency hoặc đổi cấu hình
   Android ở đợt này. Không sửa Rubik.

5. **Bridge.** JavaScript channel `GachaCinematic` gửi JSON
   `ready`, `settled`, `orbit`, `error`, `disposed`. Flutter bỏ loading cover khi
   ready, kiểm soát timeout 45 giây và fallback khi lỗi. `window.disposeGacha()`
   là lệnh teardown. `window.gachaSnapshot()` cho integration test kiểm tra RAF,
   số render và thao tác orbit; không thêm thông tin kỹ thuật vào UI người chơi.

6. **GLB.** `GachaCinematicServer` bind loopback 127.0.0.1 cổng ngẫu nhiên,
   chỉ có ba route: HTML, JS và `/model.glb` của reward hiện tại. Manifest được
   kiểm tra trước khi mount; đường dẫn model chỉ chấp nhận GLB bundled trong
   `assets/models/gacha/`, không đọc filesystem hoặc URL bên ngoài.
   JS fetch có AbortController, GLTFLoader.parseAsync đọc GLB/texture embedded.
   Không cache loader/model qua lượt. Nón lá hiện có 803564 byte, 5 mesh,
   3 material, 1 texture, **không có animation clip**. Năm món thiếu GLB vẫn dùng
   PNG đúng món; không lấy test_item.glb thay thưởng.

7. **Camera/animation.** PerspectiveCamera FOV 38°. Sau warmup dưới loading cover,
   cinematic 760 ms: item scale .7→1, đi lên .18 unit, xoay -25°→0°, hạ xuống bục;
   camera từ khoảng cách 1.18*d tiến đến d bằng easeOutCubic rồi dừng.
   Framing project cả tám góc bounding box gồm chiều sâu/bục, với khoảng trống
   quanh vật phẩm; kiểm tra cả model bẹt và cao ở ba aspect ratio.
   Orbit sau settle: không pan/autoRotate/damping, polar 32.4°–84.6°,
   azimuth ±153°, zoom .90*d–1.30*d. Chỉ render khi controls change/resize.
   Nếu GLB có clips, chạy clip đầu bằng AnimationMixer một lần; không tạo mixer
   khi không có clip. Nhánh animation clip chưa có asset thật để kiểm thử native.

8. **Light/shadow/particle.** HemisphereLight và một DirectionalLight,
   cylinder gỗ 32 đoạn, không realtime shadow/bloom/postprocessing.
   Bóng tiếp xúc là plane với gradient CanvasTexture 64×64.
   Sáu mảnh giấy 3D dùng chung geometry/material, sống trong cinematic rồi dispose.
   Reduced motion bỏ particle/clip và chốt transform ngay.
   Antialias tắt, pixel ratio tối đa 1.25, powerPreference low-power.

9. **Dispose.** Hủy timeout/RAF, abort fetch; gỡ resize/pagehide/contextlost và
   controls listeners; dispose controls; mixer.stopAllAction/uncacheRoot;
   dispose geometry/material/texture có deduplicate và close ImageBitmap;
   clear scene, renderLists.dispose, renderer.dispose/forceContextLoss, bỏ canvas
   và references. GLB parse về sau khi đã đóng cũng được dispose.
   Flutter gọi teardown, chuyển about:blank, đóng server rồi unmount WebView.
   Lần Three mount tiếp theo đợi future cleanup trước đó; không giữ viewer nền.
   Android quyết định thời điểm giải phóng native WebView/GC cuối cùng.

10. **Giữ renderer nào.** Three.js dùng luôn cho cinematic và orbit trong result.
    Giữ model_viewer_plus 1.10.0 làm fallback khi Three/WebGL/tải lỗi;
    release Three trước khi mount legacy. Native test đã giả lập contextlost
    và kiểm tra GLB tải lại bằng legacy, không còn Three WebView.
    Không mount hai renderer cùng lúc. Test viewerBuilder vẫn inspect legacy
    configuration mà không dựng platform view.

11. **RAM/FPS.** Bài stress 20 lượt của bản warmup cuối: 61 lần ready/settled
    (60 lần trong flow và một lần trước test fallback). RAF cinematic 46.5–60.6 FPS,
    median 59.3; median p95 frame interval 16.6 ms, max p95 83.1 ms.
    Load GLB + parse + warmup 316.7–939.7 ms, median 647.5 ms;
    warmup renderer/shader/texture là 195.8–657.1 ms trong khoảng trên.
    Đây là chỉ số của cinematic WebView ngắn trong debug integration test,
    không phải FPS release/toàn bộ Flutter app. Sau settle test xác nhận RAF=0
    và render count không tăng trong 300 ms idle; drag thật gửi orbit.
    25 mẫu ADB app PSS: 331.0–428.0 MiB gồm startup; mẫu cuối trước teardown
    ở lượt 19 là 411.6 MiB. Các lượt giữa/cuối dao động, không tăng đều theo lượt.
    Số geometry/texture sau settle giữ ở 7/3. PSS này không cộng mọi process WebView
    sandbox và chưa phải chứng minh tuyệt đối không leak native.
    Bản thử trước warmup kép có khựng rõ; đã sửa và chạy lại đầy đủ 20 lượt.
    Sau framing cuối, 2 lượt/7 lần mở đạt 50.3–59.3 FPS, median 58.0;
    load + warmup 371.0–1007.4 ms. Không đo lại RAM ở đợt chỉnh phép tính camera.

12. **Analyze.** `flutter analyze`: No issues found. `node --check` bundle pass.

13. **Test.** `flutter test`: 141 pass (toàn bộ 138 trước đó và 3 test server).
    Responsive: 320×568, 360×800, 393×873, 412×915, 844×390, text scale 1.6,
    SafeArea/navigation. Kiểm tra vùng drag bằng giấy, giữ giấy lớn 500 ms,
    thu/lower trước result; test tear frontier/reverse và collection vẫn pass.
    `node --test test/gacha_cinematic_framing_test.mjs`: 6 pass, gồm dolly và
    giới hạn zoom không cắt item/bục ở portrait/landscape và model thấp/cao.

14. **Máy thật.** OPPO CPH1969 Android 11, serial 6TJRA6YTFUYL75KV.
    Hai bài stress, mỗi bài 20 lượt, đều pass; bài sau dùng warmup đã sửa.
    Mỗi lượt xé hai hướng luân phiên, chậm/nhanh, thả giữa chừng, kéo ngược,
    xoay item bằng gesture native, nhận/đóng, reopen, Lobby/Gacha, bốc tiếp.
    Không crash, timeout, fallback PNG ngoài ý muốn hoặc WebView trắng trong bài.
    Context loss được cố ý giả lập ở cuối và fallback GLB pass.
    Sau chỉnh framing camera, thêm 4 lượt và 2 lượt kiểm tra khoảng cách cuối,
    đều pass. APK debug app thường build thành công, cài lại và mở trên OPPO
    sau integration; tắt chế độ giữ màn hình sáng tạm thời dùng khi kiểm thử.
    Ví/collection của harness chỉ ở bộ nhớ, tách khỏi dữ liệu người chơi.

## Artifact và cách chạy

- `artifacts/gacha/cinematic-analyze.txt`, `cinematic-tests.txt`, `cinematic-js-tests.txt`.
- `cinematic-device-20.txt`: stress trước sửa warmup, có số liệu khựng.
- `cinematic-device-final.txt`, `cinematic-memory-final.jsonl`: stress warmup cuối.
- `cinematic-device-framing.txt`, `cinematic-device-framing-final.txt`:
  4 lượt framing và 2 lượt khoảng cách cuối.
- `cinematic-paper-device.png`, `cinematic-result-device.png`: screenshot OPPO.
- `cinematic-build.txt`: build APK app thường sau integration.

```text
npm run build:gacha
flutter analyze
flutter test
node --test test/gacha_cinematic_framing_test.mjs
flutter test integration_test/gacha_device_test.dart -d 6TJRA6YTFUYL75KV
```

API đối chiếu: [GLTFLoader](https://threejs.org/docs/pages/GLTFLoader.html)
và [OrbitControls](https://threejs.org/docs/pages/OrbitControls.html).
