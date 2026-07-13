const express = require('express');
const controller = require('../controllers/transaksi.controller');
const { firebaseAuth } = require('../middleware/firebaseAuth.middleware');
const {
  transaksiBodySchema,
  transaksiParamsSchema,
  transaksiQuerySchema,
  validateRequest,
} = require('../middleware/validate.middleware');

const router = express.Router();

// Semua endpoint transaksi wajib login (Firebase ID token). req.user diisi oleh
// firebaseAuth, dan createdById transaksi diambil dari req.user.id.
router.use(firebaseAuth);

router.get('/summary', controller.getSummary);
router.get('/', validateRequest(transaksiQuerySchema, 'query'), controller.getAllTransaksi);
router.get('/:id', validateRequest(transaksiParamsSchema, 'params'), controller.getTransaksiById);
router.post(
  '/',
  validateRequest(transaksiBodySchema, 'body'),
  controller.createTransaksi
);
router.put(
  '/:id',
  validateRequest(transaksiParamsSchema, 'params'),
  validateRequest(transaksiBodySchema, 'body'),
  controller.updateTransaksi
);
router.delete(
  '/:id',
  validateRequest(transaksiParamsSchema, 'params'),
  controller.deleteTransaksi
);

module.exports = router;
