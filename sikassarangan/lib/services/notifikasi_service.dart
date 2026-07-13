import '../models/notifikasi_model.dart';
import 'api_client.dart';

class NotifikasiPage {
  const NotifikasiPage({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.total,
  });

  final List<Notifikasi> items;
  final int page;
  final int totalPages;
  final int total;
}

class NotifikasiService {
  NotifikasiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<NotifikasiPage> getAllNotifikasi({int page = 1, int limit = 20}) async {
    final data = await _client.get('/notifikasi', query: {
      'page': page,
      'limit': limit,
    });

    final items = (data['data'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => Notifikasi.fromJson(item as Map<String, dynamic>))
        .toList();

    final pagination = data['pagination'] as Map<String, dynamic>? ?? const {};

    return NotifikasiPage(
      items: items,
      page: (pagination['page'] as num?)?.toInt() ?? page,
      totalPages: (pagination['total_pages'] as num?)?.toInt() ?? 1,
      total: (pagination['total'] as num?)?.toInt() ?? items.length,
    );
  }

  Future<int> getUnreadCount() async {
    final data = await _client.get('/notifikasi/unread-count');
    final payload = data['data'] as Map<String, dynamic>? ?? const {};
    return (payload['unread_count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markAsRead(int id) async {
    await _client.patch('/notifikasi/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _client.patch('/notifikasi/read-all');
  }
}
