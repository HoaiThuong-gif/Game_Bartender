'use strict';
const { randomBytes, randomInt, createHash, createHmac, timingSafeEqual } = require('node:crypto');
const { getApps, initializeApp, applicationDefault } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore } = require('firebase-admin/firestore');
const fs = require('node:fs');

const fail = (status, message) => Object.assign(new Error(message), { status });
const digest = value => createHash('sha256').update(value).digest('hex');
const MINUTE = 60000;

class AccountBackend {
  constructor({ db, auth, secret, sendEmail, clock = Date.now }) {
    Object.assign(this, { db, auth, secret, sendEmail, clock });
  }

  async identity(token, recent = false) {
    let claims;
    try { claims = await this.auth.verifyIdToken(token, true); }
    catch (_) { throw fail(401, 'Phiên đăng nhập không hợp lệ. Hãy đăng nhập lại.'); }
    const user = await this.auth.getUser(claims.uid);
    if (user.disabled || !user.email || user.providerData.length === 0) throw fail(403, 'Tài khoản cần có email và phương thức đăng nhập hợp lệ.');
    if (recent && this.clock() - claims.auth_time * 1000 > 5 * MINUTE) throw fail(401, 'Hãy đăng nhập lại trước khi nhận mã xác thực.');
    return { user, claims };
  }

  hashCode(uid, id, email, code) {
    return createHmac('sha256', this.secret).update(JSON.stringify([uid, id, email, code])).digest('hex');
  }

  async challenge(token) {
    const { user, claims } = await this.identity(token, true);
    const now = this.clock(), id = randomBytes(24).toString('hex');
    const code = String(randomInt(1000000)).padStart(6, '0');
    const ref = this.db.collection('_accountChallenges').doc(user.uid);
    await this.db.runTransaction(async tx => {
      const old = (await tx.get(ref)).data() || {};
      if ((old.sendAfter || 0) > now) throw fail(429, 'Hãy đợi ít nhất 60 giây trước khi gửi lại.');
      const sameWindow = now - (old.windowStart || 0) < 60 * MINUTE;
      const sends = sameWindow ? old.sends || 0 : 0;
      if (sends >= 5) throw fail(429, 'Đã đạt giới hạn gửi mã. Hãy thử lại sau một giờ.');
      tx.set(ref, { id, email: user.email, hash: this.hashCode(user.uid, id, user.email, code),
        expiresAt: now + 10 * MINUTE, sendAfter: now + MINUTE, attempts: 0, used: false,
        authTime: claims.auth_time, status: 'sending', windowStart: sameWindow ? old.windowStart : now, sends: sends + 1 });
    });
    try {
      await this.sendEmail(user.email, code);
      await this.db.runTransaction(async tx => {
        if ((await tx.get(ref)).data()?.id === id) tx.update(ref, { status: 'sent' });
      });
    } catch (_) {
      await this.db.runTransaction(async tx => {
        if ((await tx.get(ref)).data()?.id === id) tx.update(ref, { status: 'failed', used: true });
      });
      throw fail(503, 'Chưa gửi được email. Hãy kiểm tra cấu hình gửi thư hoặc thử lại sau.');
    }
    return { challengeId: id, expiresAt: now + 10 * MINUTE, retryAt: now + MINUTE,
      email: user.email.replace(/^(.).*(@.*)$/, '$1***$2') };
  }

