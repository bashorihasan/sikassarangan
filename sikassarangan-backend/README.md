# siKasSarangan Backend

Backend Node.js + Express untuk pencatatan transaksi kas kegiatan RT/panitia seperti HUT RI dan PHBN, sekarang memakai Prisma ORM dan Redis cache.

## Tech Stack

- Node.js
- Express
- Prisma ORM
- PostgreSQL
- Redis
- Docker + Docker Compose
- `zod`
- `cors`
- `dotenv`

## Struktur Data

Model Prisma `Transaksi`:

- `id` auto increment primary key
- `namaTransaksi` string, maksimal 255 karakter
- `nominal` decimal 15,2
- `jenisTransaksi` enum `KAS_MASUK` / `KAS_KELUAR`
- `status` enum `REIMBURSE` / `LUNAS` / `PENDING`
- `namaPihak` string, maksimal 255 karakter
- `createdAt` default `now()`
- `updatedAt` otomatis saat update

Tabel database di-map ke `transaksi` dengan `@@map("transaksi")`.

## Environment Variable

Gunakan `.env` berikut:

```env
DB_HOST=db
DB_PORT=5432
DB_NAME=sikassarangan
DB_USER=sikassarangan_user
DB_PASSWORD=...
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=...
API_KEY=...
API_PORT=3001
DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?schema=public
```

## Endpoint API

- `GET /api/transaksi` - support query `status`, `jenis`, `search`
- `GET /api/transaksi/:id`
- `POST /api/transaksi`
- `PUT /api/transaksi/:id`
- `DELETE /api/transaksi/:id`
- `GET /api/transaksi/summary`

Endpoint mutating wajib mengirim header:

```http
x-api-key: <API_KEY>
```

## Docker

Dockerfile menjalankan `npx prisma generate` saat build, lalu container start menjalankan migrasi deploy sebelum server aktif.

## Pertama Kali Menjalankan

1. Isi `.env` sesuai environment lokal atau Docker.
2. Install dependency:

```bash
npm install
```

3. Jika ingin membuat migrasi dari host Windows, jalankan database dulu lalu override `DATABASE_URL` ke port host Docker (`127.0.0.1:5433`), misalnya:

```powershell
$env:DATABASE_URL="postgresql://sikassarangan_user:sikassarangan_password@127.0.0.1:5433/sikassarangan?schema=public"
npx prisma migrate dev --name init
```

Jika ingin jalur Docker penuh, langkah ini bisa dilewati karena image API akan menjalankan `prisma migrate deploy` saat start.

4. Generate Prisma Client jika belum otomatis terbuat:

```bash
npx prisma generate
```

5. Jalankan backend:

```bash
npm run dev
```

## Menjalankan dengan Docker

```bash
docker compose up -d --build
```

## Catatan

- Redis dipakai untuk cache `/api/transaksi/summary` selama 60 detik.
- Prisma Client dibuat sebagai singleton di `src/lib/prisma.js`.
- CORS dibuka untuk semua origin agar bisa dipakai oleh aplikasi mobile.
