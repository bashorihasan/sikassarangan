import '../models/transaksi_model.dart';
import 'api_client.dart';

// Re-export supaya kode lama yang meng-import transaksi_service tetap melihat ApiException.
export 'api_client.dart' show ApiException;

class TransaksiService {
  TransaksiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<Transaksi>> getAllTransaksi() async {
    final data = await _client.get('/transaksi');
    final items = data['data'] as List<dynamic>? ?? const <dynamic>[];
    return items
        .map((item) => Transaksi.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Transaksi> getTransaksiById(int id) async {
    final data = await _client.get('/transaksi/$id');
    return Transaksi.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<Transaksi> createTransaksi(Transaksi transaksi) async {
    final data = await _client.post('/transaksi', body: transaksi.toJson());
    return Transaksi.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<Transaksi> updateTransaksi(int id, Transaksi transaksi) async {
    final data = await _client.put('/transaksi/$id', body: transaksi.toJson());
    return Transaksi.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteTransaksi(int id) async {
    await _client.delete('/transaksi/$id');
  }

  Future<Map<String, double>> getSummary() async {
    final data = await _client.get('/transaksi/summary');
    final summary = data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return {
      'total_kas_masuk': _toDouble(summary['total_kas_masuk']),
      'total_kas_keluar': _toDouble(summary['total_kas_keluar']),
      'saldo': _toDouble(summary['saldo']),
    };
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }
}
