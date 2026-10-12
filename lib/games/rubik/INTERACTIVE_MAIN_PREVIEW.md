# Rubik tương tác ở màn chính — 2026-10-03

1. **Màn sửa:** `screens/rubik_screen.dart`. Chỉ thay import và widget body
   từ Rubik3DView sang RubikInteractivePreview. Scaffold, AppBar, SafeArea,
   bottomNavigationBar, vị trí và callback của GIẢI RUBIK/THÁCH ĐẤU giữ nguyên.

2. **Renderer cũ:** WebView tải `assets/rubik/index.html`/`rubik.js`, Three.js
   dựng grid 27 cubie. Kéo chỉ đổi rotation của cả root; không xoay layer.
   Rubik3DView/renderer cũ còn dùng cho preview nhập màu và các màn giải.

3. **Renderer mới:** WebView riêng chỉ cho màn chính, tải `interactive.html`
   và bundle `interactive.js`. Procedural grid 3×3×3 (26 cubie ngoài và core ẩn),
   54 sticker nằm trong cubie group. State hoàn toàn local, không nối solver,
   scanned state, tutorial hoặc database. Khi trở về từ màn con sẽ reset solved.

4. **Three.js:** `interactive-src.js` quản lý scene/camera/OrbitControls/gesture/
   render/lifecycle; `interactive-cube.mjs` dựng cube, raycast, chọn và snap layer.
   Build bằng `npm run build:rubik-toy` với Three.js/esbuild đã có, bundle ~552 KiB.
   Assets nằm trong thư mục `assets/rubik/` đã đăng ký; không sửa pubspec/dependency.
   Có hai nút nhỏ Hoàn tác/Đặt lại theo yêu cầu bổ sung; không thêm scramble.

5. **Raycast:** Tọa độ pointer đổi thành NDC từ bounding rect của canvas;
   Raycaster.setFromCamera và intersectObjects tìm mesh gần nhất. Mesh giữ
   reference tới cubie; face normal được biến đổi bởi matrixWorld để vẫn đúng
   sau nhiều lượt quay. Chỉ lấy mặt ngoài. Nếu ray lọt qua khe hẹp, dùng silhouette
   bounding box và chọn cell gần nhất trên mặt ngoài, tránh biến cú vuốt ở khe
   thành orbit ngoài ý muốn.

6. **Chọn layer:** Lưu cubie, normal, point và điểm bắt đầu khi pointerdown.
   Khi vượt 18–30 CSS px, xét hai axis nằm trong mặt chạm. Chiều chuyển động
   dương là `axis × faceNormal`; project tangent qua camera hiện tại và so với
   vector swipe để chọn axis/sign. Layer là tọa độ grid của cubie theo axis đó.
   Camera đã orbit vẫn dùng cùng phép chiếu; hỗ trợ x/y/z, layer -1/0/1, hai chiều.

7. **Animation:** 9 cubie thuộc layer attach vào Group tạm tại tâm root;
   quay ±π/2 trong 240 ms với smoothstep, không reload scene/WebView. Mỗi gesture
   chỉ commit một lượt; không nhận lượt khác khi lượt trước chưa hoàn tất.

8. **Snap:** Attach lại root, position round về {-1,0,1} và chuẩn hóa -0.
   Quaternion snap về orientation gần nhất trong nhóm 24 hướng hợp lệ của cube,
   tránh lỗi do Euler/gimbal lock và tích lũy sai số. Sticker là child của cubie,
   không đổi màu/material để giả lập move. Remove group tạm sau commit.

9. **Orbit/layer:** Capture-phase pointerdown raycast trước OrbitControls.
   Bắt đầu ngoài cube → OrbitControls; trên cube → giữ gesture cho layer,
   stopImmediatePropagation và disable controls đến khi xong. Tap/drag dưới
   threshold/cancel trước commit không quay. Enable controls trở lại khi move
   xong và finger đã thả. Orbit không pan, không autoRotate/damping; zoom tắt,
   camera nhìn tâm. Giữ FOV 40°, kích thước cubie .92 và công thức camera fit cũ
   để cục chính không bị làm nhỏ hay đổi vùng bố cục.

10. **Hai nút:** WebView chỉ ở Scaffold.body trong SafeArea; hai nút vẫn ở
    Scaffold.bottomNavigationBar riêng. Native test kiểm tra view kết thúc trước
    nút, vị trí hai label không đổi sau 100 lượt, bấm cả hai mở đúng nội dung,
    quay về và tiếp tục xem cube. Khi mở màn con, active=false unmount toy view.

