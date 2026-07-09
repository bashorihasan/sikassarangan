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

module.exports = {
  authenticateApiKey,
};
