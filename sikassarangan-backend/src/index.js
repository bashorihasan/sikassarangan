const express = require('express');
const cors = require('cors');
require('dotenv').config();

const transaksiRoutes = require('./routes/transaksi.routes');
const { initializeDatabase, closeDatabase } = require('./config/db');

const app = express();
const port = Number(process.env.PORT || 3000);
let server;

function buildCorsOptions() {
  const corsOrigin = process.env.CORS_ORIGIN;

  if (!corsOrigin || corsOrigin === '*') {
    return undefined;
  }

  return {
    origin: corsOrigin
      .split(',')
      .map((origin) => origin.trim())
      .filter(Boolean),
  };
}

app.disable('x-powered-by');
app.use(cors(buildCorsOptions()));
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({
    success: true,
    data: {
      status: 'ok',
      service: 'siKasSarangan backend',
    },
  });
});

app.use('/api/transaksi', transaksiRoutes);

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint tidak ditemukan',
  });
});

app.use((err, req, res, next) => {
  console.error(err);

  if (res.headersSent) {
    return next(err);
  }

  return res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Terjadi kesalahan server',
  });
});

async function startServer() {
  try {
    await initializeDatabase();

    server = app.listen(port, () => {
      console.log(`siKasSarangan backend berjalan di port ${port}`);
    });
  } catch (error) {
    console.error('Gagal memulai server:', error);
    process.exit(1);
  }
}

async function shutdown(signal) {
  console.log(`Menerima ${signal}, menghentikan server...`);

  if (server) {
    await new Promise((resolve) => server.close(resolve));
  }

  await closeDatabase();
  process.exit(0);
}

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));

startServer();
