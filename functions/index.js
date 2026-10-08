'use strict';
const { initializeApp } = require('firebase-admin/app');
const { getDatabase } = require('firebase-admin/database');
const { onValueCreated } = require('firebase-functions/v2/database');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { transition, settle } = require('./challenge');
initializeApp(process.env.FUNCTIONS_EMULATOR === 'true' ? {
  projectId: process.env.GCLOUD_PROJECT,
  databaseURL: `https://${process.env.GCLOUD_PROJECT}-default-rtdb.firebaseio.com`,
} : undefined);
const db = getDatabase();
// Set this region to the RTDB region before deploying.
const region = process.env.FUNCTIONS_EMULATOR === 'true' ? 'us-central1' :
  process.env.RUBIK_REGION || 'asia-southeast1';
async function receipts(code, room) {
  if (room?.status !== 'finished') return;
  const updates = {};
  for (const [uid, amount] of Object.entries(room.rewards)) {
    updates[`rubikRewards/${uid}/${room.creationId}_${room.round}`] = {
      amount, code, round: room.round, issuedAt: room.endedAt,
    };
  }
  await db.ref().update(updates);
}
exports.rubikCommand = onValueCreated({ ref: '/rubikCommands/{uid}/{id}', region }, async event => {
  const { uid, id } = event.params, command = { ...event.data.val(), id };
  const response = db.ref(`rubikResponses/${uid}/${id}`);
  if ((await response.get()).exists()) return;
  try {
    if (!/^[A-Z2-9]{6}$/.test(command.code)) throw new Error('Mã phòng không hợp lệ.');
    const presence = (await db.ref(`rubikPresence/${command.code}`).get()).val() || {};
    let failure;
    const result = await db.ref(`rubikRooms/${command.code}`).transaction(room => {
      // Admin transactions can first run with an empty local cache. Propose null
      // to force a server comparison/retry rather than aborting an existing room.
      if (room === null && command.action !== 'create') return null;
      failure = undefined;
      try { return transition(room, uid, command, command.action === 'finish' ? command.at : Date.now(), presence); }
      catch (e) { failure = e; return; }
    });
    if (!result.committed) throw failure || new Error('Không cập nhật được phòng.');
    if (!result.snapshot.exists() && command.action !== 'leave') throw new Error('Phòng không tồn tại.');
    await receipts(command.code, result.snapshot.val());
    await response.set({ ok: true });
  } catch (error) { await response.set({ ok: false, error: error.message }); }
});
exports.rubikMaintenance = onSchedule({ schedule: 'every 1 minutes', region }, async () => {
  const now = Date.now();
  const rooms = (await db.ref('rubikRooms').get()).val() || {};
  for (const [code] of Object.entries(rooms)) {
    const presence = (await db.ref(`rubikPresence/${code}`).get()).val() || {};
    const result = await db.ref(`rubikRooms/${code}`).transaction(room => {
      if (!room) return null;
      if (now - room.updatedAt > 86400000 || Object.values(room.players).every(p => p.left)) return null;
      if (['waiting', 'ready', 'countdown'].includes(room.status) && (!room.startAt || now < room.startAt)) {
        for (const uid of Object.keys(room.players)) {
          if (presence[uid] && !presence[uid].online && now - presence[uid].at >= 30000) {
            delete room.players[uid]; room.status = 'waiting';
            delete room.scramble; delete room.startAt;
          }
        }
        if (!Object.keys(room.players).length) return null;
        if (room.status === 'waiting') {
          room.hostId = Object.keys(room.players)[0];
          Object.values(room.players).forEach(p => { p.ready = false; p.loaded = false; });
        }
      }
      return settle(room, now, presence);
    });
    await receipts(code, result.snapshot.val());
    if (!result.snapshot.exists()) await db.ref(`rubikPresence/${code}`).remove();
  }
  // Commands/responses are transient. Reward receipts survive room cleanup.
  for (const [uid, commands] of Object.entries((await db.ref('rubikCommands').get()).val() || {})) {
    for (const [id, command] of Object.entries(commands)) if (now - command.at > 3600000) {
      await db.ref().update({ [`rubikCommands/${uid}/${id}`]: null, [`rubikResponses/${uid}/${id}`]: null });
    }
  }
});
