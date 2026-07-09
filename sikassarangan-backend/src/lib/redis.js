const { createClient } = require('redis');

const globalForRedis = globalThis;

function buildRedisClient() {
  const host = process.env.REDIS_HOST || 'redis';
  const port = Number(process.env.REDIS_PORT || 6379);
  const password = process.env.REDIS_PASSWORD;

  return createClient({
    socket: {
      host,
      port,
    },
    password: password || undefined,
  });
}

const redisClient = globalForRedis.__redisClient || buildRedisClient();

if (process.env.NODE_ENV !== 'production') {
  globalForRedis.__redisClient = redisClient;
}

redisClient.on('error', (error) => {
  console.error('Redis error:', error.message);
});

module.exports = {
  redisClient,
};
