require('dotenv').config();

const cors = require('cors');
const express = require('express');

require('./config/firebase'); // inisialisasi Firebase Admin SDK saat startup

const transaksiRoutes = require('./routes/transaksi.routes');
const authRoutes = require('./routes/auth.routes');
const notifikasiRoutes = require('./routes/notifikasi.routes');
const { prisma, resolveDatabaseUrl } = require('./lib/prisma');
const { redisClient } = require('./lib/redis');

const app = express();
const port = Number(process.env.API_PORT || process.env.PORT || 443);
let server;

async function connectServices() {
  resolveDatabaseUrl();

  await prisma.$connect();

  try {
    if (!redisClient.isOpen) {
      await redisClient.connect();
    }
  } catch (error) {
    console.warn('Redis tidak tersedia saat startup, cache summary akan dinonaktifkan sementara:', error.message);
  }
}

app.disable('x-powered-by');
app.use(cors());
app.use(express.json({ limit: '1mb' }));

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
app.use('/api/auth', authRoutes);
app.use('/api/notifikasi', notifikasiRoutes);

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
    await connectServices();

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

  try {
    if (redisClient.isOpen) {
      await redisClient.quit();
    }
  } catch (error) {
    console.warn('Gagal menutup Redis dengan bersih:', error.message);
  }

  await prisma.$disconnect();
  process.exit(0);
}

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));

startServer();
