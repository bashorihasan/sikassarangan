class Transaksi {
  const Transaksi({
    this.id,
    required this.namaTransaksi,
    required this.nominal,
    required this.jenisTransaksi,
    required this.status,
    required this.namaPihak,
    required this.tanggalTransaksi,
    this.createdById,
    this.createdByName,
    this.createdByEmail,
    this.createdAt,
  });

  final int? id;
  final String namaTransaksi;
  final double nominal;
  final String jenisTransaksi;
  final String status;
  final String namaPihak;

  /// Tanggal transaksi terjadi (diisi manual oleh user), bisa berbeda dari
  /// [createdAt] yaitu waktu data diinput ke sistem.
  final DateTime tanggalTransaksi;

  /// Info penginput transaksi (read-only, tidak dikirim saat create/update —
  /// backend mengisi createdById otomatis dari user yang sedang login).
  final int? createdById;
  final String? createdByName;
  final String? createdByEmail;

  final DateTime? createdAt;

  bool get isKasMasuk => jenisTransaksi == 'KAS_MASUK';

  bool get isKasKeluar => jenisTransaksi == 'KAS_KELUAR';

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    final createdBy = json['created_by'];

    return Transaksi(
      id: _parseInt(json['id']),
      namaTransaksi: (json['nama_transaksi'] ?? '').toString(),
      nominal: _parseNominal(json['nominal']),
      jenisTransaksi: (json['jenis_transaksi'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      namaPihak: (json['nama_pihak'] ?? '').toString(),
      tanggalTransaksi: _parseDateTime(json['tanggal_transaksi']) ??
          _parseDateTime(json['created_at']) ??
          DateTime.now(),
      createdById: _parseInt(json['created_by_id']),
      createdByName: createdBy is Map<String, dynamic>
          ? createdBy['name']?.toString()
          : null,
      createdByEmail: createdBy is Map<String, dynamic>
          ? createdBy['email']?.toString()
          : null,
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  /// Payload untuk create/update. Backend memvalidasi body dalam camelCase
  /// (namaTransaksi, jenisTransaksi, dst) dan mengisi createdById sendiri dari
  /// user yang login, jadi field itu TIDAK disertakan di sini.
  Map<String, dynamic> toJson() {
    return {
      'namaTransaksi': namaTransaksi,
      'nominal': nominal,
      'jenisTransaksi': jenisTransaksi,
      'status': status,
      'namaPihak': namaPihak,
      'tanggalTransaksi': _dateOnly(tanggalTransaksi),
    };
  }

  Transaksi copyWith({
    int? id,
    String? namaTransaksi,
    double? nominal,
    String? jenisTransaksi,
    String? status,
    String? namaPihak,
    DateTime? tanggalTransaksi,
    int? createdById,
    String? createdByName,
    String? createdByEmail,
    DateTime? createdAt,
  }) {
    return Transaksi(
      id: id ?? this.id,
      namaTransaksi: namaTransaksi ?? this.namaTransaksi,
      nominal: nominal ?? this.nominal,
      jenisTransaksi: jenisTransaksi ?? this.jenisTransaksi,
      status: status ?? this.status,
      namaPihak: namaPihak ?? this.namaPihak,
      tanggalTransaksi: tanggalTransaksi ?? this.tanggalTransaksi,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      createdByEmail: createdByEmail ?? this.createdByEmail,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '');
  }

  static double _parseNominal(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }

  /// Serialisasi tanggal saja (yyyy-MM-dd) supaya tidak tergeser oleh zona waktu.
  static String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
