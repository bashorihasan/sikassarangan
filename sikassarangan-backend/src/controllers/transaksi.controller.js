const { Prisma } = require('@prisma/client');

const { prisma } = require('../lib/prisma');
const { redisClient } = require('../lib/redis');

function toNumber(value) {
  if (value == null) {
    return 0;
  }

  if (typeof value === 'number') {
    return value;
  }

  if (typeof value === 'string') {
    return Number(value);
  }

  if (typeof value.toNumber === 'function') {
    return value.toNumber();
  }

  return Number(value);
}

function formatTransaksi(transaksi) {
  return {
    id: transaksi.id,
    nama_transaksi: transaksi.namaTransaksi,
    nominal: toNumber(transaksi.nominal),
    jenis_transaksi: transaksi.jenisTransaksi,
    status: transaksi.status,
    nama_pihak: transaksi.namaPihak,
    created_at: transaksi.createdAt,
    updated_at: transaksi.updatedAt,
  };
}

function success(res, data, statusCode = 200) {
  return res.status(statusCode).json({
    success: true,
    data,
  });
}

function failure(res, statusCode, message) {
  return res.status(statusCode).json({
    success: false,
    message,
  });
}

function handleServerError(res, error) {
  console.error(error);
  return failure(res, 500, 'Terjadi kesalahan server');
}

async function getAllTransaksi(req, res) {
  try {
    const where = {};

    if (req.query.status) {
      where.status = req.query.status;
    }

    if (req.query.jenis) {
      where.jenisTransaksi = req.query.jenis;
    }

    if (req.query.search) {
      where.OR = [
        { namaTransaksi: { contains: req.query.search, mode: 'insensitive' } },
        { namaPihak: { contains: req.query.search, mode: 'insensitive' } },
      ];
    }

    const transaksi = await prisma.transaksi.findMany({
      where,
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
    });

    return success(res, transaksi.map(formatTransaksi));
  } catch (error) {
    return handleServerError(res, error);
  }
}

async function getTransaksiById(req, res) {
  try {
    const transaksi = await prisma.transaksi.findUnique({
      where: {
        id: req.params.id,
      },
    });

    if (!transaksi) {
      return failure(res, 404, 'Transaksi tidak ditemukan');
    }

    return success(res, formatTransaksi(transaksi));
  } catch (error) {
    return handleServerError(res, error);
  }
}

async function createTransaksi(req, res) {
  try {
    const transaksi = await prisma.transaksi.create({
      data: {
        namaTransaksi: req.body.namaTransaksi,
        nominal: new Prisma.Decimal(req.body.nominal),
        jenisTransaksi: req.body.jenisTransaksi,
        status: req.body.status,
        namaPihak: req.body.namaPihak,
      },
    });

    await clearSummaryCache();

    return success(res, formatTransaksi(transaksi), 201);
  } catch (error) {
    return handleServerError(res, error);
  }
}

async function updateTransaksi(req, res) {
  try {
    const existing = await prisma.transaksi.findUnique({
      where: {
        id: req.params.id,
      },
    });

    if (!existing) {
      return failure(res, 404, 'Transaksi tidak ditemukan');
    }

    const updated = await prisma.transaksi.update({
      where: {
        id: req.params.id,
      },
      data: {
        namaTransaksi: req.body.namaTransaksi,
        nominal: new Prisma.Decimal(req.body.nominal),
        jenisTransaksi: req.body.jenisTransaksi,
        status: req.body.status,
        namaPihak: req.body.namaPihak,
      },
    });

    await clearSummaryCache();

    return success(res, formatTransaksi(updated));
  } catch (error) {
    return handleServerError(res, error);
  }
}

async function deleteTransaksi(req, res) {
  try {
    const existing = await prisma.transaksi.findUnique({
      where: {
        id: req.params.id,
      },
    });

    if (!existing) {
      return failure(res, 404, 'Transaksi tidak ditemukan');
    }

    const deleted = await prisma.transaksi.delete({
      where: {
        id: req.params.id,
      },
    });

    await clearSummaryCache();

    return success(res, formatTransaksi(deleted));
  } catch (error) {
    return handleServerError(res, error);
  }
}

async function getSummary(req, res) {
  const cacheKey = 'summary:transaksi';

  try {
    const cached = await getCachedSummary(cacheKey);
    if (cached) {
      return success(res, cached);
    }

    const [kasMasukResult, kasKeluarResult] = await Promise.all([
      prisma.transaksi.aggregate({
        where: {
          jenisTransaksi: 'KAS_MASUK',
        },
        _sum: {
          nominal: true,
        },
      }),
      prisma.transaksi.aggregate({
        where: {
          jenisTransaksi: 'KAS_KELUAR',
        },
        _sum: {
          nominal: true,
        },
      }),
    ]);

    const totalKasMasuk = toNumber(kasMasukResult._sum.nominal);
    const totalKasKeluar = toNumber(kasKeluarResult._sum.nominal);
    const summary = {
      total_kas_masuk: totalKasMasuk,
      total_kas_keluar: totalKasKeluar,
      saldo: totalKasMasuk - totalKasKeluar,
    };

    await setCachedSummary(cacheKey, summary);

    return success(res, summary);
  } catch (error) {
    return handleServerError(res, error);
  }
}

async function clearSummaryCache() {
  try {
    if (!redisClient.isOpen) {
      return;
    }

    await redisClient.del('summary:transaksi');
  } catch (error) {
    console.warn('Gagal membersihkan cache summary:', error.message);
  }
}

async function getCachedSummary(cacheKey) {
  try {
    if (!redisClient.isOpen) {
      return null;
    }

    const cached = await redisClient.get(cacheKey);
    if (!cached) {
      return null;
    }

    return JSON.parse(cached);
  } catch (error) {
    console.warn('Gagal membaca cache summary:', error.message);
    return null;
  }
}

async function setCachedSummary(cacheKey, summary) {
  try {
    if (!redisClient.isOpen) {
      return;
    }

    await redisClient.set(cacheKey, JSON.stringify(summary), {
      EX: 60,
    });
  } catch (error) {
    console.warn('Gagal menyimpan cache summary:', error.message);
  }
}

module.exports = {
  getAllTransaksi,
  getTransaksiById,
  createTransaksi,
  updateTransaksi,
  deleteTransaksi,
  getSummary,
};
