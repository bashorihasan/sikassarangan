const { prisma } = require('../lib/prisma');

function formatUser(user) {
  return {
    id: user.id,
    email: user.email,
    name: user.name,
    auth_provider: user.authProvider,
    firebase_uid: user.firebaseUid,
    fcm_token: user.fcmToken,
    created_at: user.createdAt,
    updated_at: user.updatedAt,
  };
}

// Dipanggil frontend setelah login sukses. firebaseAuth middleware sudah
// melakukan find-or-create user & attach ke req.user, jadi endpoint ini tinggal
// mengembalikan data user yang sudah tersinkron.
async function syncUser(req, res) {
  return res.status(200).json({
    success: true,
    data: formatUser(req.user),
  });
}

async function updateFcmToken(req, res) {
  try {
    const updated = await prisma.user.update({
      where: { id: req.user.id },
      data: { fcmToken: req.body.fcmToken },
    });

    return res.status(200).json({
      success: true,
      data: formatUser(updated),
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server',
    });
  }
}

module.exports = {
  syncUser,
  updateFcmToken,
  formatUser,
};
