# Nền tảng Rubik Solver

## Cấu trúc và luồng dữ liệu

Menu chính → Rubik 3D → nút hình lưới trên AppBar → Nhập màu thủ công.

```text
ManualInputScreen ──┐
                   ├─ CubeState → CubeValidationService → CubeSolver → List<RubikMove>
CubeScanner.scan ──┘                                                     ↓
                                                                  SolutionScreen
```

`CubeInputController` quản lý trạng thái nhập, reset, kiểm tra trước khi gọi
solver, trạng thái đang giải và lỗi. Widget chỉ hiển thị và gửi thao tác.
Adapter camera sau này gọi `scan()`, nếu kết quả khác null thì truyền vào
`controller.load(state)`. Kết quả scan vẫn phải qua validation; không tin dữ
liệu camera chỉ vì đã đủ 54 ô.

Project đã có `cuber`, nên giữ khả năng giải hiện tại qua `RubikSolverService`
và chạy tính toán trong isolate trên Android. Không thêm dependency. Có thể
thay solver bằng implementation khác của `CubeSolver`; controller nhận nó qua
constructor. Camera chưa được triển khai, nút quét hiển thị “sắp có”.

## Quy ước dữ liệu

`CubeState` sao chép dữ liệu đầu vào và giữ danh sách bất biến. Có đúng 6 mặt,
mỗi mặt 9 ô. `null` là ô chưa nhập, không phải màu thứ bảy. Reset xóa 48 ô ngoài
tâm. `withSticker` luôn trả state mới và từ chối sửa ô số 4 (tâm).
Constructor cho phép nhận tâm sai từ nguồn bên ngoài để validation báo lỗi.

| Mặt | Ký hiệu | Màu tâm | Mặt giáp cạnh trên khi nhìn thẳng |
| --- | --- | --- | --- |
| Up | U | Trắng | B |
| Right | R | Đỏ | U |
| Front | F | Xanh lá | U |
| Down | D | Vàng | F |
| Left | L | Cam | U |
| Back | B | Xanh dương | U |

Mỗi mặt nhìn từ bên ngoài, đánh số theo hàng: `0 1 2 / 3 4 5 / 6 7 8`.
Chuỗi adapter theo thứ tự **URFDLB**, không dựa vào thứ tự map đầu vào.
Camera phải chuẩn hóa chiều ảnh theo bảng, không tự đổi màu tâm.
Move dùng mặt và enum chiều xoay; `R`, `R'`, `R2` lần lượt là xoay thuận,
ngược và nửa vòng khi nhìn trực tiếp mặt R.

Validation chặn thiếu ô, số lượng màu khác 9, tâm sai; dùng `cuber.isOk` và
kiểm tra chuỗi chuyển đổi hai chiều để chặn cấu hình viên không hợp lệ,
lật cạnh, xoắn góc, sai parity. Cả controller và adapter solver kiểm tra đầu vào.

## Hiển thị 3D

`Rubik3DView` tải `assets/rubik/index.html`, trang này tải bundle `rubik.js`.
Sửa JavaScript trong `rubik-src.js`, sau đó chạy `npm run build:rubik`.
Mô hình 3D trên màn chính mặc định là cube đã giải. Trong manual input và
solution screen, `Rubik3DView(cubeState: ...)` đồng bộ màu từ state Flutter.
Solution screen hướng dẫn từng bước và hiển thị trạng thái sau mỗi bước.
Chưa có animation xoay từng tầng; chi tiết nằm ở phần live preview bên dưới.

Các vấn đề thấy trực tiếp trong code cũ:

- Giới hạn 30 FPS và nội suy rotation 0.25 khiến góc nhìn đuổi theo thao tác.
- Điều kiện render gồm trạng thái đang kéo/pinch nên giữ tay đứng yên vẫn render.
- Khoảng cách camera cố định không tính chiều hẹp của màn hình.
- Xóa cache WebView mỗi lần mở; solver cũ chạy đồng bộ trên UI isolate.

