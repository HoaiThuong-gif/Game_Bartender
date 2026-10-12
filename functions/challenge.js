'use strict';
const { randomInt } = require('node:crypto');
const LIMIT = 300000, GRACE = 30000;
function scramble() {
  const faces = 'RLUDFB', suffix = ['', "'", '2'], moves = [];
  let previous = -1;
  for (let i = 0; i < 20; i++) {
    let face;
    do { face = randomInt(6); } while (Math.floor(face / 2) === previous);
    previous = Math.floor(face / 2);
    moves.push(faces[face] + suffix[randomInt(3)]);
  }
  return moves;
}
const player = name => ({ name: String(name || 'Người chơi').slice(0, 24), ready: false,
  loaded: false, finished: false, dnf: false, rematch: false, left: false });
function settle(room, now, presence = {}) {
  const players = Object.entries(room.players);
  if (room.status === 'countdown' && now >= room.startAt) room.status = 'playing';
  if (room.status !== 'playing') return room;
  for (const [uid, p] of players) {
    const offline = presence[uid];
    if (!p.finished && (p.left || now >= room.startAt + LIMIT ||
      (offline && !offline.online && now - offline.at >= GRACE))) p.dnf = true;
  }
  if (!players.every(([, p]) => p.finished || p.dnf)) return room;
  const valid = players.filter(([, p]) => p.finished && !p.dnf);
  valid.sort((a, b) => a[1].finishAt - b[1].finishAt);
  room.status = 'finished'; room.endedAt = now;
  room.winnerId = valid.length === 2 && valid[0][1].finishAt === valid[1][1].finishAt
    ? 'draw' : valid[0]?.[0] || 'none';
  room.rewards = Object.fromEntries(players.map(([uid, p]) => [uid,
    p.dnf ? 0 : room.winnerId === 'draw' ? 25 : room.winnerId === uid ? 50 : p.finished ? 10 : 0]));
  return room;
}
function transition(original, uid, command, now, presence = {}) {
  let room = original ? structuredClone(original) : null;
  const { action, round } = command;
  if (action === 'create') {
    if (room) {
      if (room.creationId === command.id && room.hostId === uid) return room;
      throw new Error('Mã phòng đã được dùng. Hãy tạo lại.');
    }
    return { hostId: uid, creationId: command.id, createdAt: now, updatedAt: now,
      round: 1, status: 'waiting', players: { [uid]: player(command.name) } };
  }
  if (!room) throw new Error('Phòng không tồn tại.');
  if (action === 'join') {
    if (room.players[uid] && !room.players[uid].left) return room;
    if (room.status !== 'waiting' || Object.keys(room.players).length >= 2)
      throw new Error('Phòng đã đủ người hoặc đã bắt đầu.');
    room.players[uid] = player(command.name); room.status = 'ready';
    room.updatedAt = now; return room;
  }
  const p = room.players[uid];
  if (!p || round !== room.round) throw new Error('Bạn không thuộc lượt chơi này.');
  // Finish uses the server receipt time of the command, not function execution latency.
  if (action === 'finish' && ['countdown', 'playing'].includes(room.status) &&
      now >= room.startAt && now < room.startAt + LIMIT && !p.finished && !p.dnf && !p.left) {
    p.finished = true; p.finishAt = now; p.finishMs = now - room.startAt;
  } else if (action === 'ready' && room.status === 'ready') {
    p.ready = true;
    if (Object.values(room.players).every(p => p.ready) && !room.scramble) room.scramble = scramble();
  } else if (action === 'loaded' && room.status === 'ready' && room.scramble) {
    p.loaded = true;
    if (Object.values(room.players).every(p => p.ready && p.loaded)) {
      room.status = 'countdown'; room.startAt = now + 5000;
    }
  } else if (action === 'leave') {
    if (['waiting', 'ready', 'countdown'].includes(room.status) && (!room.startAt || now < room.startAt)) {
      delete room.players[uid];
      if (!Object.keys(room.players).length) return null;
      room.hostId = Object.keys(room.players)[0]; room.status = 'waiting';
      delete room.scramble; delete room.startAt;
      Object.values(room.players).forEach(p => { p.ready = false; p.loaded = false; });
    } else { p.left = true; if (!p.finished) p.dnf = true; }
  } else if (action === 'rematch' && room.status === 'finished' && !p.left) {
    p.rematch = true;
    if (Object.values(room.players).every(p => p.rematch && !p.left)) {
      room.round++; room.status = 'ready';
      delete room.scramble; delete room.startAt; delete room.winnerId; delete room.rewards; delete room.endedAt;
      for (const id of Object.keys(room.players)) room.players[id] = player(room.players[id].name);
    }
  } else if (!['finish', 'tick', 'loaded', 'ready', 'rematch'].includes(action)) {
    throw new Error('Thao tác không hợp lệ.');
  }
  room.updatedAt = now;
  return settle(room, now, presence);
}
module.exports = { transition, settle, scramble, LIMIT, GRACE };
