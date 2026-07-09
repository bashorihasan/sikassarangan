const { PrismaClient } = require('@prisma/client');

function resolveDatabaseUrl() {
  const databaseUrl = process.env.DATABASE_URL;

  if (databaseUrl && !databaseUrl.includes('${')) {
    return databaseUrl;
  }

  const host = process.env.DB_HOST;
  const port = process.env.DB_PORT;
  const database = process.env.DB_NAME;
  const user = process.env.DB_USER;
  const password = process.env.DB_PASSWORD;

  if (!host || !port || !database || !user || !password) {
    throw new Error('DATABASE_URL belum tersedia dan komponen database belum lengkap');
  }

  const resolved = `postgresql://${encodeURIComponent(user)}:${encodeURIComponent(password)}@${host}:${port}/${database}?schema=public`;
  process.env.DATABASE_URL = resolved;
  return resolved;
}

const globalForPrisma = globalThis;

if (!process.env.DATABASE_URL || process.env.DATABASE_URL.includes('${')) {
  resolveDatabaseUrl();
}

const prisma = globalForPrisma.__prismaClient || new PrismaClient();

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.__prismaClient = prisma;
}

module.exports = {
  prisma,
  resolveDatabaseUrl,
};
