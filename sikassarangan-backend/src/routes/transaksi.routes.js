const express = require('express');
const controller = require('../controllers/transaksi.controller');
const { authenticateApiKey } = require('../middleware/auth.middleware');
const {
  transaksiBodySchema,
  transaksiParamsSchema,
  transaksiQuerySchema,
  validateRequest,
} = require('../middleware/validate.middleware');

const router = express.Router();

router.get('/summary', controller.getSummary);
router.get('/', validateRequest(transaksiQuerySchema, 'query'), controller.getAllTransaksi);
router.get('/:id', validateRequest(transaksiParamsSchema, 'params'), controller.getTransaksiById);
router.post(
  '/',
  authenticateApiKey,
  validateRequest(transaksiBodySchema, 'body'),
  controller.createTransaksi
);
router.put(
  '/:id',
  authenticateApiKey,
  validateRequest(transaksiParamsSchema, 'params'),
  validateRequest(transaksiBodySchema, 'body'),
  controller.updateTransaksi
);
router.delete(
  '/:id',
  authenticateApiKey,
  validateRequest(transaksiParamsSchema, 'params'),
  controller.deleteTransaksi
);

module.exports = router;