Đã bỏ giới hạn 30 FPS, cập nhật rotation ở frame kế tiếp, dừng vòng render khi
không còn thay đổi, dùng zoom trực tiếp khi pinch và nội suy theo thời gian cho
con lăn. Camera fit theo tỷ lệ màn hình, giữ mức zoom tương đối khi resize.
Flutter báo lifecycle cho JavaScript để dừng khi app vào nền và gỡ observer
khi dispose. Chưa có bằng chứng đo đạc về memory leak hoặc giảm FPS theo thời gian.

## Các file tạo/sửa

Đường dẫn Dart dưới `lib/games/rubik/`:

| File | Thay đổi |
| --- | --- |
| `models/rubik_face.dart` | Thay model gắn Flutter Color bằng enum mặt/màu và quy ước tâm |
| `models/cube_state.dart` | State bất biến, 54 ô, reset/solved, sửa ô, đếm và encoding |
| `models/rubik_move.dart` | Kiểu move và chuyển đổi ký hiệu chuẩn |
| `services/cube_validation_service.dart` | Validation độc lập với widget |
| `services/cube_scanner.dart` | Interface camera trả cùng CubeState |
| `services/rubik_solver_service.dart` | Interface solver và adapter cuber chạy isolate |
| `controllers/cube_input_controller.dart` | Quản lý input, reset, load, validation và async solve |
| `widgets/rubik_palette.dart` | Nhãn và màu Flutter, hướng nhìn từng mặt |
| `widgets/rubik_3d_view.dart` | Bỏ clearCache, quản lý lifecycle của trang 3D |
| `screens/manual_input_screen.dart` | Nhập/xóa màu, chọn mặt, khóa tâm, đếm, reset, chặn tiếp tục |
| `screens/rubik_screen.dart` | Nối luồng nhập màu từ AppBar |
| `screens/rubik_solver_screen.dart` | Vô hiệu hóa nút camera chưa triển khai |
| `screens/solution_screen.dart` | Nhận danh sách move có kiểu |

Các file khác:

| File | Thay đổi |
| --- | --- |
| `assets/rubik/rubik-src.js` | Sửa scheduler, drag/zoom, fit camera và lifecycle |
| `assets/rubik/rubik.js` | Bundle được build lại từ source |
| `package.json` | Thêm lệnh build bundle |
| `test/widget_test.dart` | Thay test counter cũ dùng sai tên MyApp bằng test menu thực tế |
| `test/cube_state_test.dart` | Test state, validation, controller, adapter và move |
| `test/manual_input_test.dart` | Test nhập/xóa màu, khóa tâm, reset, đổi mặt và màn hình nhỏ |
| `test/rubik_render_test.cjs` | Test scheduler/gesture với renderer giả lập, không đo GPU |
| `docs/rubik-foundation.md` | Tài liệu kiến trúc, quy ước và kiểm tra |

## Kiểm tra

```text
flutter analyze
flutter test
node --test test/rubik_render_test.cjs
npm run build:rubik
flutter build apk --debug --no-pub
```

Kết quả kiểm tra nền tảng ban đầu: `flutter analyze` không có issue; 11 test Flutter và 3 test
JavaScript đạt. Lần build Flutter trực tiếp bị chờ tải dependency HTTPS nên
đã dừng và build thành công từ cache bằng lệnh sau trong thư mục `android`:

```text
gradlew.bat --offline --console=plain -Ptarget-platform=android-arm64 assembleDebug
```

APK debug ARM64: `build/app/outputs/apk/debug/app-debug.apk`. Không dùng APK
ở đường dẫn khác từ lần build cũ. Gradle còn cảnh báo deprecation và phiên
bản SDK XML của môi trường, nhưng không chặn build này.

Cần kiểm tra trên điện thoại Android bằng profile mode: kéo một ngón, pinch
hai ngón, chuyển từ pinch sang kéo, xoay màn hình, vào nền/trở lại, mở/đóng
Rubik nhiều lần và theo dõi FPS/bộ nhớ sau 10–15 phút. Test JavaScript chỉ xác
nhận logic lập lịch, không bảo đảm tốc độ GPU/WebView.