  async verify(token, id, code) {
    const { user, claims } = await this.identity(token);
    const now = this.clock(), ref = this.db.collection('_accountChallenges').doc(user.uid);
    const result = await this.db.runTransaction(async tx => {
      const entry = (await tx.get(ref)).data();
      if (!entry || entry.authTime !== claims.auth_time || entry.id !== id || entry.email !== user.email || entry.used || entry.status !== 'sent') return 'Mã không còn hiệu lực. Hãy yêu cầu mã mới.';
      if (entry.expiresAt <= now) return 'Mã đã hết hạn. Hãy gửi lại mã.';
      if (entry.attempts >= 5) return 'Đã nhập sai quá nhiều lần. Hãy yêu cầu mã mới.';
      const correct = /^\d{6}$/.test(code) && timingSafeEqual(Buffer.from(entry.hash, 'hex'),
        Buffer.from(this.hashCode(user.uid, id, user.email, code), 'hex'));
      tx.update(ref, { attempts: entry.attempts + 1, used: correct || entry.attempts + 1 >= 5 });
      return correct ? null : 'Mã chưa đúng. Bạn chỉ được thử tối đa 5 lần.';
    });
    if (result) throw fail(400, result);
    if (!user.emailVerified) await this.auth.updateUser(user.uid, { emailVerified: true });
    const grant = randomBytes(32).toString('hex');
    const sid = digest(grant), expiresAt = now + 30 * 24 * 60 * MINUTE;
    await this.db.collection('_accountSessions').doc(sid).create({ uid: user.uid, createdAt: now, expiresAt, revoked: false });
    await this.ensureProfile(user);
    const customToken = await this.auth.createCustomToken(user.uid, { account_session: sid });
    return { customToken, grant, expiresAt };
  }

  async checkGrant(sid, uid) {
    const entry = (await this.db.collection('_accountSessions').doc(sid).get()).data();
    if (!entry || (uid && entry.uid !== uid) || entry.revoked || entry.expiresAt <= this.clock()) throw fail(401, 'Phiên xác thực đã hết hạn. Hãy đăng nhập và xác thực email lại.');
    const user = await this.auth.getUser(entry.uid);
    if (user.disabled || (Date.parse(user.tokensValidAfterTime) || 0) > entry.createdAt) throw fail(401, 'Phiên đã bị thu hồi. Hãy đăng nhập lại.');
    return user;
  }

  async resume(grant) {
    if (!/^[a-f0-9]{64}$/.test(grant)) throw fail(401, 'Khóa đăng nhập không hợp lệ.');
    const sid = digest(grant), user = await this.checkGrant(sid);
    return { customToken: await this.auth.createCustomToken(user.uid, { account_session: sid }) };
  }

  async session(token) {
    const { user, claims } = await this.identity(token);
    if (typeof claims.account_session !== 'string') throw fail(401, 'Cần xác thực email trước khi vào Lobby.');
    await this.checkGrant(claims.account_session, user.uid);
    return this.ensureProfile(user);
  }

  async logout(token) {
    const { user, claims } = await this.identity(token);
    if (typeof claims.account_session === 'string') {
      const ref = this.db.collection('_accountSessions').doc(claims.account_session);
      await this.db.runTransaction(async tx => {
        const session = (await tx.get(ref)).data();
        if (session?.uid === user.uid) tx.update(ref, { revoked: true });
      });
    }
    await this.db.collection('_accountChallenges').doc(user.uid).delete();
    return { ok: true };
  }

  async cancel(token, id) {
    const { user } = await this.identity(token);
    const ref = this.db.collection('_accountChallenges').doc(user.uid);
    await this.db.runTransaction(async tx => {
      const value = (await tx.get(ref)).data();
      if (value?.id === id) tx.update(ref, { used: true });
    });
    return { ok: true };
  }

  async ensureProfile(user) {
    // A unique index reserves public IDs. Names are never used as keys.
    for (let attempt = 0; attempt < 5; attempt++) {
      const candidate = 'NB-' + randomBytes(8).toString('hex').toUpperCase();
      const result = await this.db.runTransaction(async tx => {
        const ref = this.db.collection('players').doc(user.uid);
        const previous = (await tx.get(ref)).data() || {};
        if (previous.uid && previous.uid !== user.uid) throw fail(409, 'UID hồ sơ cũ cần kiểm tra; dữ liệu chưa bị thay đổi.');
        const gameId = previous.gameId || previous.gameID || candidate;
        if (typeof gameId !== 'string' || gameId.includes('/') || !gameId.length) throw fail(409, 'Game ID cũ cần được quản trị viên kiểm tra; dữ liệu chưa bị thay đổi.');
        const index = this.db.collection('gameIds').doc(gameId), existing = (await tx.get(index)).data();
        if (existing && existing.uid !== user.uid) {
          if (gameId !== candidate) throw fail(409, 'Game ID cũ bị trùng. Cần kiểm tra trước khi chuyển dữ liệu.');
          return null;
        }
        const defaults = { uid: user.uid, gameId, displayName: user.displayName || 'Người chơi',
          email: user.email, photoURL: user.photoURL || '', createdAt: new Date(user.metadata.creationTime), schemaVersion: 2 };
        const missing = Object.fromEntries(Object.entries(defaults).filter(([key]) => !(key in previous)));
        if (previous.gameId == null || previous.gameId === '') missing.gameId = gameId;
        if (previous.uid == null || previous.uid === '') missing.uid = user.uid;
        tx.set(index, { uid: user.uid }, { merge: true });
        if (Object.keys(missing).length) tx.set(ref, missing, { merge: true });
        return { ...previous, ...missing };
      });
      if (result) return result;
    }
    throw fail(503, 'Chưa cấp được Game ID. Hãy thử lại.');
  }
}