11. **Performance/lifecycle:** Reuse một BoxGeometry, một PlaneGeometry,
    một material body và sáu material màu. Không GLB/texture/realtime shadow/
    postprocessing. Pixel ratio cap 1.25. Chỉ RAF khi cần render hoặc đang quay
    layer; idle RAF=0. Native test xác nhận render count không tăng sau 400 ms idle.
    Khi rời màn/background, unmount; JS hủy RAF, bỏ listeners, dispose controls,
    geometry/material, renderLists, renderer/context và canvas; Flutter chuyển
    about:blank. Không giữ renderer nền khi ở solver/challenge. Quay lại mount
    solved cube mới. Không đo FPS/RAM release; kết quả idle và lifecycle được
    kiểm tra bằng snapshot JS và số platform view thực tế trong widget tree.

12. **Analyze/test:** `flutter analyze`: No issues found. `flutter test`: 141 pass.
    `node --test test/rubik_interactive_test.mjs test/rubik_render_test.cjs`:
    20 pass (15 test toy mới và 5 test renderer cũ). Gồm bốn quarter turn/inverse
    cho cả 9 layer, 100 move và 100 inverse, grid/orientation/màu, raycast các mặt
    từ nhiều góc, tap/cancel, một move mỗi swipe, pause giữa animation, idle và
    dispose idempotent. Renderer cũ vẫn pass facelet mapping/cube-state bridge.

13. **Máy thật:** OPPO CPH1969 Android 11. Bài cuối pass đủ 100 swipe native,
    nhanh/chậm xen kẽ, orbit sau mỗi 10 lượt, tap/drag nhỏ không quay, kiểm tra
    27 vị trí duy nhất đúng grid và 9 sticker mỗi màu sau từng move.
    Đã thực hiện đủ 9 layer và 16 tổ hợp axis/layer/chiều; tất cả 18 tổ hợp được
    kiểm tra trong JS tests. Không crash, WebView trắng, cubie lệch, mất màu,
    gesture kẹt hoặc nút bị che trong bài cuối. Mở cả hai màn con, trở về reset,
    rời Rubik/vào lại đều pass. Bài đầu dừng ở lượt 74 vì point sát seam không
    nhận; đã sửa hit-test khe và chạy lại toàn bộ 100 lượt, không bỏ qua failure.
    APK debug app thường được build/cài lại sau kiểm thử.

## Phạm vi và artifact

Không sửa renderer Rubik cũ, solver, scan, nhập màu, solution, challenge hoặc Gacha.
Thêm component, các asset toy, test JS/native, build script và tài liệu này.

- `artifacts/rubik-toy-analyze.txt`, `rubik-toy-flutter-tests.txt`, `rubik-toy-js-tests.txt`.
- `rubik-toy-device-smoke.txt`: 10 lượt đầu.
- `rubik-toy-device-100.txt`: lần stress phát hiện điểm sát seam.
- `rubik-toy-device-final.txt`: toàn bộ 100 lượt sau sửa hit-test.
- `rubik-toy-build.txt`: APK app thường.
- `rubik-toy-main-device.png`: màn Rubik chính trong app thường trên OPPO.
- `rubik-toy-main-moved-device.png`: sau vuốt thật trong app thường, hàng giữa
  đã đổi màu/vị trí trong khi camera và hai nút giữ nguyên.

```text
npm run build:rubik-toy
flutter analyze
flutter test
node --test test/rubik_interactive_test.mjs test/rubik_render_test.cjs
flutter test integration_test/rubik_interactive_device_test.dart -d 6TJRA6YTFUYL75KV
```

Đối chiếu API: [Raycaster](https://threejs.org/docs/pages/Raycaster.html),
[Object3D.attach](https://threejs.org/docs/pages/Object3D.html#attach),
[OrbitControls](https://threejs.org/docs/pages/OrbitControls.html).

## Bổ sung nền xanh biển và nút điều khiển

Nền Scaffold, WebView và scene dùng xanh biển nhạt `#DCEFFC`. Nút Thách đấu
dùng chữ và viền xanh để đọc rõ trên nền sáng. Hai nút nhỏ ở góc trên bên phải
là overlay Flutter: Hoàn tác quay ngược từng bước trong lịch sử; Đặt lại đưa
27 cubie về vị trí/hướng solved, xóa lịch sử và khôi phục camera ban đầu.
Orbit không được ghi vào lịch sử. Cả hai nút khóa trong lúc kéo/quay; Hoàn tác
khóa khi chưa có bước. Bridge gửi trạng thái sau mỗi thay đổi, không reload
WebView khi hoàn tác hoặc đặt lại. Native test kiểm tra hai lần hoàn tác bằng
snapshot từng bước, đặt lại cube/camera và trạng thái nút khi lịch sử rỗng.

Kiểm tra bổ sung: Flutter analyze sạch, 141 Flutter test và 20 JS test pass.
OPPO chạy đủ 100 lượt, hai lần hoàn tác, reset và chuyển màn/remount đều pass
(`artifacts/rubik-blue-device-pass.txt`). Bài native chờ cả lịch sử JS và trạng
thái nút Flutter để tránh đọc trước khi lệnh bridge thực thi; chờ transition
điều hướng kết thúc trước khi tìm nút Back.
