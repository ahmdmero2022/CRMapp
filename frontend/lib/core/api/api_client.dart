import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// Thin REST client for the CRM backend. Base URL defaults to same-origin
/// (empty string) so it works when the Flutter web build is served directly
/// by the Dart backend; override with --dart-define=API_BASE_URL=http://host:port
/// for local development against a separately-running `flutter run -d web-server`.
class ApiClient {
  ApiClient({required this.tokenProvider});

  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  final String? Function() tokenProvider;
  final http.Client _client = http.Client();

  Uri _uri(String path, [Map<String, String>? query]) {
    final cleanQuery = query == null
        ? null
        : (Map<String, String>.from(query)
          ..removeWhere((key, value) => value.isEmpty));
    return Uri.parse('$baseUrl/api$path')
        .replace(queryParameters: cleanQuery?.isEmpty == true ? null : cleanQuery);
  }

  Map<String, String> get _headers {
    final token = tokenProvider();
    return {
      'content-type': 'application/json',
      if (token != null) 'authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final res = await _client.get(_uri(path, query), headers: _headers);
    return _handle(res);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final res = await _client.post(_uri(path),
        headers: _headers, body: body == null ? null : jsonEncode(body));
    return _handle(res);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final res = await _client.put(_uri(path),
        headers: _headers, body: body == null ? null : jsonEncode(body));
    return _handle(res);
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    final res = await _client.patch(_uri(path),
        headers: _headers, body: body == null ? null : jsonEncode(body));
    return _handle(res);
  }

  Future<dynamic> delete(String path) async {
    final res = await _client.delete(_uri(path), headers: _headers);
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    if (res.statusCode == 204) return null;
    dynamic decoded;
    try {
      decoded = res.body.isEmpty ? null : jsonDecode(res.body);
    } catch (_) {
      decoded = null;
    }
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decoded;
    }
    final message = decoded is Map && decoded['error'] != null
        ? decoded['error'] as String
        : 'Request failed (${res.statusCode})';
    throw ApiException(message, statusCode: res.statusCode);
  }
}
