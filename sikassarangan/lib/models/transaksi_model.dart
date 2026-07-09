class Transaksi {
  const Transaksi({
    this.id,
    required this.namaTransaksi,
    required this.nominal,
    required this.jenisTransaksi,
    required this.status,
    required this.namaPihak,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String namaTransaksi;
  final double nominal;
  final String jenisTransaksi;
  final String status;
  final String namaPihak;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      id: json['id'] as int?,
      namaTransaksi: (json['nama_transaksi'] ?? '') as String,
      nominal: _parseNominal(json['nominal']),
      jenisTransaksi: (json['jenis_transaksi'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      namaPihak: (json['nama_pihak'] ?? '') as String,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
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
    DateTime? updatedAt,
  }) {
    return Transaksi(
      id: id ?? this.id,
      namaTransaksi: namaTransaksi ?? this.namaTransaksi,
      nominal: nominal ?? this.nominal,
      jenisTransaksi: jenisTransaksi ?? this.jenisTransaksi,
      status: status ?? this.status,
      namaPihak: namaPihak ?? this.namaPihak,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
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
