// firebase-admin v14 memakai modular API (bukan lagi namespaced `admin.credential.cert`).
const { initializeApp, getApps, cert } = require('firebase-admin/app');

// Status inisialisasi. Dipakai middleware/notify untuk fail-closed kalau Firebase
// belum dikonfigurasi (mis. env FIREBASE_SERVICE_ACCOUNT_BASE64 belum di-set).
let firebaseReady = false;

function initFirebase() {
  if (getApps().length > 0) {
    firebaseReady = true;
    return;
  }

  const base64 = process.env.FIREBASE_SERVICE_ACCOUNT_BASE64;

  if (!base64) {
    console.warn(
      '[firebase] FIREBASE_SERVICE_ACCOUNT_BASE64 belum di-set — verifikasi token & push notification dinonaktifkan.'
    );
    return;
  }

  try {
    const serviceAccount = JSON.parse(
      Buffer.from(base64, 'base64').toString('utf-8')
    );

    initializeApp({
      credential: cert(serviceAccount),
    });

    firebaseReady = true;
    console.log('[firebase] Firebase Admin SDK berhasil diinisialisasi.');
  } catch (error) {
    console.error(
      '[firebase] Gagal inisialisasi Firebase Admin SDK:',
      error.message
    );
  }
}

initFirebase();

function isFirebaseConfigured() {
  return firebaseReady;
}

module.exports = {
  isFirebaseConfigured,
};
