const test = require('node:test');
const assert = require('node:assert/strict');
const { transition: step, scramble, settle } = require('../challenge');
function start() {
  let room = step(null, 'a', {action:'create', id:'unique', name:'A'}, 1000);
  room = step(room, 'b', {action:'join', name:'B'}, 2000);
  const command = action => ({action, round:1});
  room = step(room, 'a', command('ready'), 3000);
  room = step(room, 'b', command('ready'), 3000);
  room = step(room, 'a', command('loaded'), 4000);
  assert.equal(room.status, 'ready');
  room = step(room, 'b', command('loaded'), 4000);
  return room;
}
test('capacity, common scramble, prepared handshake and start epoch', () => {
  const room = start();
  assert.equal(room.status, 'countdown'); assert.equal(room.startAt, 9000);
  assert.equal(room.scramble.length, 20);
  assert.throws(() => step(room, 'c', {action:'join'}, 5000));
  const repeated = step(room, 'a', {action:'ready',round:1}, 5000);
  assert.deepEqual(repeated.scramble, room.scramble);
});
test('finish before GO rejected; duplicates cannot rewrite time', () => {
  let room = start();
  room = step(room, 'a', {action:'finish',round:1}, 8999);
  assert.equal(room.players.a.finished, false);
  room = step(room, 'a', {action:'finish',round:1}, 10000);
  room = step(room, 'a', {action:'finish',round:1}, 11000);
  assert.equal(room.players.a.finishAt, 10000);
  room = step(room, 'b', {action:'finish',round:1}, 12000);
  assert.equal(room.winnerId, 'a'); assert.deepEqual(room.rewards, {a:50,b:10});
  assert.equal(room.players.b.finishMs, 3000);
});
test('receipt timestamps determine winner despite reversed function order', () => {
  let room = start();
  room = step(room, 'b', {action:'finish',round:1}, 12000);
  room = step(room, 'a', {action:'finish',round:1}, 10000);
  assert.equal(room.winnerId, 'a');
});
test('tie, timeout and disconnect grace', () => {
  let room = start();
  room = step(room, 'a', {action:'finish',round:1}, 10000);
  const tie = step(room, 'b', {action:'finish',round:1}, 10000);
  assert.deepEqual(tie.rewards, {a:25,b:25});
  const timeout = settle(structuredClone(room), room.startAt+300000);
  assert.equal(timeout.players.b.dnf, true); assert.deepEqual(timeout.rewards, {a:50,b:0});
  const presence = {b:{online:false,at:10000}};
  assert.equal(settle(structuredClone(room), 39999, presence).status, 'playing');
  assert.equal(settle(structuredClone(room), 40000, presence).winnerId, 'a');
});
test('both must agree to rematch and stale commands cannot affect next round', () => {
  let room = start();
  room = step(room, 'a', {action:'finish',round:1}, 10000);
  room = step(room, 'b', {action:'finish',round:1}, 12000);
  room = step(room, 'a', {action:'rematch',round:1}, 13000);
  assert.equal(room.round, 1);
  room = step(room, 'b', {action:'rematch',round:1}, 13000);
  assert.equal(room.round, 2); assert.equal(room.status, 'ready');
  assert.equal(room.scramble, undefined); assert.equal(room.players.a.finished, false);
  assert.throws(() => step(room, 'a', {action:'finish',round:1}, 14000));
});
test('leave before GO resets readiness and host; final departure deletes room', () => {
  let room = start();
  room = step(room, 'a', {action:'leave',round:1}, 6000);
  assert.equal(room.status, 'waiting'); assert.equal(room.hostId, 'b');
  assert.equal(room.scramble, undefined); assert.equal(room.players.b.ready, false);
  room = step(room, 'b', {action:'leave',round:1}, 6500);
  assert.equal(room, null);
});
test('scramble excludes adjacent moves on the same axis', () => {
  for (let i=0;i<100;i++) {
    const moves = scramble(); assert.equal(moves.length,20);
    for (let j=1;j<moves.length;j++) {
      assert.notEqual(Math.floor('RLUDFB'.indexOf(moves[j][0])/2),
        Math.floor('RLUDFB'.indexOf(moves[j-1][0])/2));
    }
  }
});
