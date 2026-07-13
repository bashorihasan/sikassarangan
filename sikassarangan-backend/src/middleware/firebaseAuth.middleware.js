const { Prisma } = require('@prisma/client');
const { getAuth } = require('firebase-admin/auth');

const { isFirebaseConfigured } = require('../config/firebase');
const { prisma } = require('../lib/prisma');

function unauthorized(res, message) {
  return res.status(401).json({
    success: false,
    message,
  });
}

function resolveAuthProvider(decodedToken) {
  const provider = decodedToken.firebase && decodedToken.firebase.sign_in_provider;
  return provider === 'google.com' ? 'GOOGLE' : 'EMAIL';
}

function resolveName(decodedToken, email) {
  if (decodedToken.name && decodedToken.name.trim()) {
    return decodedToken.name.trim();
  }
  if (email) {
    return email.split('@')[0];
  }
  return 'Pengguna';
}

// Cari user berdasarkan firebaseUid. Kalau belum ada:
//  - kalau email-nya sudah terdaftar (akun lama tanpa firebaseUid), tautkan.
//  - kalau benar-benar baru, buat user baru dari data token.
async function findOrCreateUser(decodedToken) {
  const firebaseUid = decodedToken.uid;
  const email = decodedToken.email || null;
  const name = resolveName(decodedToken, email);
  const authProvider = resolveAuthProvider(decodedToken);

  const byUid = await prisma.user.findUnique({ where: { firebaseUid } });
  if (byUid) {
    return byUid;
  }

  if (email) {
    const byEmail = await prisma.user.findUnique({ where: { email } });
    if (byEmail) {
      return prisma.user.update({
        where: { id: byEmail.id },
        data: { firebaseUid, authProvider },
      });
    }
  }

  try {
    return await prisma.user.create({
      data: {
        email: email || `${firebaseUid}@no-email.local`,
        name,
        firebaseUid,
        authProvider,
      },
    });
  } catch (error) {
    // Race condition: user dibuat oleh request lain yang bersamaan. Ambil ulang.
    if (
      error instanceof Prisma.PrismaClientKnownRequestError &&
      error.code === 'P2002'
    ) {
      const existing = await prisma.user.findUnique({ where: { firebaseUid } });
      if (existing) {
        return existing;
      }
    }
    throw error;
  }
}

async function firebaseAuth(req, res, next) {
  if (!isFirebaseConfigured()) {
    return res.status(503).json({
      success: false,
      message: 'Autentikasi Firebase belum dikonfigurasi di server',
    });
  }

  const header = req.header('authorization') || req.header('Authorization');
  if (!header || !header.startsWith('Bearer ')) {
    return unauthorized(res, 'Token autentikasi tidak dikirim');
  }

  const token = header.slice('Bearer '.length).trim();
  if (!token) {
    return unauthorized(res, 'Token autentikasi tidak dikirim');
  }

  let decodedToken;
  try {
    decodedToken = await getAuth().verifyIdToken(token);
  } catch (error) {
    return unauthorized(res, 'Token autentikasi tidak valid atau kadaluarsa');
  }

  try {
    req.user = await findOrCreateUser(decodedToken);
    req.firebaseToken = decodedToken;
    return next();
  } catch (error) {
    console.error('[firebaseAuth] Gagal sinkronisasi user:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal memproses data user',
    });
  }
}

module.exports = {
  firebaseAuth,
  findOrCreateUser,
};
