import 'package:flutter/foundation.dart';

import '../models/transaksi_model.dart';
import '../services/transaksi_service.dart';

class TransaksiProvider extends ChangeNotifier {
  TransaksiProvider(this._service);

  final TransaksiService _service;

  List<Transaksi> _transaksi = [];
  double _totalKasMasuk = 0;
  double _totalKasKeluar = 0;
  double _saldo = 0;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String _errorMessage = '';
  String _searchQuery = '';
  String _statusFilter = '';

  List<Transaksi> get transaksi => List.unmodifiable(_transaksi);
  double get totalKasMasuk => _totalKasMasuk;
  double get totalKasKeluar => _totalKasKeluar;
  double get saldo => _saldo;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  List<Transaksi> get filteredTransaksi {
    final query = _searchQuery.trim().toLowerCase();

    return _transaksi.where((transaksi) {
      final matchesSearch = query.isEmpty ||
          transaksi.namaTransaksi.toLowerCase().contains(query) ||
          transaksi.namaPihak.toLowerCase().contains(query) ||
          transaksi.status.toLowerCase().contains(query);
      final matchesStatus =
          _statusFilter.isEmpty || transaksi.status == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  List<Transaksi> get recentTransaksi =>
      _transaksi.take(10).toList(growable: false);

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setStatusFilter(String value) {
    _statusFilter = value;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = '';
    notifyListeners();
  }

  Future<void> loadDashboard() async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final results = await Future.wait<dynamic>([
        _service.getAllTransaksi(),
        _service.getSummary(),
      ]);

      final transaksiResult = results[0] as List<Transaksi>;
      final summaryResult = results[1] as Map<String, double>;

      _transaksi = transaksiResult;
      _totalKasMasuk = summaryResult['total_kas_masuk'] ?? 0;
      _totalKasKeluar = summaryResult['total_kas_keluar'] ?? 0;
      _saldo = summaryResult['saldo'] ?? 0;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = 'Gagal memuat data: $error';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTransaksi() async {
    _setLoading(true);
    _errorMessage = '';

    try {
      _transaksi = await _service.getAllTransaksi();
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = 'Gagal memuat data transaksi: $error';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadSummary() async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final summary = await _service.getSummary();
      _totalKasMasuk = summary['total_kas_masuk'] ?? 0;
      _totalKasKeluar = summary['total_kas_keluar'] ?? 0;
      _saldo = summary['saldo'] ?? 0;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = 'Gagal memuat ringkasan: $error';
    } finally {
      _setLoading(false);
    }
  }

  Future<Transaksi> getTransaksiById(int id) {
    return _service.getTransaksiById(id);
  }

  Future<Transaksi?> createTransaksi(Transaksi transaksi) async {
    return _submitOperation(() async {
      final created = await _service.createTransaksi(transaksi);
      await loadDashboard();
      return created;
    });
  }

  Future<Transaksi?> updateTransaksi(int id, Transaksi transaksi) async {
    return _submitOperation(() async {
      final updated = await _service.updateTransaksi(id, transaksi);
      await loadDashboard();
      return updated;
    });
  }

  Future<void> deleteTransaksi(int id) async {
    await _submitOperation(() async {
      await _service.deleteTransaksi(id);
      await loadDashboard();
      return null;
    });
  }

  Future<T?> _submitOperation<T>(Future<T> Function() action) async {
    _setSubmitting(true);
    _errorMessage = '';

    try {
      return await action();
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return null;
    } catch (error) {
      _errorMessage = 'Terjadi kesalahan: $error';
      return null;
    } finally {
      _setSubmitting(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }
}
