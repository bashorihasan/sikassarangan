class Transaksi {
  const Transaksi({
    this.id,
    required this.namaTransaksi,
    required this.nominal,
    required this.jenisTransaksi,
    required this.status,
    required this.namaPihak,
    this.createdAt,
  });

  final int? id;
  final String namaTransaksi;
  final double nominal;
  final String jenisTransaksi;
  final String status;
  final String namaPihak;
  final DateTime? createdAt;

  bool get isKasMasuk => jenisTransaksi == 'KAS_MASUK';

  bool get isKasKeluar => jenisTransaksi == 'KAS_KELUAR';

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      id: _parseInt(json['id']),
      namaTransaksi: (json['nama_transaksi'] ?? '').toString(),
      nominal: _parseNominal(json['nominal']),
      jenisTransaksi: (json['jenis_transaksi'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      namaPihak: (json['nama_pihak'] ?? '').toString(),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_transaksi': namaTransaksi,
      'nominal': nominal,
      'jenis_transaksi': jenisTransaksi,
      'status': status,
      'nama_pihak': namaPihak,
    };
  }

  Transaksi copyWith({
    int? id,
    String? namaTransaksi,
    double? nominal,
    String? jenisTransaksi,
    String? status,
    String? namaPihak,
    DateTime? createdAt,
  }) {
    return Transaksi(
      id: id ?? this.id,
      namaTransaksi: namaTransaksi ?? this.namaTransaksi,
      nominal: nominal ?? this.nominal,
      jenisTransaksi: jenisTransaksi ?? this.jenisTransaksi,
      status: status ?? this.status,
      namaPihak: namaPihak ?? this.namaPihak,
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
}
