'use strict';
const { randomInt, randomUUID } = require('node:crypto');
const recipes = [
  { id: 'orange_juice', productId: 'orange_juice', difficulty: 1, stations: ['juicer'] },
  { id: 'lemonade', productId: 'lemon_juice', difficulty: 1, stations: ['juicer'] },
  { id: 'strawberry_smoothie', productId: 'strawberry_smoothie', difficulty: 2, stations: ['cuttingBoard', 'blender'] },
  { id: 'citrus_cocktail', productId: 'citrus_cocktail', difficulty: 3, stations: ['juicer', 'shaker'] },
  { id: 'strawberry_lemonade', productId: 'strawberry_lemonade', difficulty: 3, stations: ['juicer', 'blender', 'shaker'] },
];
const processing = {
  juicer: { orange: 'orange_juice', lemon: 'lemon_juice' },
  cuttingBoard: { strawberry: 'cut_strawberry' },
  blender: { cut_strawberry: 'strawberry_smoothie', lemon_juice: 'strawberry_lemonade_blend' },
  shaker: { orange_juice: 'citrus_cocktail', lemon_juice: 'citrus_cocktail', strawberry_lemonade_blend: 'strawberry_lemonade' },
};
function requireThat(condition, message, status = 409) {
  if (!condition) throw Object.assign(new Error(message), { status });
}
const pick = values => values[randomInt(values.length)];
function spawn(room) {
  for (const p of Object.values(room.players).filter(p => p.connected)) {
    const box = room.inbox[p.ringIndex] ||= {};
    if (Object.keys(box).length < 12) box[randomUUID()] = {
      type: 'ingredient', itemId: pick(['orange', 'lemon', 'strawberry', 'ice']), fromRingIndex: p.ringIndex,
    };
  }
}
function roundSetup(room, number) {
  const players = Object.entries(room.players).filter(([, p]) => p.connected)
    .sort((a, b) => a[1].ringIndex - b[1].ringIndex);
  const inbox = {};
  players.forEach(([, p], index) => { inbox[index] = room.inbox[p.ringIndex] || {}; p.ringIndex = index; });
  room.players = Object.fromEntries(players); room.inbox = inbox;
  const pool = recipes.filter(r => r.difficulty <= Math.min(number, 3));
  const anchor = pick(pool.filter(r => r.stations.length <= players.length));
  const rings = players.map((_, i) => i);
  // Fisher-Yates: anchor stations go to different, randomly chosen players.
  for (let i = rings.length - 1; i > 0; i--) { const j = randomInt(i + 1); [rings[i], rings[j]] = [rings[j], rings[i]]; }
  const assignment = Object.fromEntries(rings.map(r => [r, pick([null, ...Object.keys(processing)])]));
  anchor.stations.forEach((station, i) => { assignment[rings[i]] = station; });
  const feasible = pool.filter(r => r.stations.every(s => Object.values(assignment).includes(s)));
  room.round = { number, ordersPerPlayer: 3, stationAssignment: assignment, progress: {} };
  room.orders = {};
  for (const [uid, p] of players) {
    room.round.progress[p.ringIndex] = 0;
    room.orders[uid] = Object.fromEntries(Array.from({ length: 3 }, () => [randomUUID(), { recipeId: pick(feasible).id, status: 'pending' }]));
  }
  spawn(room);
}
function end(room, now) {
  if (room.status !== 'playing') return;
  room.status = 'ended'; room.endedAt = now;
  for (const player of Object.values(room.players)) player.readyInLobby = false;
  const ranking = Object.entries(room.players).map(([playerId, p]) => ({ playerId, ...p }))
    .sort((a, b) => b.completedOrders - a.completedOrders);
  room.results = {
    totalSurvivalSeconds: Math.max(0, Math.round((Math.min(now, room.timer.endTime) - room.timer.startedAt) / 1000)),
    totalTeamOrders: ranking.reduce((sum, p) => sum + p.completedOrders, 0), ranking,
  };
}
function settle(room, now) {
  if (room.status !== 'playing') return;
  const active = Object.values(room.players).filter(p => p.connected);
  if (now >= room.timer.endTime || active.length < 2) return end(room, now);
  if (active.every(p => room.round.progress[p.ringIndex] >= 3)) roundSetup(room, room.round.number + 1);
  if (now - room.lastSpawnAt >= 3000) { spawn(room); room.lastSpawnAt = now; }
}
function create(uid, name, now) {
  return { status: 'lobby', createdAt: now, players: { [uid]: { name, ringIndex: 0, connected: true, completedOrders: 0 } }, inbox: {} };
}
function command(original, uid, action, body, now) {
  const room = structuredClone(original);
  settle(room, now);
  if (action === 'join') {
    requireThat(room.status === 'lobby', 'Phòng đã bắt đầu hoặc kết thúc.');
    requireThat(room.players[uid] || Object.keys(room.players).length < 4, 'Phòng đã đầy.');
    const ring = Math.max(-1, ...Object.values(room.players).map(p => p.ringIndex)) + 1;
    room.players[uid] ||= { name: body.name, ringIndex: ring, connected: true, completedOrders: 0 };
    room.players[uid].connected = true;
    return room;
  }
  const p = room.players[uid];
  requireThat(p, 'Bạn không thuộc phòng này.', 403);
  if (action === 'leave') {
    if (room.status === 'lobby') delete room.players[uid]; else p.connected = false;
    if (room.status !== 'playing') {
      Object.values(room.players)
        .sort((a, b) => Number(b.connected) - Number(a.connected) || a.ringIndex - b.ringIndex)
        .forEach((player, index) => { player.ringIndex = index; });
    }
    settle(room, now); return room;
  }
  if (action === 'return') {
    requireThat(room.status === 'ended', 'Trận chưa kết thúc.');
    requireThat(p.connected, 'Bạn đã rời phòng.', 403);
    p.readyInLobby = true;
    return room;
  }
  if (action === 'start') {
    requireThat(room.status === 'lobby' || room.status === 'ended', 'Phòng không ở sảnh.');
    requireThat(p.connected && p.ringIndex === 0, 'Chỉ chủ phòng được bắt đầu.', 403);
    requireThat(Object.values(room.players).filter(player => player.connected)
      .every(player => player.readyInLobby !== false), 'Chờ mọi người quay lại phòng.');
    requireThat(Object.values(room.players).filter(p => p.connected).length >= 2, 'Cần ít nhất 2 người.');
    room.status = 'playing'; room.timer = { startedAt: now, endTime: now + 60000 };
    delete room.results;
    room.inbox = {};
    for (const player of Object.values(room.players)) player.completedOrders = 0;
    room.lastSpawnAt = now; roundSetup(room, 1); return room;
  }
  if (action === 'end') {
    requireThat(room.status === 'ended' || (room.status === 'playing' &&
      (now >= room.timer.endTime || Object.values(room.players).filter(p => p.connected).length < 2)), 'Trận chưa đủ điều kiện kết thúc.');
    end(room, now); return room;
  }
  requireThat(room.status === 'playing' && p.connected, 'Trận không hoạt động.');
  const ring = p.ringIndex, box = room.inbox[ring] ||= {};
  const item = Object.hasOwn(box, body.itemId) ? box[body.itemId] : undefined;
  if (['send', 'trash', 'process'].includes(action)) requireThat(item, 'Vật phẩm không còn trong khay.', 404);
  if (action === 'send') {
    const n = Object.keys(room.players).length, target = body.toRingIndex;
    requireThat(Number.isInteger(target) && target >= 0 && target < n && target !== ring &&
      [(ring + 1) % n, (ring - 1 + n) % n].includes(target), 'Chỉ được chuyền cho người liền kề.', 400);
    requireThat(Object.values(room.players).some(p => p.ringIndex === target && p.connected), 'Người nhận mất kết nối.');
    const destination = room.inbox[target] ||= {};
    requireThat(Object.keys(destination).length < 12, 'Khay người nhận đã đầy.');
    destination[body.itemId] = { ...item, fromRingIndex: ring }; delete box[body.itemId];
  } else if (action === 'trash') delete box[body.itemId];
  else if (action === 'process') {
    const station = room.round.stationAssignment[ring];
    requireThat(station && station === body.station, 'Trạm không thuộc người chơi.', 403);
    const output = processing[station]?.[item.itemId];
    requireThat(output, 'Trạm không xử lý được vật phẩm này.', 400);
    box[body.itemId] = { ...item, type: 'product', itemId: output };
  } else if (action === 'submit') {
    const order = room.orders[uid]?.[body.orderId], product = box[body.productId];
    requireThat(order && order.status === 'pending', 'Đơn không tồn tại hoặc đã nộp.');
    requireThat(product && product.type === 'product' && product.itemId === recipes.find(r => r.id === order.recipeId).productId, 'Sản phẩm không khớp đơn.');
    delete box[body.productId]; order.status = 'submitted';
    p.completedOrders++; room.round.progress[ring]++; room.timer.endTime += 5000;
  } else requireThat(false, 'Thao tác không hợp lệ.', 400);
  settle(room, now); return room;
}
module.exports = { recipes, create, command, settle, requireThat };
