const { getMessaging } = require('firebase-admin/messaging');

const { isFirebaseConfigured } = require('../config/firebase');
const { prisma } = require('../lib/prisma');

// FCM multicast dibatasi 500 token per panggilan.
const FCM_MULTICAST_LIMIT = 500;

function chunk(items, size) {
  const result = [];
  for (let i = 0; i < items.length; i += size) {
    result.push(items.slice(i, i + size));
  }
  return result;
}

// Hapus token yang sudah tidak valid (device uninstall / token kadaluarsa)
// supaya tabel users tetap bersih.
async function cleanupInvalidTokens(tokens, batchResponse) {
  const invalidTokens = [];

  batchResponse.responses.forEach((response, index) => {
    if (response.success) {
      return;
    }

    const code = response.error && response.error.code;
    if (
      code === 'messaging/registration-token-not-registered' ||
      code === 'messaging/invalid-registration-token' ||
      code === 'messaging/invalid-argument'
    ) {
      invalidTokens.push(tokens[index]);
    }
  });

  if (invalidTokens.length === 0) {
    return;
  }

  try {
    await prisma.user.updateMany({
      where: { fcmToken: { in: invalidTokens } },
      data: { fcmToken: null },
    });
  } catch (error) {
    console.warn('[notify] Gagal membersihkan token FCM invalid:', error.message);
  }
}

/**
 * Simpan riwayat notifikasi ke DB untuk semua user (kecuali excludeUserId) dan
 * kirim push FCM ke device mereka. Push bersifat best-effort — kalau Firebase
 * belum dikonfigurasi atau tidak ada token, riwayat tetap tersimpan.
 */
async function notifyAllUsers({
  title,
  body,
  type,
  relatedId = null,
  excludeUserId = null,
}) {
  const users = await prisma.user.findMany({
    where: excludeUserId ? { id: { not: excludeUserId } } : {},
    select: { id: true, fcmToken: true },
  });

  if (users.length === 0) {
    return;
  }

  // 1) Simpan riwayat notifikasi per user.
  await prisma.notifikasi.createMany({
    data: users.map((user) => ({
      userId: user.id,
      title,
      body,
      type,
      relatedId,
    })),
  });

  // 2) Kirim push (best-effort).
  if (!isFirebaseConfigured()) {
    return;
  }

  const tokens = users.map((user) => user.fcmToken).filter(Boolean);
  if (tokens.length === 0) {
    return;
  }

  const data = {
    type: String(type),
    relatedId: relatedId != null ? String(relatedId) : '',
  };

  for (const batch of chunk(tokens, FCM_MULTICAST_LIMIT)) {
    try {
      const response = await getMessaging().sendEachForMulticast({
        tokens: batch,
        notification: { title, body },
        data,
        android: {
          priority: 'high',
          notification: {
            channelId: 'sikassarangan_default',
            priority: 'high',
            sound: 'default',
            defaultSound: true,
          },
        },
      });
      await cleanupInvalidTokens(batch, response);
    } catch (error) {
      console.warn('[notify] Gagal mengirim push FCM:', error.message);
    }
  }
}

// Versi fire-and-forget: dipanggil dari handler tanpa di-await supaya tidak
// memblokir response endpoint utama. Semua error ditelan + di-log.
function notifyAllUsersInBackground(payload) {
  notifyAllUsers(payload).catch((error) => {
    console.error('[notify] notifyAllUsers gagal:', error);
  });
}

module.exports = {
  notifyAllUsers,
  notifyAllUsersInBackground,
};
