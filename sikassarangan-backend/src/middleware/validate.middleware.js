const { z } = require('zod');

const jenisTransaksiEnum = z.enum(['KAS_MASUK', 'KAS_KELUAR']);
const statusTransaksiEnum = z.enum(['REIMBURSE', 'LUNAS', 'PENDING']);

const transaksiBodySchema = z.object({
  namaTransaksi: z
    .string()
    .trim()
    .min(1, 'namaTransaksi wajib diisi')
    .max(255, 'namaTransaksi maksimal 255 karakter'),
  nominal: z.coerce.number().positive('nominal harus lebih dari 0'),
  jenisTransaksi: jenisTransaksiEnum,
  status: statusTransaksiEnum,
  namaPihak: z
    .string()
    .trim()
    .min(1, 'namaPihak wajib diisi')
    .max(255, 'namaPihak maksimal 255 karakter'),
  // Tanggal transaksi terjadi (diisi manual user). Menerima string tanggal / ISO,
  // dikoersi jadi Date. createdById TIDAK divalidasi di sini karena diambil dari req.user.
  tanggalTransaksi: z.coerce.date({
    errorMap: () => ({ message: 'tanggalTransaksi harus berupa tanggal yang valid' }),
  }),
});

const transaksiParamsSchema = z.object({
  id: z.coerce.number().int().positive('id harus berupa angka positif'),
});

const transaksiQuerySchema = z.object({
  status: statusTransaksiEnum.optional(),
  jenis: jenisTransaksiEnum.optional(),
  search: z.string().trim().optional(),
});

function formatError(error) {
  if (error instanceof z.ZodError) {
    return error.issues.map((issue) => ({
      path: issue.path.join('.'),
      message: issue.message,
    }));
  }

  return [{ path: '', message: 'Validasi gagal' }];
}

function validateRequest(schema, source = 'body') {
  return (req, res, next) => {
    const result = schema.safeParse(req[source]);

    if (!result.success) {
      return res.status(400).json({
        success: false,
        message: 'Validasi gagal',
        errors: formatError(result.error),
      });
    }

    req[source] = result.data;
    return next();
  };
}

module.exports = {
  jenisTransaksiEnum,
  statusTransaksiEnum,
  transaksiBodySchema,
  transaksiParamsSchema,
  transaksiQuerySchema,
  validateRequest,
};