function configuredBackend() {
  const { BREVO_API_KEY, BREVO_SENDER_EMAIL, OTP_HMAC_KEY, FIREBASE_PROJECT_ID } = process.env;
  if (!BREVO_API_KEY || !BREVO_SENDER_EMAIL || !OTP_HMAC_KEY || Buffer.byteLength(OTP_HMAC_KEY) < 32 || !FIREBASE_PROJECT_ID) {
    throw fail(503, 'Máy chủ chưa cấu hình Firebase Admin và email OTP. Hãy báo người quản lý.');
  }
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS && !fs.existsSync(process.env.GOOGLE_APPLICATION_CREDENTIALS)) {
    throw fail(503, 'Không tìm thấy file Firebase Admin. Hãy kiểm tra GOOGLE_APPLICATION_CREDENTIALS trên máy chủ.');
  }
  let app = getApps().find(app => app.name === 'accounts');
  if (!app) app = initializeApp({ credential: applicationDefault(), projectId: FIREBASE_PROJECT_ID }, 'accounts');
  return new AccountBackend({ db: getFirestore(app), auth: getAuth(app), secret: OTP_HMAC_KEY,
    sendEmail: async (email, code) => {
      const response = await fetch('https://api.brevo.com/v3/smtp/email', { method: 'POST',
        headers: { 'api-key': BREVO_API_KEY, 'content-type': 'application/json' }, signal: AbortSignal.timeout(15000),
        body: JSON.stringify({ sender: { email: BREVO_SENDER_EMAIL, name: 'Nhóm Bar' }, to: [{ email }],
          subject: 'Mã xác thực Nhóm Bar', textContent: `Mã xác thực của bạn: ${code}. Mã có hạn 10 phút. Không chia sẻ mã này.` }) });
      if (!response.ok) throw fail(503, 'Không gửi được thư xác thực.');
    } });
}

let instance;
async function accountRoute(req, url, readBody) {
  if (!url.pathname.startsWith('/api/v1/account/')) return null;
  const name = url.pathname.substring('/api/v1/account/'.length);
  const allowed = { challenge: 'POST', verify: 'POST', resume: 'POST', session: 'GET', logout: 'POST', cancel: 'POST' };
  if (req.method !== allowed[name]) throw fail(404, 'Thao tác tài khoản không tồn tại.');
  const token = (req.headers.authorization || '').replace(/^Bearer /, '');
  const body = req.method === 'POST' ? await readBody(req) : {};
  try {
    instance ||= configuredBackend();
    switch (name) {
      case 'challenge': return await instance.challenge(token);
      case 'verify': return await instance.verify(token, String(body.challengeId || ''), String(body.code || ''));
      case 'resume': return await instance.resume(String(body.grant || ''));
      case 'session': return await instance.session(token);
      case 'logout': return await instance.logout(token);
      case 'cancel': return await instance.cancel(token, String(body.challengeId || ''));
    }
  } catch (error) {
    if (error.status) throw error;
    console.error('[Account]', error.code || error.name); // Never log credentials, OTP or email bodies.
    throw fail(503, 'Chưa kết nối được dịch vụ tài khoản. Hãy thử lại.');
  }
}
module.exports = { AccountBackend, accountRoute, configuredBackend };
