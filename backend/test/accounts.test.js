'use strict';
const { test } = require('node:test');
const assert = require('node:assert/strict');
const { AccountBackend } = require('../src/accounts');

// Explicit in-memory fixtures test policy only; they do not prove a live Firebase connection.
function fixture() {
  const records = new Map();
  function ref(path) {
    return { path, get: async () => ({ data: () => records.get(path) }),
      create: async value => { assert.ok(!records.has(path)); records.set(path, value); },
      update: async value => records.set(path, { ...records.get(path), ...value }),
      delete: async () => records.delete(path) };
  }
  const db = { collection: name => ({ doc: id => ref(`${name}/${id}`) }), runTransaction: async action => {
    const writes = [];
    const result = await action({ get: r => r.get(),
      set: (r, value, options) => writes.push(() => records.set(r.path, options?.merge ? { ...records.get(r.path), ...value } : value)),
      update: (r, value) => writes.push(() => records.set(r.path, { ...records.get(r.path), ...value })) });
    writes.forEach(write => write()); return result;
  } };
  let now = Date.now();
  const users = new Map(['a', 'b'].map(uid => [uid, { uid, email: `${uid}@example.com`, displayName: 'Same name', providerData: [{}],
    emailVerified: false, disabled: false, tokensValidAfterTime: new Date(0).toISOString(), metadata: { creationTime: new Date().toISOString() } }]));
  const messages = [], claims = new Map();
  const auth = { verifyIdToken: async token => {
    if (token.startsWith('custom:')) return { uid: token.slice(7), auth_time: Math.floor(now / 1000), ...claims.get(token.slice(7)) };
    if (!users.has(token)) throw Error('invalid token');
    return { uid: token, auth_time: Math.floor(now / 1000) };
  }, getUser: async uid => users.get(uid), updateUser: async (uid, value) => Object.assign(users.get(uid), value),
  createCustomToken: async (uid, value) => { claims.set(uid, value); return `custom:${uid}`; } };
  const backend = new AccountBackend({ db, auth, secret: 'unit-test-only-secret-not-production', clock: () => now,
    sendEmail: async (email, code) => messages.push({ email, code }) });
  return { backend, records, messages, users, advance: ms => { now += ms; } };
}

test('policy: only a correct email code creates an authenticated grant; replay and logout fail', async () => {
  const { backend, messages, records } = fixture();
  const challenge = await backend.challenge('a');
  assert.equal(messages.length, 1);
  const stored = records.get('_accountChallenges/a');
  assert.ok(!Object.values(stored).includes(messages[0].code));
  await assert.rejects(backend.session('a'), { status: 401 });
  const result = await backend.verify('a', challenge.challengeId, messages[0].code);
  assert.ok(result.grant);
  assert.ok((await backend.session(result.customToken)).gameId);
  assert.ok((await backend.resume(result.grant)).customToken);
  await assert.rejects(backend.verify('a', challenge.challengeId, messages[0].code), { status: 400 });
  await backend.logout(result.customToken);
  await assert.rejects(backend.resume(result.grant), { status: 401 });
});

test('policy: wrong OTP, expiry, resend cooldown, daily window limit and cancellation', async () => {
  const { backend, messages, advance } = fixture();
  const first = await backend.challenge('a');
  await assert.rejects(backend.challenge('a'), { status: 429 });
  const wrong = messages[0].code === '000000' ? '111111' : '000000';
  for (let i = 0; i < 5; i++) await assert.rejects(backend.verify('a', first.challengeId, wrong), { status: 400 });
  await assert.rejects(backend.verify('a', first.challengeId, messages[0].code), { status: 400 });
  advance(60001);
  const second = await backend.challenge('a');
  advance(600001);
  await assert.rejects(backend.verify('a', second.challengeId, messages[1].code), { status: 400 });
  const third = await backend.challenge('a');
  await backend.cancel('a', third.challengeId);
  await assert.rejects(backend.verify('a', third.challengeId, messages[2].code), { status: 400 });
  for (let i = 0; i < 2; i++) { advance(60001); await backend.challenge('a'); }
  advance(60001);
  await assert.rejects(backend.challenge('a'), { status: 429 });
});

test('policy: duplicate display names have distinct stable Game IDs; legacy profile data is retained', async () => {
  const { backend, users, records } = fixture();
  const first = await backend.ensureProfile(users.get('a')), second = await backend.ensureProfile(users.get('b'));
  assert.equal(first.displayName, second.displayName);
  assert.notEqual(first.uid, second.uid);
  assert.notEqual(first.gameId, second.gameId);
  records.set('players/a', { ...first, displayName: 'Changed', gacha: { owned: ['cat'] }, points: 123 });
  const again = await backend.ensureProfile(users.get('a'));
  assert.equal(again.gameId, first.gameId);
  assert.equal(again.displayName, 'Changed');
  assert.deepEqual(again.gacha, { owned: ['cat'] });
  assert.equal(again.points, 123);
});

test('policy: failed email delivery never validates OTP; revoked credentials invalidate grants', async () => {
  const { backend, users, messages, advance } = fixture();
  const challenge = await backend.challenge('a');
  const result = await backend.verify('a', challenge.challengeId, messages[0].code);
  advance(1000);
  users.get('a').tokensValidAfterTime = new Date(Date.now() + 1000).toISOString();
  await assert.rejects(backend.resume(result.grant), { status: 401 });
  backend.sendEmail = async () => { throw Error('provider unavailable'); };
  await assert.rejects(backend.challenge('b'), { status: 503 });
});
