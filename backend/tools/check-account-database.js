'use strict';
// Admin credential is read from the environment, never from tracked source files.
const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { randomUUID } = require('node:crypto');
const path = require('node:path'), fs = require('node:fs');
const env = path.join(__dirname, '../.env');
if (fs.existsSync(env)) process.loadEnvFile(env);

async function main() {
  if (!process.env.FIREBASE_PROJECT_ID || !process.env.GOOGLE_APPLICATION_CREDENTIALS) throw Error('Thiếu Firebase Admin credentials. Chưa kiểm chứng Firestore thật.');
  if (!fs.existsSync(process.env.GOOGLE_APPLICATION_CREDENTIALS)) throw Error('Đường dẫn GOOGLE_APPLICATION_CREDENTIALS không tồn tại. Chưa kết nối Firestore.');
  const app = initializeApp({ credential: applicationDefault(), projectId: process.env.FIREBASE_PROJECT_ID });
  const db = getFirestore(app);
  const ref = db.collection('_accountDiagnostics').doc(randomUUID());
  try {
    await ref.create({ value: 1 });
    if ((await ref.get()).data()?.value !== 1) throw Error('Read failed');
    await ref.update({ value: 2 });
    if ((await ref.get()).data()?.value !== 2) throw Error('Update failed');
    console.log('Firestore thật: tạo, đọc và cập nhật thành công. Dữ liệu người dùng không bị sửa.');
  } finally {
    await ref.delete(); // Only this random diagnostic document, never a player record.
    await db.terminate();
  }
}
main().catch(error => { console.error(error.code || error.message); process.exitCode = 1; });
