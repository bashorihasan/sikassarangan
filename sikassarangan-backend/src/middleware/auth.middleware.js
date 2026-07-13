function authenticateApiKey(req, res, next) {
  const expectedApiKey = process.env.API_KEY;

  if (!expectedApiKey) {
    return res.status(500).json({
      success: false,
      message: 'API key belum dikonfigurasi di server',
    });
  }

  const providedApiKey = req.header('x-api-key');

  if (!providedApiKey || providedApiKey !== expectedApiKey) {
    return res.status(401).json({
      success: false,
      message: 'API key tidak valid atau tidak dikirim',
    });
  }

  return next();
}

// Menempelkan user yang sedang login ke req.user, sehingga controller bisa memakai
// req.user.id sebagai createdById tanpa memintanya dari body request.
//
// Catatan: login per-user (Firebase Authentication) belum diimplementasikan. Sampai itu
// aktif, middleware ini jadi jembatan sementara:
//   - Kalau autentikasi lain sudah mengisi req.user, biarkan (forward-compatible).
//   - Kalau ada header `x-user-id`, pakai itu sebagai identitas user.
//   - Kalau tidak ada, fallback ke DEFAULT_USER_ID (user default hasil migration/seed).
// Nanti saat Firebase aktif, cukup ganti/dahului middleware ini dengan verifikasi token
// yang mengisi req.user dari Firebase UID.
function attachCurrentUser(req, res, next) {
  if (req.user && req.user.id) {
    return next();
  }

  const headerUserId = req.header('x-user-id');
  const fallbackUserId = process.env.DEFAULT_USER_ID;
  const rawUserId = headerUserId || fallbackUserId;

  const userId = Number.parseInt(rawUserId, 10);

  if (!Number.isInteger(userId) || userId <= 0) {
    return res.status(401).json({
      success: false,
      message: 'User yang menginput transaksi tidak dapat ditentukan (x-user-id tidak valid)',
    });
  }

  req.user = { id: userId };
  return next();
}

module.exports = {
  authenticateApiKey,
  attachCurrentUser,
};
