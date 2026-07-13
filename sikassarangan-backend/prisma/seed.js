// Seed sederhana: memastikan ada 1 user default.
//
// Untuk backfill data production, pembuatan user default SUDAH ditangani di
// dalam migration (lihat migrations/*_add_tanggal_transaksi_and_user_model).
// Seed ini berguna untuk environment baru / lokal (mis. setelah `prisma migrate reset`)
// supaya selalu tersedia user default. Bersifat idempotent (aman dijalankan berkali-kali).
//
// Jalankan dengan: npx prisma db seed

const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const DEFAULT_USER_EMAIL = 'system@sikassarangan.local';

async function main() {
  const user = await prisma.user.upsert({
    where: { email: DEFAULT_USER_EMAIL },
    update: {},
    create: {
      email: DEFAULT_USER_EMAIL,
      name: 'Sistem siKasSarangan',
      authProvider: 'EMAIL',
    },
  });

  console.log(`User default siap: #${user.id} <${user.email}>`);
}

main()
  .catch((error) => {
    console.error('Gagal menjalankan seed:', error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
