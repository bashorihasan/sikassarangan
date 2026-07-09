# siKasSarangan Backend

Backend Node.js + Express untuk pencatatan transaksi kas kegiatan RT/panitia seperti HUT RI atau PHBN.

## Tech Stack

- Node.js
- Express
- PostgreSQL
- Docker + Docker Compose
- `pg`
- `dotenv`
- `cors`
- `express-validator`

## Struktur Data

Tabel `transaksi` disiapkan otomatis saat aplikasi pertama kali berjalan:

- `id` auto increment primary key
- `nama_transaksi` wajib diisi
- `nominal` wajib diisi
- `jenis_transaksi` enum `KAS_MASUK` / `KAS_KELUAR`
- `status` enum `REIMBURSE` / `LUNAS` / `PENDING`
- `nama_pihak` wajib diisi
- `created_at` default `NOW()`
- `updated_at` default `NOW()` dan otomatis diperbarui saat update

## Persiapan

1. Masuk ke folder project:

```bash
cd sikassarangan-backend
```

2. Pastikan file `.env` sudah ada. File ini sudah disediakan dengan nilai awal, silakan sesuaikan jika perlu.

3. Pastikan Docker Desktop sudah berjalan.

## Menjalankan dengan Docker

```bash
docker compose up -d --build
```

Cek log API:

```bash
docker compose logs -f api
```

## Environment Variable

Gunakan file `.env` untuk konfigurasi runtime. Template ada di `.env.example`.

Contoh isi:

```env
PORT=3000
DB_HOST=db
DB_PORT=5432
DB_USER=sikassarangan_user
DB_PASSWORD=change-this-password
DB_NAME=sikassarangan_db
API_KEY=change-this-api-key
CORS_ORIGIN=*
```

## Auth API Key

Endpoint berikut wajib menyertakan header:

```http
x-api-key: change-this-api-key
```

Endpoint yang dilindungi:

- `POST /api/transaksi`
- `PUT /api/transaksi/:id`
- `DELETE /api/transaksi/:id`

## Endpoint API

- `GET /api/transaksi`
- `GET /api/transaksi/:id`
- `POST /api/transaksi`
- `PUT /api/transaksi/:id`
- `DELETE /api/transaksi/:id`
- `GET /api/transaksi/summary`

## Contoh Request

### Tambah transaksi

```bash
curl -X POST http://localhost:3000/api/transaksi \
  -H "Content-Type: application/json" \
  -H "x-api-key: change-this-api-key" \
  -d '{
    "nama_transaksi": "Iuran HUT RI",
    "nominal": 500000,
    "jenis_transaksi": "KAS_MASUK",
    "status": "LUNAS",
    "nama_pihak": "Warga RT 05"
  }'
```

### Ringkasan kas

```bash
curl http://localhost:3000/api/transaksi/summary
```

## Catatan Docker

- Service database hanya dibind ke `127.0.0.1` pada host, jadi tidak diekspos langsung ke publik.
- API menunggu database siap sebelum start.
- Data PostgreSQL disimpan di volume persisten `postgres_data`.
