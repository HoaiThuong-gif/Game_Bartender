'use strict';
// Run only against the local emulators. This script never contacts a live project.
const assert = require('node:assert/strict');
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const database = 'http://127.0.0.1:19000';
const namespace = 'demo-rubik-default-rtdb';
async function user() {
  const response = await fetch('http://127.0.0.1:19099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=demo', {
    method: 'POST', headers: {'content-type':'application/json'}, body: JSON.stringify({returnSecureToken:true}),
  });
  assert.equal(response.status,200);
  const data = await response.json(); return {uid:data.localId,token:data.idToken};
}
async function request(who, path, method = 'GET', data) {
  return fetch(`${database}/${path}.json?ns=${namespace}&auth=${who.token}`, {
    method, headers:{'content-type':'application/json'}, body:data === undefined ? undefined : JSON.stringify(data),
  });
}
async function command(who, action, round = 1) {
  const id = require('node:crypto').randomUUID();
  const write = await request(who,`rubikCommands/${who.uid}/${id}`,'PUT',{
    action, code:'ABC234',round,name:'Test player',at:{'.sv':'timestamp'},
  });
  assert.equal(write.status,200,await write.text());
  for (let i=0;i<100;i++) {
    const response = await request(who,`rubikResponses/${who.uid}/${id}`);
    const value = await response.json();
    if (value !== null) { if (!value.ok) console.log(`${action}: ${value.error}`); return value; }
    await sleep(200);
  }
  throw new Error(`No backend response to ${action}`);
}
async function room(who) {
  const response = await request(who,'rubikRooms/ABC234');
  assert.equal(response.status,200); return response.json();
}
async function main() {
  const a = await user(), b = await user(), c = await user();
  assert.equal((await command(a,'create',0)).ok,true);
  assert.equal((await command(b,'join',0)).ok,true);
  assert.equal((await command(c,'join',0)).ok,false);
  assert.equal((await request(c,'rubikRooms/ABC234')).status,401);
  assert.equal((await request(a,'rubikRooms/ABC234/winnerId','PUT',a.uid)).status,401);
  assert.equal((await request(a,`rubikRooms/ABC234/players/${b.uid}/finishAt`,'PUT',1)).status,401);
  assert.equal((await request(a,`rubikRewards/${a.uid}/fake`,'PUT',{amount:999})).status,401);
  // Client timestamps and request mutation must be denied.
  assert.equal((await request(a,`rubikCommands/${a.uid}/fake`,'PUT',
    {action:'finish',code:'ABC234',round:1,name:'A',at:1})).status,401);
  assert.equal((await command(a,'ready')).ok,true);
  assert.equal((await command(b,'ready')).ok,true);
  const first = await room(a); assert.deepEqual(first.scramble,(await room(b)).scramble);
  assert.equal(first.scramble.length,20);
  await command(a,'loaded'); assert.equal((await room(a)).status,'ready');
  await command(b,'loaded');
  const countdown = await room(a); assert.equal(countdown.status,'countdown');
  assert.equal(countdown.startAt,(await room(b)).startAt);
  await sleep(Math.max(0,countdown.startAt-Date.now()+50));
  await command(a,'finish');
  const finishAt = (await room(a)).players[a.uid].finishAt;
  await command(a,'finish'); assert.equal((await room(a)).players[a.uid].finishAt,finishAt);
  await command(b,'finish');
  const result = await room(a); assert.equal(result.status,'finished'); assert.equal(result.winnerId,a.uid);
  assert.equal((await room(b)).winnerId,a.uid);
  const receiptId = `${result.creationId}_1`;
  const receipt = await (await request(a,`rubikRewards/${a.uid}/${receiptId}`)).json();
  assert.equal(receipt.amount,50);
  await command(a,'rematch'); assert.equal((await room(a)).round,1);
  await command(b,'rematch'); assert.equal((await room(a)).round,2);
  assert.equal((await command(a,'finish',1)).ok,false);
  await command(a,'leave',2); await command(b,'leave',2);
  console.log('PASS: two authenticated clients, shared scramble/start, finish/reward, rematch, capacity and security rules.');
}
main().catch(error => { console.error(error); process.exitCode = 1; });
