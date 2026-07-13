import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://hasan.shosio.com/api';

  static Duration get timeout {
    final seconds = int.tryParse(
      dotenv.env['REQUEST_TIMEOUT_SECONDS'] ?? '15',
    );

    return Duration(seconds: seconds ?? 15);
  }
}
