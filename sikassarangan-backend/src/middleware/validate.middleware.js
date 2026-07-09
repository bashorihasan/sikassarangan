const { body, param, validationResult } = require('express-validator');

const allowedJenisTransaksi = ['KAS_MASUK', 'KAS_KELUAR'];
const allowedStatus = ['REIMBURSE', 'LUNAS', 'PENDING'];

const createTransaksiValidation = [
  body('nama_transaksi')
    .trim()
    .notEmpty()
    .withMessage('nama_transaksi wajib diisi')
    .isLength({ max: 255 })
    .withMessage('nama_transaksi maksimal 255 karakter'),
  body('nominal')
    .notEmpty()
    .withMessage('nominal wajib diisi')
    .isFloat({ min: 0 })
    .withMessage('nominal harus berupa angka yang tidak negatif')
    .toFloat(),
  body('jenis_transaksi')
    .notEmpty()
    .withMessage('jenis_transaksi wajib diisi')
    .isIn(allowedJenisTransaksi)
    .withMessage('jenis_transaksi harus KAS_MASUK atau KAS_KELUAR'),
  body('status')
    .notEmpty()
    .withMessage('status wajib diisi')
    .isIn(allowedStatus)
    .withMessage('status harus REIMBURSE, LUNAS, atau PENDING'),
  body('nama_pihak')
    .trim()
    .notEmpty()
    .withMessage('nama_pihak wajib diisi')
    .isLength({ max: 255 })
    .withMessage('nama_pihak maksimal 255 karakter'),
];

const updateTransaksiValidation = [...createTransaksiValidation];

const idValidation = [
  param('id')
    .isInt({ gt: 0 })
    .withMessage('id harus berupa angka positif')
    .toInt(),
];

function handleValidation(req, res, next) {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validasi gagal',
      errors: errors.array(),
    });
  }

  return next();
}

module.exports = {
  createTransaksiValidation,
  updateTransaksiValidation,
  idValidation,
  handleValidation,
};
