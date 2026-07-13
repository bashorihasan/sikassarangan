const { prisma } = require('../lib/prisma');

function formatNotifikasi(notifikasi) {
  return {
    id: notifikasi.id,
    title: notifikasi.title,
    body: notifikasi.body,
    type: notifikasi.type,
    related_id: notifikasi.relatedId,
    is_read: notifikasi.isRead,
    created_at: notifikasi.createdAt,
  };
}

function serverError(res, error) {
  console.error(error);
  return res.status(500).json({
    success: false,
    message: 'Terjadi kesalahan server',
  });
}

async function getAllNotifikasi(req, res) {
  try {
    const { page, limit } = req.query;
    const skip = (page - 1) * limit;

    const [items, total] = await Promise.all([
      prisma.notifikasi.findMany({
        where: { userId: req.user.id },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      prisma.notifikasi.count({ where: { userId: req.user.id } }),
    ]);

    return res.status(200).json({
      success: true,
      data: items.map(formatNotifikasi),
      pagination: {
        page,
        limit,
        total,
        total_pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    return serverError(res, error);
  }
}

async function getUnreadCount(req, res) {
  try {
    const count = await prisma.notifikasi.count({
      where: { userId: req.user.id, isRead: false },
    });

    return res.status(200).json({
      success: true,
      data: { unread_count: count },
    });
  } catch (error) {
    return serverError(res, error);
  }
}

async function markRead(req, res) {
  try {
    // Scope ke userId supaya user tidak bisa menandai notifikasi milik orang lain.
    const result = await prisma.notifikasi.updateMany({
      where: { id: req.params.id, userId: req.user.id },
      data: { isRead: true },
    });

    if (result.count === 0) {
      return res.status(404).json({
        success: false,
        message: 'Notifikasi tidak ditemukan',
      });
    }

    return res.status(200).json({
      success: true,
      data: { id: req.params.id, is_read: true },
    });
  } catch (error) {
    return serverError(res, error);
  }
}

async function markAllRead(req, res) {
  try {
    const result = await prisma.notifikasi.updateMany({
      where: { userId: req.user.id, isRead: false },
      data: { isRead: true },
    });

    return res.status(200).json({
      success: true,
      data: { updated: result.count },
    });
  } catch (error) {
    return serverError(res, error);
  }
}

module.exports = {
  getAllNotifikasi,
  getUnreadCount,
  markRead,
  markAllRead,
};
