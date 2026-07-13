const express = require('express');
const { z } = require('zod');

const controller = require('../controllers/auth.controller');
const { firebaseAuth } = require('../middleware/firebaseAuth.middleware');
const { validateRequest } = require('../middleware/validate.middleware');

const router = express.Router();

// Semua endpoint auth butuh Firebase ID token yang valid.
router.use(firebaseAuth);

const fcmTokenBodySchema = z.object({
  fcmToken: z.string().trim().min(1, 'fcmToken wajib diisi'),
});

router.post('/sync-user', controller.syncUser);
router.post(
  '/fcm-token',
  validateRequest(fcmTokenBodySchema, 'body'),
  controller.updateFcmToken
);

module.exports = router;
