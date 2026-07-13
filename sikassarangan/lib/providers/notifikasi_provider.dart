import 'package:flutter/foundation.dart';

import '../models/notifikasi_model.dart';
import '../services/api_client.dart';
import '../services/notifikasi_service.dart';

class NotifikasiProvider extends ChangeNotifier {
  NotifikasiProvider({NotifikasiService? service})
      : _service = service ?? NotifikasiService();

  final NotifikasiService _service;

  final List<Notifikasi> _items = [];
  int _unreadCount = 0;
  int _page = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _errorMessage = '';

  List<Notifikasi> get items => List.unmodifiable(_items);
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _page < _totalPages;
  String get errorMessage => _errorMessage;

  Future<void> refresh() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final result = await _service.getAllNotifikasi(page: 1, limit: 20);
      _items
        ..clear()
        ..addAll(result.items);
      _page = result.page;
      _totalPages = result.totalPages;
      await _loadUnreadCount();
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = 'Gagal memuat notifikasi: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore) {
      return;
    }
    _isLoadingMore = true;
    notifyListeners();
    try {
      final result = await _service.getAllNotifikasi(page: _page + 1, limit: 20);
      _items.addAll(result.items);
      _page = result.page;
      _totalPages = result.totalPages;
    } catch (_) {
      // Abaikan kegagalan load-more; user bisa scroll ulang.
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Dipakai untuk badge di home tanpa memuat seluruh daftar.
  Future<void> loadUnreadCount() async {
    await _loadUnreadCount();
    notifyListeners();
  }

  Future<void> _loadUnreadCount() async {
    try {
      _unreadCount = await _service.getUnreadCount();
    } catch (_) {
      // Biarkan nilai lama kalau gagal.
    }
  }

  Future<void> markAsRead(int id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1 || _items[index].isRead) {
      return;
    }

    // Optimistic update.
    _items[index] = _items[index].copyWith(isRead: true);
    if (_unreadCount > 0) {
      _unreadCount--;
    }
    notifyListeners();

    try {
      await _service.markAsRead(id);
    } catch (_) {
      await refresh(); // rollback dengan memuat ulang kondisi server.
    }
  }

  Future<void> markAllAsRead() async {
    for (var i = 0; i < _items.length; i++) {
      if (!_items[i].isRead) {
        _items[i] = _items[i].copyWith(isRead: true);
      }
    }
    _unreadCount = 0;
    notifyListeners();

    try {
      await _service.markAllAsRead();
    } catch (_) {
      await refresh();
    }
  }

  void reset() {
    _items.clear();
    _unreadCount = 0;
    _page = 1;
    _totalPages = 1;
    _errorMessage = '';
    notifyListeners();
  }
}