Bước tiếp theo: kiểm tra trên thiết bị thật, sau đó nối animation xoay từng
tầng qua `CubeMoveAnimator`. Camera vẫn có thể triển khai sau theo cùng model.

## Kiểm tra orientation và UI nhập màu (bản cập nhật)

Đã trace `ManualInputScreen` → `CubeInputController.setSticker` → `CubeState`
→ `toFaceletDefinition` → `Cube.from` → `isOk`/round-trip → adapter `solve`.
Hàm chuyển duy nhất vẫn là `CubeState.toFaceletDefinition`; thứ tự URFDLB được
khai báo tường minh. `fromFaceletDefinition` là chiều ngược để import và test.

Đối chiếu trực tiếp source cuber 0.4.0 đang cài:

- `lib/src/facelet.dart`: sơ đồ net và chỉ số sticker theo hàng.
- `lib/src/cube.dart`: `_edgeFacelet` xác nhận U2–B2, D2–F8,
  U8–F2, U6–R2, U4–L2; `_cornerFacelet` xác nhận hướng trái/phải,
  ví dụ U9–R1–F3 và D3–F9–R7.
- `Cube.from`/`Cube.of`: đọc URFDLB rồi chuẩn hóa hướng toàn khối từ tâm.
  Việc này không thể tự sửa một mặt riêng bị người nhập xoay 90/180 độ.

Không tìm thấy lỗi hoán vị/mirror ở mapping cũ theo quy ước đã nêu. Test đã
xác nhận solved, cả 18 move đơn và chuỗi move, cùng fixture R độc lập.
Test xoay riêng mặt U của fixture R chứng minh: vẫn đủ mỗi màu 9 ô nhưng
trạng thái nhận được không hợp lệ. Đây là một nguyên nhân có thể gây hiện tượng
người dùng gặp; chưa có 54 ô lần nhập thực tế nên chưa kết luận trường hợp đó.
Không thêm xoay mặt ngầm và không bỏ `cube.isOk` để che lỗi nhập.

UI mới: Mặt 1/6 → tên màu → sơ đồ tĩnh và hướng dẫn tâm trước/tâm trên →
grid lớn → palette 6 màu có bộ đếm → Mặt trước/Mặt tiếp theo. Cho đi qua mặt
chưa hoàn thành, luôn giữ dữ liệu. Bấm Kiểm tra & Giải ở mặt cuối mới kiểm tra
và báo lỗi, không chuyển sang solver nếu sai. Tối đa 9 ô mỗi màu được chặn tại
controller. Xóa ô tách riêng, reset ở AppBar. Không đổi Three.js/WebView.

`CubeInputProblem` phân biệt thiếu ô, sai số lượng màu, tâm sai, cấu hình không
thể tồn tại. `cube_input_diagnostics.dart` ghi log debug khi bấm kiểm tra:
6 arrays, hướng trên, definition, số lượng từng ký hiệu, Cube.from,
isOk/isSolved, verify status và round-trip. Ô chưa nhập dùng `?` chỉ trong log;
không gửi definition chứa `?` vào cuber. Release không ghi log này.

### Trạng thái nhập tay để kiểm chứng

Bắt đầu cube solved, xoay mặt đỏ thuận chiều kim đồng hồ một lần khi nhìn
thẳng mặt đỏ. Nhập ba hàng **giống nhau** cho mỗi mặt như sau; nhìn mặt cần
nhập hướng về mình, giữ màu tâm phía trên đúng cột giữa:

| Mặt trước | Tâm phía trên | Mỗi hàng, lặp lại 3 hàng |
| --- | --- | --- |
| Trắng (U) | Xanh dương | Trắng · Trắng · Xanh lá |
| Đỏ (R) | Trắng | Đỏ · Đỏ · Đỏ |
| Xanh lá (F) | Trắng | Xanh lá · Xanh lá · Vàng |
| Vàng (D) | Xanh lá | Vàng · Vàng · Xanh dương |
| Cam (L) | Trắng | Cam · Cam · Cam |
| Xanh dương (B) | Trắng | Trắng · Xanh dương · Xanh dương |

