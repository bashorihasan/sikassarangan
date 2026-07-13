const express = require('express');
const { z } = require('zod');

const controller = require('../controllers/notifikasi.controller');
const { firebaseAuth } = require('../middleware/firebaseAuth.middleware');
const { validateRequest } = require('../middleware/validate.middleware');

const router = express.Router();

// Semua endpoint notifikasi wajib login.
router.use(firebaseAuth);

const notifikasiQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(20),
});

const notifikasiParamsSchema = z.object({
  id: z.coerce.number().int().positive('id harus berupa angka positif'),
});

// Route statis didaftarkan sebelum route berparameter (/:id/read).
router.get('/', validateRequest(notifikasiQuerySchema, 'query'), controller.getAllNotifikasi);
router.get('/unread-count', controller.getUnreadCount);
router.patch('/read-all', controller.markAllRead);
router.patch(
  '/:id/read',
  validateRequest(notifikasiParamsSchema, 'params'),
  controller.markRead
);

module.exports = router;
