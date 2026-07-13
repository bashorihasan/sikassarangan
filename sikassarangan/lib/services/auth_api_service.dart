import '../models/app_user.dart';
import 'api_client.dart';

class AuthApiService {
  AuthApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// Sinkronisasi user ke database backend (dipanggil setelah login sukses).
  Future<AppUser> syncUser() async {
    final data = await _client.post('/auth/sync-user');
    return AppUser.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Simpan/update FCM token milik user yang sedang login.
  Future<AppUser> updateFcmToken(String fcmToken) async {
    final data = await _client.post('/auth/fcm-token', body: {
      'fcmToken': fcmToken,
    });
    return AppUser.fromJson(data['data'] as Map<String, dynamic>);
  }
}