Definition: `UUFUUFUUFRRRRRRRRRFFDFFDFFDDDBDDBDDBLLLLLLLLLUBBUBBUBB`.
Kỳ vọng: `isOk=true`, `isSolved=false`. Lời giải áp dụng lại phải về solved.

File thay đổi trong bản cập nhật: `models/rubik_face.dart` (hướng trên dùng
chung), `models/cube_state.dart` (chuyển đổi hai chiều),
`controllers/cube_input_controller.dart` (giới hạn màu, log khi kiểm tra),
`services/cube_validation_service.dart` (loại lỗi),
`services/cube_input_diagnostics.dart` (mới, log debug),
`screens/manual_input_screen.dart` (bố cục mới), `widgets/rubik_palette.dart`
(palette), `widgets/cube_orientation_hint.dart` (mới, minh họa tĩnh),
`test/manual_input_test.dart`, `test/cube_orientation_test.dart` (mới),
và tài liệu này. Các path Dart tương đối với `lib/games/rubik/`.

Kiểm tra bản cập nhật: `flutter analyze` sạch, `flutter test` đạt 18 test,
bao gồm nhập đủ 6 mặt → giải trên viewport 360×800 và bố cục ngang 640×320.
SHA-256 của `rubik-src.js`, `rubik.js`, `rubik_3d_view.dart` không đổi so với
trước bản cập nhật. Chưa đánh giá giao diện trực tiếp trên điện thoại thật.

## Live preview và hướng dẫn từng bước

Manual input giữ preview ở 38% chiều cao vùng nội dung; phần nhập cuộn riêng,
nút chuyển mặt nằm cố định phía dưới. Chuyển mặt và chọn màu không tạo WebView
mới. Cho phép kéo/pinch trong preview; cuộn ở vùng nhập màu.

Luồng dữ liệu:

```text
Tô/xóa/reset → CubeInputController → CubeState
  ├→ grid + bộ đếm
  ├→ Rubik3DView.didUpdateWidget → RubikPreviewBridge
  │    → runJavaScript(setCubeState(definition)) → đổi material → requestRender
  └→ validation → cuber solver → List<RubikMove> + initialState
       → SolutionController → tiến/lùi → CubeMoveService → CubeState → preview
```

### Mapping 3D

Flutter và JavaScript trao đổi **cùng một chuỗi URFDLB**, tạo bởi
`CubeState.toFaceletDefinition(allowIncomplete: true)`. `?` là ô xám, không
được đưa vào solver. Offset solver = thứ tự mặt × 9 + row × 3 + column.
Row/column bắt đầu từ 0, nhìn từ ngoài mặt đúng hướng tâm phía trên đã hướng dẫn.

`faceletLayout` trong `rubik-src.js` là nơi duy nhất chuyển chỉ số solver sang
tọa độ 3D. Trục: +x=R, +y=U, +z=F. Material của BoxGeometry: +x,−x,+y,−y,+z,−z.

| Mặt | x | y | z | Material slot |
| --- | --- | --- | --- | --- |
| U | c−1 | 1 | r−1 | 2 |
| R | 1 | 1−r | 1−c | 0 |
| F | c−1 | 1−r | 1 | 4 |
| D | c−1 | −1 | 1−r | 3 |
| L | −1 | 1−r | c−1 | 1 |
| B | 1−c | 1−r | −1 | 5 |

Test đối chiếu toàn bộ 8 góc + 12 cạnh với bảng facelet của cuber, gồm B và D;
54 slot là duy nhất. Không hoán đổi thứ tự sticker ở widget.

### Cập nhật và tài nguyên

Bridge đợi trang tải xong mới gửi state, giữ state mới nhất khi platform
channel đang bận, bỏ qua state trùng. Mỗi payload chỉ có 54 ký tự và được JSON
encode. JS giữ lại toàn bộ 27 mesh và các material dùng chung; chỉ đổi tham
chiếu material ở slot khác màu. Không mutate màu của material dùng chung.
48 ô chưa nhập có material xám riêng; 6 tâm lấy từ state. Reset gửi lại state rỗng.

