'use strict';
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const envFile = path.join(__dirname, '../.env');
if (fs.existsSync(envFile)) process.loadEnvFile(envFile);
const { randomBytes, randomUUID, randomInt } = require('node:crypto');
const { Store } = require('./store');
const bartender = require('./bartender');
const rubik = require('./rubik');
const { requireThat } = bartender;
const openapi = require('./openapi');
const { accountRoute } = require('./accounts');

async function readBody(req) {
  let raw = '';
  for await (const chunk of req) {
    raw += chunk;
    requireThat(Buffer.byteLength(raw) <= 16384, 'Request quá lớn.', 413);
  }
  try {
    const body = raw ? JSON.parse(raw) : {};
    requireThat(body && typeof body === 'object' && !Array.isArray(body), 'Body phải là JSON object.', 400);
    return body;
  } catch (error) { throw Object.assign(error, { status: 400 }); }
}
function nameOf(body) {
  requireThat(typeof body.name === 'string' && body.name.trim().length > 0 && body.name.trim().length <= 24, 'Tên phải có 1–24 ký tự.', 400);
  return body.name.trim();
}
function createServer({ store = new Store(process.env.DATA_FILE || path.join(__dirname, '../data/state.json')), clock = Date.now } = {}) {
  const data = store.data;
  function maintain(now) {
    for (const [code, room] of Object.entries(data.bartender)) {
      for (const [uid, p] of Object.entries(room.players)) {
        const presence = data.presence[`bartender:${code}:${uid}`];
        if (presence && now - presence.at >= 30000) p.connected = false;
      }
      bartender.settle(room, now);
    }
    for (const [code, room] of Object.entries(data.rubik)) {
      const presence = {};
      for (const uid of Object.keys(room.players)) {
        const value = data.presence[`rubik:${code}:${uid}`];
        if (value) presence[uid] = now - value.at >= 30000 ? { online: false, at: value.at } : value;
      }
      rubik.settle(room, now, presence);
      if (['waiting', 'ready', 'countdown'].includes(room.status) && (!room.startAt || now < room.startAt)) {
        for (const [uid, p] of Object.entries(presence)) {
          if (!p.online && now - p.at >= 30000 && room.players[uid]) {
            data.rubik[code] = rubik.transition(data.rubik[code], uid, { action: 'leave', round: room.round }, now, presence);
            if (!data.rubik[code]) { delete data.rubik[code]; break; }
          }
        }
      }
    }
    for (const game of ['bartender', 'rubik']) {
      for (const [code, room] of Object.entries(data[game])) {
        if (now - room.createdAt > 86400000 || !Object.keys(room.players).length) delete data[game][code];
      }
    }
    for (const [token, session] of Object.entries(data.sessions)) if (now >= session.expiresAt) delete data.sessions[token];
    for (const [key, presence] of Object.entries(data.presence)) if (now - presence.at > 86400000) delete data.presence[key];
    store.save();
  }
  const timer = setInterval(() => maintain(clock()), 1000);
  timer.unref();
  const server = http.createServer(async (req, res) => {
    res.setHeader('Access-Control-Allow-Origin', process.env.CORS_ORIGIN || '*');
    res.setHeader('Access-Control-Allow-Headers', 'Authorization, Content-Type');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Cache-Control', 'no-store');
    const reply = (status, value) => { res.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8' }); res.end(JSON.stringify(value)); };
    try {
      if (req.method === 'OPTIONS') { res.writeHead(204); res.end(); return; }
      const url = new URL(req.url, 'http://localhost');
      const account = await accountRoute(req, url, readBody);
      if (account !== null) return reply(200, account);
      if (req.method === 'GET' && url.pathname === '/openapi.json') return reply(200, openapi);
      if (req.method === 'GET' && ['/', '/docs', '/docs/'].includes(url.pathname)) {
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        res.end('<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Nhóm Bar API</title><link rel="stylesheet" href="/docs/swagger-ui.css"></head><body><div id="swagger-ui"></div><script src="/docs/swagger-ui-bundle.js"></script><script>SwaggerUIBundle({url:"/openapi.json",dom_id:"#swagger-ui",persistAuthorization:false,validatorUrl:null,tryItOutEnabled:true,displayRequestDuration:true})</script></body></html>'); return;
      }
      if (req.method === 'GET' && ['/docs/swagger-ui.css', '/docs/swagger-ui-bundle.js'].includes(url.pathname)) {
        const file = path.join(require('swagger-ui-dist').absolutePath(), path.basename(url.pathname));
        res.writeHead(200, { 'Content-Type': file.endsWith('.css') ? 'text/css' : 'application/javascript' });
        fs.createReadStream(file).pipe(res); return;
      }
      if (req.method === 'GET' && url.pathname === '/api/v1/health') return reply(200, { status: 'ok', serverTime: clock(), storage: 'json-file' });
      if (req.method === 'POST' && url.pathname === '/api/v1/sessions') {
        const body = await readBody(req), name = nameOf(body), now = clock();
        const token = randomBytes(32).toString('hex');
        const session = { uid: randomUUID(), name, expiresAt: now + 86400000 };
        data.sessions[token] = session; store.save();
        return reply(201, { token, ...session, serverTime: now });
      }
      const token = (req.headers.authorization || '').replace(/^Bearer /, '');
      const session = data.sessions[token];
      requireThat(session && session.expiresAt > clock(), 'Cần Bearer token hợp lệ từ /sessions.', 401);
      const uid = session.uid;
      if (req.method === 'GET' && url.pathname === '/api/v1/bartender/recipes') return reply(200, { recipes: bartender.recipes });
      const match = url.pathname.match(/^\/api\/v1\/(bartender|rubik)\/rooms(?:\/([A-Z2-9]{6}|[0-9]{4}))?(?:\/([a-z]+))?$/);
      requireThat(match, 'Endpoint không tồn tại.', 404);
      const [, game, code, action] = match;
      const rooms = data[game];
      if (req.method === 'POST' && !code && !action) {
        await readBody(req);
        let newCode;
        do { newCode = game === 'bartender' ? String(randomInt(1000, 10000)) : Array.from({ length: 6 }, () => 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'[randomInt(32)]).join(''); } while (rooms[newCode]);
        rooms[newCode] = game === 'bartender' ? bartender.create(uid, session.name, clock()) :
          rubik.transition(null, uid, { action: 'create', id: randomUUID(), name: session.name }, clock());
        data.presence[`${game}:${newCode}:${uid}`] = { online: true, at: clock() }; store.save();
        return reply(201, { code: newCode, room: rooms[newCode], serverTime: clock() });
      }
      requireThat(code && rooms[code], 'Phòng không tồn tại.', 404);
      if (req.method === 'GET' && !action) {
        requireThat(rooms[code].players[uid], 'Bạn không thuộc phòng này.', 403);
        data.presence[`${game}:${code}:${uid}`] = { online: true, at: clock() };
        if (game === 'bartender') rooms[code].players[uid].connected = true;
        maintain(clock());
        return reply(200, { code, room: rooms[code] || null, serverTime: clock() });
      }
      requireThat(req.method === 'POST' && action, 'Phương thức không được hỗ trợ.', 405);
      const body = await readBody(req);
      if (action === 'presence') {
        requireThat(rooms[code].players[uid], 'Bạn không thuộc phòng này.', 403);
        requireThat(typeof body.online === 'boolean', 'online phải là boolean.', 400);
        data.presence[`${game}:${code}:${uid}`] = { online: body.online, at: clock() };
        if (game === 'bartender') rooms[code].players[uid].connected = body.online;
        maintain(clock());
      } else if (game === 'bartender') {
        requireThat(['join', 'leave', 'start', 'prepared', 'end', 'send', 'trash', 'process', 'submit', 'return'].includes(action), 'Thao tác không hợp lệ.', 400);
        rooms[code] = bartender.command(rooms[code], uid, action, { ...body, name: session.name }, clock());
      } else {
        requireThat(['join', 'commands'].includes(action), 'Thao tác không hợp lệ.', 400);
        if (action === 'commands') {
          requireThat(['ready', 'loaded', 'finish', 'leave', 'rematch', 'tick'].includes(body.action) && Number.isInteger(body.round), 'action hoặc round không hợp lệ.', 400);
        }
        rooms[code] = rubik.transition(rooms[code], uid, { ...body, action: action === 'join' ? 'join' : body.action, name: session.name }, clock());
        if (!rooms[code]) delete rooms[code];
      }
      if (action === 'join') data.presence[`${game}:${code}:${uid}`] = { online: true, at: clock() };
      store.save();
      return reply(200, { code, room: rooms[code] || null, serverTime: clock() });
    } catch (error) {
      const status = error.status || (error instanceof SyntaxError ? 400 : 409);
      reply(status, { error: { message: error.message } });
    }
  });
  server.on('close', () => clearInterval(timer));
  return server;
}
if (require.main === module) {
  const port = Number(process.env.PORT || 3000);
  createServer().listen(port, '0.0.0.0', () => console.log(`Nhóm Bar API: http://localhost:${port}/docs`));
}
module.exports = { createServer };
