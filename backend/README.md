# Nhóm Bar backend

Backend Node.js độc lập, API HTTP JSON cho Flutter ở thư mục `../nhombar/`. Không cần
Flutter, Firebase, json-server hay Cloud Functions để chạy server này.
Yêu cầu Node.js 22 trở lên.

```powershell
cd backend
npm ci
npm start
```

- Swagger UI: http://localhost:3000/docs
- OpenAPI: http://localhost:3000/openapi.json
- Health: http://localhost:3000/api/v1/health
- Kiểm thử: `npm test`

Swagger UI phục vụ từ dependency cục bộ `swagger-ui-dist`, không tải CDN lúc mở
trang, theo [hướng dẫn Swagger UI](https://swagger.io/docs/open-source-tools/swagger-ui/usage/installation/).

## Cấu trúc

```text
src/server.js      HTTP routes, xác thực, heartbeat, vòng cập nhật định kỳ
src/bartender.js   Luật Bartender, phân trạm, chế biến, đơn hàng, kết quả
src/rubik.js       Máy trạng thái Rubik (từ nền tảng functions cũ)
src/store.js       Lưu toàn bộ trạng thái qua file tạm + rename
src/openapi.js     Hợp đồng API, schema request/response, Swagger
test/api.test.js   Kiểm thử HTTP, nhiều người, luật chơi, lưu dữ liệu
data/state.json   Dữ liệu runtime tự tạo, không commit
tools/            Server quét 3D Python, công cụ kết nối và kiểm thử
vision/           API nhận diện ảnh YOLO, môi trường Python riêng
bartender_ws/     Module Dart HTTP/WebSocket gốc của Zhoufen, không phải API mặc định
firebase/         Cloud Functions và cấu hình Firebase cũ (không cần cho REST API)
```

Hướng dẫn quét 3D: [tools/SCAN_CONNECTIONS.md](tools/SCAN_CONNECTIONS.md).
Chạy từ folder lớn: `.\backend\tools\start-scan-server.ps1` hoặc mở
`backend/Mo-may-quet.cmd`. Runtime Python và khóa ghép nối giữ trong
`backend/.scan-runtime/`; dữ liệu phiên quét nằm ở `backend/build/scan-jobs/`.

## Thử API trên Swagger

1. `POST /api/v1/sessions` với `{"name":"Thuong"}`.
2. Copy `token` trong response → **Authorize** → dán token (không thêm `Bearer`).
3. `POST /api/v1/bartender/rooms` → copy `code`.
4. Tạo session thứ hai, Authorize bằng token mới → `.../rooms/{code}/join`.
5. `.../start` → `GET .../rooms/{code}` xem players, stations, orders, inbox.
6. Dùng key vật phẩm trong inbox làm `itemId` cho process/send/trash. Nộp đơn
   dùng `orderId` và `productId` là **key vật phẩm**, không phải tên món.
7. Rubik tương tự: tạo/vào phòng rồi `commands` với action `ready`, `loaded`,
   `finish`, `rematch`, `leave`, `tick` và `round` hiện tại.

`GET` phòng mỗi giây vừa lấy dữ liệu vừa giữ kết nối. Khi thử bằng Swagger,
gọi GET với từng token trong vòng 30 giây hoặc mở hai app để giữ heartbeat.
Swagger không tự polling. Bartender cần 2–4 người; Rubik cần 2 người.
Backend không tự thêm bot vào phòng online.

## Module Dart HTTP/WebSocket tùy chọn

Mã nguồn trước đây ở `server/` nằm trong `backend/bartender_ws/`. Module này
giữ hợp đồng `/rooms` và WebSocket của Zhoufen, trong khi app mặc định dùng
Node.js `/api/v1`. Không chạy hai server cho cùng một phòng; chúng không dùng
chung dữ liệu. Firebase Authentication/hồ sơ của app vẫn được cấu hình riêng.
Module dùng chung các model Dart thuần tại `nhombar/lib/games/bartender/models/`;
không sao chép một bộ model thứ hai hoặc yêu cầu Flutter để chạy server Dart.

Nếu cần phát triển hoặc kiểm tra riêng module Dart, tại thư mục gốc chạy:

```powershell
cd backend/bartender_ws
dart pub get
dart test
dart run bin/server.dart
```

Health của module là http://127.0.0.1:8080/health. Lệnh chạy trên dùng dữ liệu
trong bộ nhớ, khác kho JSON của Node.js; không thay đổi `API_BASE_URL` của app
nếu chưa dùng đúng adapter `ZhoufenApiRoomRepository`.

Docker build dùng context là thư mục gốc dự án, vì module dùng chung model Dart
với frontend: `docker build -f backend/bartender_ws/Dockerfile .`.

## Cấu hình và giới hạn

Đặt biến môi trường trước `npm start` trong PowerShell:

```powershell
$env:PORT='3000'
$env:DATA_FILE='D:\data\state.json'
$env:CORS_ORIGIN='https://your-frontend.example'
```

Mặc định lắng nghe `0.0.0.0:3000`, lưu `backend/data/state.json`. Phiên ẩn danh
hết hạn sau 24 giờ; mở lại game để tạo phiên mới. Phòng cũ hơn 24 giờ được dọn.
Không có đăng ký/tài khoản hoặc lịch sử trận lâu dài.

File JSON là kho lưu trữ demo, **không phải hệ quản trị CSDL**. Chạy một process
trên file này, không dùng cluster/nhiều replica. Token lưu cùng file nên không
commit hoặc chia sẻ file dữ liệu. Khi triển khai thật cần CSDL giao dịch, HTTPS,
quản lý phiên/rate limit. Rubik còn tin thao tác `finish` từ client như nền tảng
cũ, chưa xác minh cube trên server.

Server sinh nguyên liệu mỗi 3 giây (tối đa 12 vật phẩm/khay), dùng giờ server
để hết trận/chuyển vòng. Sau 30 giây không heartbeat đánh dấu mất kết nối.
Các cập nhật chạy đồng bộ trong một process để không cộng trùng đơn/giờ.

## English

Run `npm ci` and `npm start` with Node.js 22+. Swagger is at `/docs`; the OpenAPI
contract is at `/openapi.json`. Create an anonymous session, authorize its Bearer
token, then create/join a room. Poll every second for state and presence. The
backend owns Bartender transitions and persists a JSON snapshot locally. This
single-process demo store can later be replaced behind the same HTTP API.
