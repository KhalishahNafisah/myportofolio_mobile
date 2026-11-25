import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  String get userMessage => switch (statusCode) {
    400 => 'Data tidak valid. Periksa kembali isian formulir.',
    401 => 'Sesi tidak berlaku. Silakan login kembali.',
    403 => 'Akun ini tidak memiliki izin untuk melakukan tindakan tersebut.',
    _ => 'Permintaan gagal (HTTP $statusCode). Silakan coba lagi.',
  };

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  static const _timeout = Duration(seconds: 20);

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<List<Project>> getProjects() async {
    final response = await _client
        .get(
          _uri('/api/v1/projects/'),
          headers: const {'Accept': 'application/json'},
        )
        .timeout(_timeout);
    _ensureSuccess(response);
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! List<dynamic>) {
      throw const FormatException('Expected a list of projects.');
    }
    return decoded
        .map((item) => Project.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _client
        .post(
          _uri('/api/v1/projects/'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Token $token',
          },
          body: jsonEncode(project.toJson()),
        )
        .timeout(_timeout);
    _ensureSuccess(response);
    return Project.fromJson(_decodeObject(response));
  }

  Future<String> obtainToken(String username, String password) async {
    final response = await _client
        .post(
          _uri('/api/v1/auth/token/'),
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(_timeout);
    _ensureSuccess(response);
    final token = _decodeObject(response)['token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('Expected an authentication token.');
    }
    return token;
  }

  Future<void> logout({required String token}) async {
    final response = await _client
        .post(
          _uri('/api/v1/auth/logout/'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Token $token',
          },
        )
        .timeout(_timeout);
    _ensureSuccess(response);
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object.');
    }
    return decoded;
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, response.body);
    }
  }

  void close() => _client.close();
}
