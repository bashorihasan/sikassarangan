-- CreateEnum
CREATE TYPE "JenisTransaksi" AS ENUM ('KAS_MASUK', 'KAS_KELUAR');

-- CreateEnum
CREATE TYPE "StatusTransaksi" AS ENUM ('REIMBURSE', 'LUNAS', 'PENDING');

-- CreateTable
CREATE TABLE "transaksi" (
    "id" SERIAL NOT NULL,
    "namaTransaksi" VARCHAR(255) NOT NULL,
    "nominal" DECIMAL(15,2) NOT NULL,
    "jenisTransaksi" "JenisTransaksi" NOT NULL,
    "status" "StatusTransaksi" NOT NULL,
    "namaPihak" VARCHAR(255) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "transaksi_pkey" PRIMARY KEY ("id")
);
