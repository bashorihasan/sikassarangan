const { Pool } = require('pg');
require('dotenv').config();

function requireEnv(name) {
  const value = process.env[name];

  if (!value) {
    throw new Error(`${name} harus diisi di file .env`);
  }

  return value;
}

const pool = new Pool({
  host: requireEnv('DB_HOST'),
  port: Number(requireEnv('DB_PORT')),
  user: requireEnv('DB_USER'),
  password: requireEnv('DB_PASSWORD'),
  database: requireEnv('DB_NAME'),
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});

const schemaSql = `
DO $$
BEGIN
  CREATE TYPE jenis_transaksi_enum AS ENUM ('KAS_MASUK', 'KAS_KELUAR');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE status_transaksi_enum AS ENUM ('REIMBURSE', 'LUNAS', 'PENDING');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS transaksi (
  id SERIAL PRIMARY KEY,
  nama_transaksi VARCHAR(255) NOT NULL,
  nominal NUMERIC(14,2) NOT NULL CHECK (nominal >= 0),
  jenis_transaksi jenis_transaksi_enum NOT NULL,
  status status_transaksi_enum NOT NULL,
  nama_pihak VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS transaksi_set_updated_at ON transaksi;
CREATE TRIGGER transaksi_set_updated_at
BEFORE UPDATE ON transaksi
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
`;

async function initializeDatabase() {
  const maxAttempts = Number(process.env.DB_INIT_MAX_ATTEMPTS || 20);
  const retryDelayMs = Number(process.env.DB_INIT_RETRY_DELAY_MS || 3000);

  for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
    try {
      await pool.query(schemaSql);
      return;
    } catch (error) {
      if (attempt === maxAttempts) {
        throw error;
      }

      console.log(
        `Database belum siap, mencoba lagi dalam ${retryDelayMs / 1000} detik... (percobaan ${attempt}/${maxAttempts})`
      );
      await new Promise((resolve) => setTimeout(resolve, retryDelayMs));
    }
  }
}

async function closeDatabase() {
  await pool.end();
}

async function query(text, params) {
  return pool.query(text, params);
}

module.exports = {
  pool,
  initializeDatabase,
  closeDatabase,
  query,
};
