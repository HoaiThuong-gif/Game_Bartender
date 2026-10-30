'use strict';
const ref = name => ({ $ref: `#/components/schemas/${name}` });
const object = (properties, required = Object.keys(properties)) => ({ type: 'object', properties, required });
const str = { type: 'string' }, integer = { type: 'integer' }, boolean = { type: 'boolean' };
const dictionary = value => ({ type: 'object', additionalProperties: value });
const json = schema => ({ 'application/json': { schema } });
const schemas = {
  Error: object({ error: object({ message: str }) }),
  SessionRequest: object({ name: { type: 'string', minLength: 1, maxLength: 24, example: 'Thuong' } }),
  Session: object({ token: str, uid: str, name: str, expiresAt: integer, serverTime: integer }),
  Player: object({ name: str, ringIndex: integer, connected: boolean, completedOrders: integer, readyInLobby: boolean }, ['name', 'ringIndex', 'connected', 'completedOrders']),
  Item: object({ type: { type: 'string', enum: ['ingredient', 'product'] }, itemId: str, fromRingIndex: integer }),
  Order: object({ recipeId: str, status: { type: 'string', enum: ['pending', 'submitted'] } }),
  Recipe: object({ id: str, productId: str, difficulty: integer, stations: { type: 'array', items: str } }),
  BartenderRoom: object({
    status: { type: 'string', enum: ['lobby', 'playing', 'ended'] }, createdAt: integer,
    players: dictionary(ref('Player')), inbox: dictionary(dictionary(ref('Item'))),
    timer: object({ startedAt: integer, endTime: integer, preparing:boolean, readyPlayers:dictionary(boolean) }, ['startedAt','endTime']),
    round: object({ number: integer, ordersPerPlayer: integer, stationAssignment: dictionary({ type: 'string', nullable: true }), progress: dictionary(integer) }),
    orders: dictionary(dictionary(ref('Order'))),
    results: object({ totalSurvivalSeconds: integer, totalTeamOrders: integer, ranking: { type: 'array', items: { allOf: [ref('Player'), object({ playerId: str })] } } }),
  }, ['status', 'createdAt', 'players', 'inbox']),
  RubikPlayer: object({ name: str, ready: boolean, loaded: boolean, finished: boolean, dnf: boolean, rematch: boolean, left: boolean, finishAt: { ...integer, nullable:true }, finishMs: { ...integer, nullable:true } }, ['name', 'ready', 'loaded', 'finished', 'dnf', 'rematch', 'left']),
  RubikRoom: object({ hostId: str, creationId: str, createdAt: integer, updatedAt: integer, round: integer,
    status: { type: 'string', enum: ['waiting', 'ready', 'countdown', 'playing', 'finished'] },
    players: dictionary(ref('RubikPlayer')), scramble: { type: 'array', items: str }, startAt: { ...integer, nullable:true }, winnerId: { ...str, nullable:true }, endedAt: integer,
  }, ['hostId', 'createdAt', 'updatedAt', 'round', 'status', 'players']),
  Health: object({ status: str, serverTime: integer, storage: str }),
  Profile: object({ uid: { ...str, readOnly: true }, gameId: { ...str, readOnly: true },
    displayName: { ...str, description: 'Có thể trùng tên; không phải khóa đăng nhập' }, email: str, photoURL: str,
    createdAt: { readOnly:true, description:'Ngày tạo đã có trong hồ sơ, giữ nguyên định dạng dữ liệu cũ', oneOf:[{type:'string',format:'date-time'},{type:'object'},{type:'integer'}] },
    schemaVersion: { ...integer, readOnly:true },
  }, ['uid', 'gameId', 'displayName']),
  Challenge: object({ challengeId: str, email: { ...str, description: 'Email đã che một phần' },
    expiresAt: { ...integer, description: 'Unix milliseconds; hết hạn sau 10 phút' }, retryAt: integer }),
  Verification: object({ customToken: { ...str, description: 'Chỉ dùng với Firebase signInWithCustomToken; không ghi log/chia sẻ' },
    grant: { ...str, description: 'Khóa bí mật chỉ lưu trong Keystore khi bật sinh trắc học' }, expiresAt: integer }),
};
for (const game of ['Bartender', 'Rubik']) schemas[`${game}Response`] = object({ code: str, room: { ...schemas[`${game}Room`], nullable: true }, serverTime: integer });
const paths = {};
function route(path, method, summary, tag, response, body, publicRoute = false, created = false) {
  const errorCodes = tag === 'System' ? [] : tag === 'Session' ? [400, 413]
    : tag === 'Account' ? [400, 401, 403, 405, 409, 413, 429, 503]
      : [400, 401, 403, 404, 405, 409, 413];
  const errorDescriptions = {
    400: 'Dữ liệu không hợp lệ', 401: 'Thiếu/hết hạn xác thực', 403: 'Không có quyền',
    404: 'Không tìm thấy', 405: 'Phương thức không hỗ trợ', 409: 'Trạng thái chưa phù hợp',
    413: 'Request vượt giới hạn', 429: 'Đã vượt giới hạn; đợi rồi thử lại',
    503: 'Dịch vụ tài khoản chưa cấu hình hoặc tạm gián đoạn',
  };
  const operation = {
    tags: [tag], summary, operationId: `${method}_${path.replace(/[^a-zA-Z0-9]+/g, '_')}`,
    responses: { [created ? '201' : '200']: { description: 'Thành công', content: json(response) },
      ...Object.fromEntries(errorCodes.map(status => [status, { description: errorDescriptions[status], content: json(ref('Error')) }])) },
  };
  if (publicRoute) operation.security = [];
  if (path.includes('{code}')) operation.parameters = [{ name: 'code', in: 'path', required: true, schema: { type: 'string', pattern: tag === 'Bartender' ? '^[0-9]{4}$' : '^[A-Z2-9]{6}$' }, description: 'Mã nhận được từ API tạo phòng' }];
  if (body) operation.requestBody = { required: true, content: json(body) };
  (paths[path] ||= {})[method] = operation;
}
route('/api/v1/health', 'get', 'Kiểm tra backend và giờ máy chủ', 'System', ref('Health'), null, true);
route('/api/v1/sessions', 'post', 'Tạo phiên người chơi ẩn danh (hạn 24 giờ)', 'Session', ref('Session'), ref('SessionRequest'), true, true);
route('/api/v1/bartender/recipes', 'get', 'Danh sách công thức và trạm cần dùng', 'Bartender', object({ recipes: { type: 'array', items: ref('Recipe') } }));
for (const [game, tag] of [['bartender', 'Bartender'], ['rubik', 'Rubik']]) {
  const base = `/api/v1/${game}/rooms`, response = ref(`${tag}Response`);
  route(base, 'post', 'Tạo phòng với tên trong phiên hiện tại', tag, response, null, false, true);
  route(`${base}/{code}`, 'get', 'Lấy trạng thái phòng và gửi heartbeat (poll 1 giây)', tag, response);
  route(`${base}/{code}/join`, 'post', 'Tham gia phòng đang chờ', tag, response);
  route(`${base}/{code}/presence`, 'post', 'Cập nhật trạng thái kết nối', tag, response, object({ online: { type: 'boolean', example: true } }));
}
for (const [action, summary, body] of [
  ['start', 'Bắt đầu trận khi có ít nhất hai người', object({ waitForScene: { type:'boolean', default:false } }, [])],
  ['prepared', 'Báo cảnh 3D đã tải để đồng bộ đếm ngược giữa các máy', object({ preparationId:integer })],
  ['return', 'Quay lại phòng sau trận; chủ phòng chờ mọi người sẵn sàng rồi chơi lại', null],
  ['leave', 'Rời phòng hiện tại', null],
  ['end', 'Kết thúc khi hết giờ hoặc thiếu người', null],
  ['send', 'Chuyền vật phẩm có thật cho người liền kề', object({ itemId: str, toRingIndex: integer })],
  ['trash', 'Bỏ vật phẩm khỏi khay của mình', object({ itemId: str })],
  ['process', 'Chế biến tại trạm được phân', object({ itemId: str, station: { type: 'string', enum: ['juicer', 'cuttingBoard', 'blender', 'shaker'] } })],
  ['submit', 'Nộp sản phẩm đúng đơn; cộng điểm và 5 giây', object({ orderId: str, productId: { type: 'string', description: 'Key UUID của vật phẩm trong inbox, không phải tên công thức' } })],
]) route(`/api/v1/bartender/rooms/{code}/${action}`, 'post', summary, 'Bartender', ref('BartenderResponse'), body);
route('/api/v1/rubik/rooms/{code}/commands', 'post', 'Gửi thao tác của lượt Rubik hiện tại', 'Rubik', ref('RubikResponse'), object({ action: { type: 'string', enum: ['ready', 'loaded', 'finish', 'leave', 'rematch', 'tick'], example: 'ready' }, round: { type: 'integer', minimum: 1, example: 1 } }));
for (const [action, method, summary, response, body] of [
  ['challenge', 'post', 'Gửi OTP qua email Firebase của chính tài khoản (5 lần/giờ, cách 60 giây)', ref('Challenge'), object({})],
  ['verify', 'post', 'Kiểm tra OTP (tối đa 5 lần), cấp phiên Firebase và Game ID', ref('Verification'), object({ challengeId: str, code: { type:'string',pattern:'^[0-9]{6}$',description:'Mã thật trong email, không có mã mặc định' } })],
  ['session', 'get', 'Kiểm tra phiên OTP và đọc hồ sơ của chính UID', ref('Profile'), null],
  ['cancel', 'post', 'Hủy mã OTP đang chờ của chính tài khoản', object({ ok: boolean }), object({ challengeId: str })],
  ['logout', 'post', 'Thu hồi phiên hiện tại, không xóa hồ sơ', object({ ok: boolean }), object({})],
  ['resume', 'post', 'Đổi khóa Keystore còn hạn thành Firebase custom token', object({ customToken: str }), object({ grant: { ...str,minLength:64,maxLength:64 } })],
]) {
  const path = `/api/v1/account/${action}`;
  route(path,method,summary,'Account',response,body,action==='resume');
  paths[path][method].security = action==='resume' ? [] : [{firebaseAuth:[]}];
  paths[path][method].description = action==='resume'
    ? 'Không dùng token demo; cần khóa bí mật được cấp sau OTP và được HĐH giải mã từ Keystore.'
    : 'Dùng Firebase ID token của chính tài khoản sau đăng nhập Email/Google trong Flutter. Token /sessions là phiên game, không dùng được tại đây. Không nhập API key Brevo hoặc khóa Admin. Lỗi 503 nghĩa là dịch vụ chưa sẵn sàng, không có dữ liệu giả thay thế.';
}
module.exports = {
  openapi: '3.0.3', info: { title: 'Nhóm Bar API', version: '1.0.0',
    description: 'Backend độc lập của Flutter. Tạo session, copy token vào Authorize, rồi tạo/vào phòng. Dùng trình duyệt khác hoặc token khác để giả lập người thứ hai. GET phòng mỗi giây giữ kết nối; sau 30 giây không heartbeat sẽ mất kết nối. Trạng thái lưu ở backend/data/state.json; chỉ chạy một tiến trình server. Rubik finish là khai báo của client, chưa xác minh trạng thái cube.' },
  servers: [{ url: '/', description: 'Máy chủ đang mở Swagger' }],
  security: [{ bearerAuth: [] }], tags: ['System', 'Session', 'Account', 'Bartender', 'Rubik'].map(name => ({ name })),
  paths, components: { securitySchemes: {
    bearerAuth: { type: 'http', scheme: 'bearer', description: 'Phiên game giới hạn quyền từ POST /api/v1/sessions' },
    firebaseAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT', description: 'Firebase ID token, không phải Admin key/custom token/game token' },
  }, schemas },
};
