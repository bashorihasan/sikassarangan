const express = require('express');
const controller = require('../controllers/transaksi.controller');
const { authenticateApiKey } = require('../middleware/auth.middleware');
const {
  createTransaksiValidation,
  updateTransaksiValidation,
  idValidation,
  handleValidation,
} = require('../middleware/validate.middleware');

const router = express.Router();

router.get('/summary', controller.getSummary);
router.get('/', controller.getAllTransaksi);
router.get('/:id', idValidation, handleValidation, controller.getTransaksiById);
router.post(
  '/',
  authenticateApiKey,
  createTransaksiValidation,
  handleValidation,
  controller.createTransaksi
);
router.put(
  '/:id',
  authenticateApiKey,
  idValidation,
  handleValidation,
  updateTransaksiValidation,
  handleValidation,
  controller.updateTransaksi
);
router.delete(
  '/:id',
  authenticateApiKey,
  idValidation,
  handleValidation,
  controller.deleteTransaksi
);

module.exports = router;
