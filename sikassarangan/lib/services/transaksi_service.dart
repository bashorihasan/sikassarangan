import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/transaksi_model.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class TransaksiService {
  final http.Client _client;

  TransaksiService({http.Client? client}) : _client = client ?? http.Client();

  Uri _uri([String path = '']) {
    return Uri.parse('${ApiConfig.baseUrl}$path');
  }

  Map<String, String> _headers() => ApiConfig.headers;

  String _extractMessage(dynamic body, {String fallback = 'Terjadi kesalahan'}) {
    if (body is Map<String, dynamic>) {
      final message = body['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    return fallback;
  }

  Future<Map<String, dynamic>> _sendRequest(
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
            _extractMessage(decoded, fallback: 'Request gagal'),
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
          fallback: 'Server merespons dengan status ${response.statusCode}',
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

  Future<List<Transaksi>> getAllTransaksi() async {
    final data = await _sendRequest(
      () => _client.get(_uri('/transaksi'), headers: _headers()),
    );

    final items = data['data'] as List<dynamic>? ?? const <dynamic>[];
    return items
      .map((item) => Transaksi.fromJson(item as Map<String, dynamic>))
      .toList(growable: false);
  }

  Future<Transaksi> getTransaksiById(int id) async {
    final data = await _sendRequest(
      () => _client.get(_uri('/transaksi/$id'), headers: _headers()),
    );

    return Transaksi.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<Transaksi> createTransaksi(Transaksi transaksi) async {
    final data = await _sendRequest(
      () => _client.post(
        _uri('/transaksi'),
        headers: _headers(),
        body: jsonEncode(transaksi.toJson()),
      ),
    );

    return Transaksi.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<Transaksi> updateTransaksi(int id, Transaksi transaksi) async {
    final data = await _sendRequest(
      () => _client.put(
        _uri('/transaksi/$id'),
        headers: _headers(),
        body: jsonEncode(transaksi.toJson()),
      ),
    );

    return Transaksi.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteTransaksi(int id) async {
    await _sendRequest(
      () => _client.delete(_uri('/transaksi/$id'), headers: _headers()),
    );
  }

  Future<Map<String, double>> getSummary() async {
    final data = await _sendRequest(
      () => _client.get(_uri('/transaksi/summary'), headers: _headers()),
    );

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
