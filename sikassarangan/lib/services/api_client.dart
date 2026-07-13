import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;

  @override
  String toString() => message;
}

/// HTTP client bersama untuk semua service. Otomatis melampirkan Firebase ID
/// token sebagai `Authorization: Bearer <token>` di setiap request, dan
/// menyeragamkan parsing/penanganan error.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = '${ApiConfig.baseUrl}$path';
    if (query == null || query.isEmpty) {
      return Uri.parse(base);
    }
    final normalized =
        query.map((key, value) => MapEntry(key, value?.toString() ?? ''));
    return Uri.parse(base).replace(queryParameters: normalized);
  }

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  String? _encode(Object? body) => body == null ? null : jsonEncode(body);

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) =>
      _send(() async => _client.get(_uri(path, query), headers: await _headers()));

  Future<Map<String, dynamic>> post(String path, {Object? body}) =>
      _send(() async =>
          _client.post(_uri(path), headers: await _headers(), body: _encode(body)));

  Future<Map<String, dynamic>> put(String path, {Object? body}) =>
      _send(() async =>
          _client.put(_uri(path), headers: await _headers(), body: _encode(body)));

  Future<Map<String, dynamic>> patch(String path, {Object? body}) =>
      _send(() async =>
          _client.patch(_uri(path), headers: await _headers(), body: _encode(body)));

  Future<Map<String, dynamic>> delete(String path) =>
      _send(() async => _client.delete(_uri(path), headers: await _headers()));

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request().timeout(ApiConfig.timeout);
      final decoded = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is Map<String, dynamic> && decoded['success'] == false) {
          throw ApiException(
            _extractMessage(decoded, 'Request gagal'),
            statusCode: response.statusCode,
          );
        }
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return <String, dynamic>{'data': decoded};
      }

      throw ApiException(
        _extractMessage(
          decoded,
          'Server merespons dengan status ${response.statusCode}',
        ),
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet atau backend.',
      );
    } on HttpException {
      throw ApiException('Gagal memproses respon dari server.');
    } on FormatException {
      throw ApiException('Format respon dari server tidak valid.');
    } on TimeoutException {
      throw ApiException('Koneksi ke server timeout.');
    }
  }

  String _extractMessage(dynamic body, String fallback) {
    if (body is Map<String, dynamic>) {
      final message = body['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return fallback;
  }
}
