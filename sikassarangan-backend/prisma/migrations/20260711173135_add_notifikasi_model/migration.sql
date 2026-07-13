-- CreateEnum
CREATE TYPE "NotifikasiType" AS ENUM ('TRANSAKSI_BARU', 'TRANSAKSI_UPDATE', 'TRANSAKSI_HAPUS', 'UMUM');

-- CreateTable
CREATE TABLE "notifikasi" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "type" "NotifikasiType" NOT NULL DEFAULT 'TRANSAKSI_BARU',
    "relatedId" INTEGER,
    "isRead" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notifikasi_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "notifikasi_userId_isRead_idx" ON "notifikasi"("userId", "isRead");

-- CreateIndex
CREATE INDEX "notifikasi_userId_createdAt_idx" ON "notifikasi"("userId", "createdAt");

-- AddForeignKey
ALTER TABLE "notifikasi" ADD CONSTRAINT "notifikasi_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