Không reload trang, không rebuild scene, không tăng pixelRatio hoặc đổi renderer,
lighting, drag/pinch và scheduler hiện có. `requestRender` gộp nhiều cập nhật
trong một frame và dừng khi idle. Preview nhập tạm dừng khi mở màn lời giải;
preview lời giải tạm dừng khi mở chú thích. Observer/bridge được dispose.

Không auto-rotate mặt nhập ở bản này; người dùng kéo để xem, hướng dẫn tâm phía
trên vẫn hiển thị cạnh grid. Đây là lựa chọn giữ phạm vi thay đổi 3D nhỏ.

### Cách đọc hướng dẫn

Giữ tâm trắng trên, tâm xanh lá trước, tâm đỏ phải giữa các bước. Hướng quay
tính khi nhìn thẳng vào mặt đang xoay, kể cả B/D; chỉ xoay tầng được yêu cầu.
Mỗi bước hiển thị ký hiệu, tên mặt và câu hướng dẫn tiếng Việt. Chú thích U/R/F/D/L/B,
dấu nháy và số 2 nằm trong bottom sheet có thể cuộn.

Preview ban đầu là trạng thái đã nhập, trước bước 1. Bấm Bước tiếp áp dụng move
đang hiển thị và tăng số bước đã thực hiện. Bấm Bước trước áp dụng inverse và
giảm số bước; UI nêu inverse cần làm trên Rubik thật. Kết thúc vẫn cho lùi lại.

**Đã có cập nhật trạng thái 3D sau từng bước; chưa có animation xoay tầng.**
API `CubeMoveAnimator.animate(before, move, after)` đã chuẩn bị để triển khai
sau. Controller chờ animation hoàn tất rồi commit state và chặn bấm chồng.
Hiện mặc định không truyền animator nên chuyển ngay sang state đích.

### File thay đổi của bước live preview

Các path dưới `lib/games/rubik/`:

- `models/rubik_move.dart`: inverse cho 18 move.
- `helpers/rubik_move_helper.dart` (mới): tên mặt, mô tả tiếng Việt, describeMove.
- `services/rubik_preview_bridge.dart` (mới): hàng đợi state mới nhất và JS communication.
- `services/cube_move_service.dart` (mới): áp dụng move bằng cuber, interface animation.
- `controllers/solution_controller.dart` (mới): tiến/lùi, state, lỗi và khóa chuyển bước.
- `widgets/rubik_3d_view.dart`: nhận CubeState, đồng bộ sau khi ready và khi cập nhật.
- `widgets/rubik_preview_panel.dart` (mới): preview dùng chung, chú thích thao tác.
- `widgets/move_legend.dart` (mới): bảng chú thích cho người mới.
- `screens/manual_input_screen.dart`: chia vùng, live state và chuyển initialState sang guide.
- `screens/solution_screen.dart`: step-by-step và preview theo từng state.

Ngoài ra: `assets/rubik/rubik-src.js` (mapping + API màu), `assets/rubik/rubik.js`
(esbuild sinh lại), `test/manual_input_test.dart`, `test/rubik_render_test.cjs`,
`test/rubik_preview_bridge_test.dart` (mới), `test/solution_test.dart` (mới), tài liệu này.

Kiểm tra: analyze sạch; 22 test Flutter + 5 test JS đạt. Flutter widget test
dùng preview thay thế vì runner không cung cấp Android WebView; bridge được
test riêng bằng JS transport giả và JS bằng Three.js với renderer giả.
Cần thử trực tiếp trên Android để xác nhận platform-view gestures, độ trễ màu,
resize và hiệu năng khi chạy lâu. Build bundle bằng `npm run build:rubik`.

APK debug ARM64 của bản live preview đã build offline thành công (53 giây):
`build/app/outputs/apk/debug/app-debug.apk`.
