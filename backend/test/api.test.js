'use strict';
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { createServer } = require('../src/server');
const { Store } = require('../src/store');
const bartender = require('../src/bartender');

async function fixture(t) {
  let now = Date.now();
  const store = new Store(), server = createServer({ store, clock: () => now });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  t.after(() => new Promise(resolve => { server.closeAllConnections(); server.close(resolve); }));
  const base = `http://127.0.0.1:${server.address().port}`;
  async function request(method, route, body, token) {
    const response = await fetch(`${base}${route}`, { method,
      headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
      body: body === undefined ? undefined : JSON.stringify(body) });
    return { status: response.status, data: await response.json() };
  }
  const session = async name => (await request('POST', '/api/v1/sessions', { name })).data;
  return { request, session, store, base, advance: ms => { now += ms; } };
}

test('Swagger, schemas, validation and authentication are available over HTTP', async t => {
  const { request, base } = await fixture(t);
  assert.equal((await request('GET', '/api/v1/health')).status, 200);
  assert.equal((await request('POST', '/api/v1/sessions', { name: '' })).status, 400);
  assert.equal((await request('POST', '/api/v1/bartender/rooms')).status, 401);
  const spec = (await request('GET', '/openapi.json')).data;
  assert.equal(spec.openapi, '3.0.3');
  assert.ok(spec.components.schemas.BartenderRoom.properties.inbox);
  assert.ok(spec.paths['/api/v1/rubik/rooms/{code}/commands']);
  assert.match(await (await fetch(`${base}/docs`)).text(), /SwaggerUIBundle/);
  assert.equal((await fetch(`${base}/docs/swagger-ui-bundle.js`)).status, 200);
});

test('two clients create, join, process, submit atomically, reject replay/forgery, and finish on timeout', async t => {
  const { request, session, store, advance } = await fixture(t);
  const a = await session('A'), b = await session('B'), outsider = await session('C');
  const created = await request('POST', '/api/v1/bartender/rooms', {}, a.token);
  assert.equal(created.status, 201);
  const code = created.data.code, route = `/api/v1/bartender/rooms/${code}`;
  assert.equal((await request('GET', route, undefined, outsider.token)).status, 403);
  assert.equal((await request('POST', `${route}/start`, {}, a.token)).status, 409);
  assert.equal((await request('POST', `${route}/join`, {}, b.token)).status, 200);
  assert.equal((await request('POST', `${route}/start`, {}, a.token)).status, 200);
  const room = store.data.bartender[code];
  const [workerUid] = Object.entries(room.players).find(([, p]) => room.round.stationAssignment[p.ringIndex] === 'juicer');
  const worker = workerUid === a.uid ? a : b, other = worker === a ? b : a;
  const ring = room.players[worker.uid].ringIndex;
  const [orderId, order] = Object.entries(room.orders[worker.uid])[0];
  const itemId = 'test-item';
  room.inbox[ring][itemId] = { type: 'ingredient', itemId: order.recipeId === 'lemonade' ? 'lemon' : 'orange', fromRingIndex: ring };
  assert.equal((await request('POST', `${route}/process`, { itemId, station: 'juicer' }, other.token)).status, 404);
  assert.equal((await request('POST', `${route}/process`, { itemId, station: 'juicer' }, worker.token)).status, 200);
  const before = store.data.bartender[code].timer.endTime;
  const submit = () => request('POST', `${route}/submit`, { orderId, productId: itemId }, worker.token);
  const responses = await Promise.all([submit(), submit()]);
  assert.deepEqual(responses.map(r => r.status).sort(), [200, 409]);
  assert.equal(store.data.bartender[code].timer.endTime, before + 5000);
  assert.equal(store.data.bartender[code].players[worker.uid].completedOrders, 1);
  assert.equal(store.data.bartender[code].inbox[ring][itemId], undefined);
  assert.equal((await request('POST', `${route}/send`, { itemId: 'forged', toRingIndex: 1 - ring }, worker.token)).status, 404);
  assert.equal((await request('POST', `${route}/end`, {}, worker.token)).status, 409);
  advance(66000);
  const ended = await request('GET', route, undefined, worker.token);
  assert.equal(ended.data.room.status, 'ended');
  assert.equal(ended.data.room.results.totalTeamOrders, 1);
});

