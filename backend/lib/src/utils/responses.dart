import 'dart:convert';

import 'package:shelf/shelf.dart';

Response jsonResponse(Object? data, {int status = 200}) {
  return Response(
    status,
    body: jsonEncode(data),
    headers: {'content-type': 'application/json'},
  );
}

Response jsonError(String message, {int status = 400}) {
  return jsonResponse({'error': message}, status: status);
}

/// Standard envelope for paginated list endpoints.
Response jsonListResponse(List<dynamic> items, int total) {
  return jsonResponse({'items': items, 'total': total});
}

Response notFound(String what) => jsonError('$what not found', status: 404);

Response unauthorized([String message = 'Unauthorized']) =>
    jsonError(message, status: 401);

/// Parses the request body as a JSON map; returns null (and a 400 to the
/// caller) if the body is missing or malformed.
Future<Map<String, dynamic>?> readJsonBody(Request request) async {
  try {
    final body = await request.readAsString();
    if (body.isEmpty) return {};
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  } catch (_) {
    return null;
  }
}
