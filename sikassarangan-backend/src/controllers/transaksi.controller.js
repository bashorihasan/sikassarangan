const { query } = require('../config/db');

function formatTransaksi(row) {
  return {
    id: row.id,
    nama_transaksi: row.nama_transaksi,
    nominal: Number(row.nominal),
    jenis_transaksi: row.jenis_transaksi,
    status: row.status,
    nama_pihak: row.nama_pihak,
    created_at: row.created_at,
    updated_at: row.updated_at,
  };
}

function handleServerError(res, error) {
  console.error(error);
  return res.status(500).json({
    success: false,
    message: 'Terjadi kesalahan server',
  });
}

async function getAllTransaksi(req, res) {
  try {
    const result = await query(
      'SELECT * FROM transaksi ORDER BY created_at DESC, id DESC'
    );

    return res.json({
      success: true,
      data: result.rows.map(formatTransaksi),
    });
  } catch (error) {
    return handleServerError(res, error);
  }
}

async function getTransaksiById(req, res) {
  try {
    const { id } = req.params;
    const result = await query('SELECT * FROM transaksi WHERE id = $1', [id]);

    if (result.rowCount === 0) {
      return res.status(404).json({
        success: false,
        message: 'Transaksi tidak ditemukan',
      });
    }

    return res.json({
      success: true,
      data: formatTransaksi(result.rows[0]),
    });
  } catch (error) {
    return handleServerError(res, error);
  }
}

async function createTransaksi(req, res) {
  try {
    const { nama_transaksi, nominal, jenis_transaksi, status, nama_pihak } =
      req.body;

    const result = await query(
      `
      INSERT INTO transaksi (
        nama_transaksi,
        nominal,
        jenis_transaksi,
        status,
        nama_pihak
      )
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
      `,
      [nama_transaksi, nominal, jenis_transaksi, status, nama_pihak]
    );

    return res.status(201).json({
      success: true,
      data: formatTransaksi(result.rows[0]),
    });
  } catch (error) {
    return handleServerError(res, error);
  }
}

async function updateTransaksi(req, res) {
  try {
    const { id } = req.params;
    const { nama_transaksi, nominal, jenis_transaksi, status, nama_pihak } =
      req.body;

    const result = await query(
      `
      UPDATE transaksi
      SET
        nama_transaksi = $1,
        nominal = $2,
        jenis_transaksi = $3,
        status = $4,
        nama_pihak = $5,
        updated_at = NOW()
      WHERE id = $6
      RETURNING *
      `,
      [nama_transaksi, nominal, jenis_transaksi, status, nama_pihak, id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        success: false,
        message: 'Transaksi tidak ditemukan',
      });
    }

    return res.json({
      success: true,
      data: formatTransaksi(result.rows[0]),
    });
  } catch (error) {
    return handleServerError(res, error);
  }
}

async function deleteTransaksi(req, res) {
  try {
    const { id } = req.params;
    const result = await query('DELETE FROM transaksi WHERE id = $1 RETURNING *', [
      id,
    ]);

    if (result.rowCount === 0) {
      return res.status(404).json({
        success: false,
        message: 'Transaksi tidak ditemukan',
      });
    }

    return res.json({
      success: true,
      message: 'Transaksi berhasil dihapus',
      data: formatTransaksi(result.rows[0]),
    });
  } catch (error) {
    return handleServerError(res, error);
  }
}

async function getSummary(req, res) {
  try {
    const result = await query(`
      SELECT
        COALESCE(SUM(CASE WHEN jenis_transaksi = 'KAS_MASUK' THEN nominal ELSE 0 END), 0) AS total_kas_masuk,
        COALESCE(SUM(CASE WHEN jenis_transaksi = 'KAS_KELUAR' THEN nominal ELSE 0 END), 0) AS total_kas_keluar
      FROM transaksi
    `);

    const summary = result.rows[0];
    const totalKasMasuk = Number(summary.total_kas_masuk || 0);
    const totalKasKeluar = Number(summary.total_kas_keluar || 0);

    return res.json({
      success: true,
      data: {
        total_kas_masuk: totalKasMasuk,
        total_kas_keluar: totalKasKeluar,
        saldo: totalKasMasuk - totalKasKeluar,
      },
    });
  } catch (error) {
    return handleServerError(res, error);
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
