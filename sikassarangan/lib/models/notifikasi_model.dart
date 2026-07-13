class Notifikasi {
  const Notifikasi({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.relatedId,
    required this.isRead,
    this.createdAt,
  });

  final int id;
  final String title;
  final String body;
  final String type;
  final int? relatedId;
  final bool isRead;
  final DateTime? createdAt;

  bool get isTransaksi =>
      type == 'TRANSAKSI_BARU' ||
      type == 'TRANSAKSI_UPDATE' ||
      type == 'TRANSAKSI_HAPUS';

  factory Notifikasi.fromJson(Map<String, dynamic> json) {
    return Notifikasi(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      type: (json['type'] ?? 'UMUM').toString(),
      relatedId: (json['related_id'] as num?)?.toInt(),
      isRead: json['is_read'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Notifikasi copyWith({bool? isRead}) {
    return Notifikasi(
      id: id,
      title: title,
      body: body,
      type: type,
      relatedId: relatedId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