test('real HTTP rematch preserves room code and waits for every connected player', async t => {
  const { request, session, store } = await fixture(t);
  const host = await session('Host'), guest = await session('Guest');
  const created = await request('POST', '/api/v1/bartender/rooms', {}, host.token);
  const code = created.data.code, route = `/api/v1/bartender/rooms/${code}`;
  await request('POST', `${route}/join`, {}, guest.token);
  assert.equal((await request('POST', `${route}/start`, {}, guest.token)).status, 403);
  assert.equal((await request('POST', `${route}/start`, {}, host.token)).status, 200);
  // Advance only this fixture's authoritative timer; no persisted player data is used.
  store.data.bartender[code].timer.endTime = store.data.bartender[code].timer.startedAt - 1;
  const ended = await request('GET', route, undefined, host.token);
  assert.equal(ended.data.room.status, 'ended');
  assert.equal(ended.data.room.players[guest.uid].readyInLobby, false);
  assert.equal((await request('POST', `${route}/return`, {}, host.token)).status, 200);
  assert.equal((await request('POST', `${route}/start`, {}, host.token)).status, 409);
  await request('POST', `${route}/return`, {}, guest.token);
  const restarted = await request('POST', `${route}/start`, {}, host.token);
  assert.equal(restarted.status, 200);
  assert.equal(restarted.data.code, code);
  assert.equal(restarted.data.room.round.number, 1);
  assert.equal(restarted.data.room.results, undefined);
  assert.ok(Object.values(restarted.data.room.inbox).every(box => Object.keys(box).length === 1));
});

test('leaving host transfers the waiting-room seat without allowing guests to start', async t => {
  const { request, session } = await fixture(t);
  const host = await session('Host'), guest = await session('Guest'), third = await session('Third');
  const created = await request('POST', '/api/v1/bartender/rooms', {}, host.token);
  const route = `/api/v1/bartender/rooms/${created.data.code}`;
  await request('POST', `${route}/join`, {}, guest.token);
  await request('POST', `${route}/join`, {}, third.token);
  const left = await request('POST', `${route}/leave`, {}, host.token);
  assert.equal(left.data.room.players[guest.uid].ringIndex, 0);
  assert.equal((await request('POST', `${route}/start`, {}, third.token)).status, 403);
  assert.equal((await request('POST', `${route}/start`, {}, guest.token)).status, 200);
});

test('Rubik two-player ready, loaded, countdown, finish and rematch use backend time', async t => {
  const { request, session, advance } = await fixture(t);
  const a = await session('A'), b = await session('B');
  const created = await request('POST', '/api/v1/rubik/rooms', {}, a.token);
  assert.match(created.data.code, /^[A-Z2-9]{6}$/);
  const route = `/api/v1/rubik/rooms/${created.data.code}`;
  assert.equal((await request('POST', `${route}/join`, {}, b.token)).status, 200);
  const command = (who, action, round = 1) => request('POST', `${route}/commands`, { action, round }, who.token);
  await command(a, 'ready');
  assert.equal((await command(b, 'ready')).data.room.scramble.length, 20);
  await command(a, 'loaded');
  assert.equal((await command(b, 'loaded')).data.room.status, 'countdown');
  advance(5001);
  await command(a, 'finish'); advance(100);
  const result = await command(b, 'finish');
  assert.equal(result.data.room.status, 'finished');
  assert.equal(result.data.room.winnerId, a.uid);
  await command(a, 'rematch');
  assert.equal((await command(b, 'rematch')).data.room.round, 2);
  assert.equal((await command(a, 'ready', 1)).status, 409);
});

test('round generation stays feasible across player counts and rounds', () => {
  for (let n = 2; n <= 4; n++) for (let iteration = 0; iteration < 50; iteration++) {
    let room = bartender.create('0', 'A', 1000);
    for (let i = 1; i < n; i++) room = bartender.command(room, String(i), 'join', { name: String(i) }, 1000);
    room = bartender.command(room, '0', 'start', {}, 1000);
    for (let round = 1; round <= 5; round++) {
      const available = Object.values(room.round.stationAssignment);
      for (const orders of Object.values(room.orders)) for (const order of Object.values(orders)) {
        assert.ok(bartender.recipes.find(r => r.id === order.recipeId).stations.every(s => available.includes(s)));
      }
      Object.values(room.players).forEach(p => { room.round.progress[p.ringIndex] = 3; });
      bartender.settle(room, 1000);
      assert.equal(room.round.number, round + 1);
    }
  }
});

test('JSON store persists state across independent server instances', t => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'nhom-bar-api-'));
  t.after(() => fs.rmSync(directory, { recursive: true }));
  const file = path.join(directory, 'state.json');
  const first = new Store(file);
  first.data.bartender['1234'] = bartender.create('player', 'A', 1); first.save();
  assert.equal(new Store(file).data.bartender['1234'].players.player.name, 'A');
});
