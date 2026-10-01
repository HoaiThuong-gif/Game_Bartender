# Lobby dùng asset cập nhật

Đã đọc lại trực tiếp cả 5 PNG, đo alpha và căn lại theo nội dung hiện tại.
Không sửa PNG, không crop/merge ảnh, không dùng các bản `*-cutout.png` cũ.
`pubspec.yaml` đã khai báo `assets/images/lobby/`, không cần sửa.

## Kích thước và padding thực tế

Content rect dưới đây đo bằng alpha > 40/255, theo dạng (left, top, width, height).
Padding ghi theo thứ tự trái / trên / phải / dưới, đơn vị pixel ảnh nguồn.

| PNG | Kích thước | Content rect | Padding |
| --- | --- | --- | --- |
| background.png | 941 × 1672 | (0, 0, 941, 1672) | 0 / 0 / 0 / 0 |
| bartender.png | 1448 × 1086 | (62, 24, 1365, 1047) | 62 / 24 / 21 / 15 |
| games.png | 1303 × 1207 | (94, 14, 1182, 1183) | 94 / 14 / 27 / 10 |
| rubik.png | 1312 × 1199 | (139, 68, 1034, 1099) | 139 / 68 / 139 / 32 |
| flag.png | 1448 × 1086 | (58, 37, 1374, 1019) | 58 / 37 / 16 / 30 |

Cả 4 object đều có alpha thật và khoảng trong suốt quanh silhouette. Rubik có
padding hai bên lớn nhất; máy arcade có lề trái đáng kể. Cờ còn có vùng trống
lớn trong bounding box do cán cờ chéo. Không lấy mép PNG làm điểm tiếp xúc.

## Hệ tọa độ và anchor

Scene design size bằng background: **941 × 1672**.
`FittedBox(BoxFit.cover)` scale cả Stack với:

`sceneScale = max(viewportWidth / 941, viewportHeight / 1672)`.

Offset toàn scene được căn giữa. Cover có thể cắt các mép cảnh nhưng không làm
méo hoặc tạo khoảng trắng. Không còn clamp vị trí riêng từng object theo màn
hình: clamp cũ có thể kéo Rubik khỏi bàn hoặc arcade khỏi điểm chân trên sàn.
Mọi object giữ nguyên quan hệ với background ở các tỷ lệ màn hình.

Toàn bộ cấu hình nằm trong `lib/screens/home/lobby_layout.dart`:
`asset`, `imageSize`, `contentRect`, `x`, `y`, `width`, `scale`, `anchor`.
`width` là chiều rộng nội dung nhìn thấy, không bao gồm padding PNG.

| Object | Điểm tiếp xúc x / y | Content width | Anchor trong content rect | Vị trí |
| --- | --- | --- | --- | --- |
| Bartender | 200 / 1218 | 740 | (0.5, 1) | Tiền cảnh trái; nhóm chân trước chạm sân |
| Arcade | 720 / 1000 | 240 | (0.5, 1) | Sát khu tường phải, xa hơn quầy |
| Rubik | 790 / 1302 | 86 | (0.5, 1) | Đáy nằm trong mặt bàn đỏ phía trước |
| Flag | 655 / 455 | 250 | (46/1374, 863/1019) | Điểm bắt cán vào tường, pixel nguồn (104, 900) |

Với mỗi object:

- `imageScale = width * scale / contentRect.width`.
- `sourceAnchor = contentRect.topLeft + contentRect.size * anchor`.
- `imageRect.topLeft = (x, y) - sourceAnchor * imageScale`.
- Kích thước render = `imageSize * imageScale`.

Nhờ vậy padding vẫn được render đúng, ảnh giữ tỷ lệ, và khi đổi `scale` điểm
chân giữ nguyên. `visualRect` mô tả nội dung thật; `imageRect` mô tả cả PNG.
Anchor đáy giữa của quầy/máy là baseline cho cả nhóm đồ vật có nhiều chân với
độ sâu khác nhau; không ép tất cả chân đứng cùng một đường ngang.

Quầy gần camera có kích thước lớn hơn arcade ở sâu trong cảnh. Rubik nhỏ hơn,
được đặt trên vùng mặt bàn chứ không tại cạnh trước/chân bàn. Cấu hình là căn
thủ công theo mặt sàn/mặt bàn nhìn thấy trong asset, không phải phục dựng 3D.
Không cần offset bất thường hoặc sửa nội dung PNG để đạt bố cục hiện tại.

## Hitbox, feedback và navigation

`LobbyObject` đo mask alpha riêng cho PNG hiện tại, decode một lần và cache
mask 192 pixel chiều rộng. Hitbox loại padding và lỗ trong suốt, chỉ nhận pixel
alpha > 40/255; ngưỡng này cũng dùng để đo content rect. Biên hitbox xấp xỉ ở
độ phân giải mask, không phải một button phủ khu vực cảnh.

Feedback nhấn scale xuống 0.96 trong 90 ms quanh chính anchor tiếp xúc, tránh
nhấc chân khỏi sàn. Cờ xoay rất nhẹ quanh điểm gắn tường, có controller riêng,
`RepaintBoundary`, `IgnorePointer`, dispose đầy đủ và hỗ trợ tắt animation.

- Rubik → `lib/games/rubik/screens/rubik_screen.dart`, qua `MaterialPageRoute`.
- Bartender → `onBartenderTap`; chưa có game, mặc định snackbar đang phát triển.
- Arcade → `onArcadeTap`; chưa có game, mặc định snackbar đang phát triển.
- Flag → trang trí, không nhận tap.

Layer order: background → arcade phía sau → quầy tiền cảnh → Rubik trên bàn
→ cờ. Không thêm card, chữ hoặc icon menu che cảnh.

## File thay đổi và kiểm tra

Sửa `lobby_layout.dart`, `lobby_screen.dart`, `widgets/lobby_object.dart`,
`widgets/animated_flag.dart`, `test/widget_test.dart` và tài liệu này.
Không tạo file code mới. Ảnh kiểm tra được tạo ở `build/lobby-preview/`.

Widget tests kiểm tra tọa độ tiếp xúc ở 360×640, 390×844, 430×932, 768×1024,
không trôi theo viewport; loại vùng trong suốt; giữ điểm chân khi nhấn; cờ không
nhận tap; callback placeholder và route Rubik hiện có. PNG render từng kích
thước được lưu tại `build/lobby-preview/<width>x<height>.png`.

Kết quả: `flutter analyze` không có issue; toàn bộ 34 test đạt. Đã build,
cài và chạy app portrait trên CPH1969 / Android 11; đã xem ảnh chụp thực tế
`build/lobby-preview/android.png`, cùng các ảnh render phone/tablet.
