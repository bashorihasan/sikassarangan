-- Migration: add tanggalTransaksi + User model + Transaksi.createdBy relation
--
-- STRATEGI AMAN UNTUK DATA PRODUCTION (expand -> backfill -> contract):
--   1. Buat enum + tabel users lebih dulu.
--   2. Seed 1 user default SEBELUM menyentuh tabel transaksi.
--   3. tanggalTransaksi ditambah dengan DEFAULT now() -> baris lama otomatis terisi.
--   4. createdById ditambah NULLABLE dulu, di-backfill ke user default,
--      baru kemudian dijadikan NOT NULL + dipasang foreign key.
-- Dengan urutan ini, tabel transaksi yang sudah ada isinya tidak akan error.

-- CreateEnum
CREATE TYPE "AuthProvider" AS ENUM ('EMAIL', 'GOOGLE');

-- CreateTable
CREATE TABLE "users" (
    "id" SERIAL NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "password" TEXT,
    "firebaseUid" TEXT,
    "authProvider" "AuthProvider" NOT NULL DEFAULT 'EMAIL',
    "fcmToken" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_firebaseUid_key" ON "users"("firebaseUid");

-- Seed user default untuk backfill data transaksi lama.
-- Idempotent: ON CONFLICT DO NOTHING agar aman kalau dijalankan ulang.
INSERT INTO "users" ("email", "name", "authProvider", "createdAt", "updatedAt")
VALUES ('system@sikassarangan.local', 'Sistem siKasSarangan', 'EMAIL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT ("email") DO NOTHING;

-- AlterTable: tanggalTransaksi non-nullable + DEFAULT now() (baris lama otomatis terisi now()).
ALTER TABLE "transaksi"
    ADD COLUMN "tanggalTransaksi" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- AlterTable: createdById ditambah NULLABLE dulu supaya tidak error di tabel yang sudah berisi data.
ALTER TABLE "transaksi"
    ADD COLUMN "createdById" INTEGER;

-- Backfill: assign semua transaksi lama ke user default.
UPDATE "transaksi"
SET "createdById" = (SELECT "id" FROM "users" WHERE "email" = 'system@sikassarangan.local')
WHERE "createdById" IS NULL;

-- Contract: setelah semua baris terisi, jadikan createdById NOT NULL.
ALTER TABLE "transaksi"
    ALTER COLUMN "createdById" SET NOT NULL;

-- CreateIndex
CREATE INDEX "transaksi_createdById_idx" ON "transaksi"("createdById");

-- CreateIndex
CREATE INDEX "transaksi_tanggalTransaksi_idx" ON "transaksi"("tanggalTransaksi");

-- AddForeignKey
ALTER TABLE "transaksi" ADD CONSTRAINT "transaksi_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
