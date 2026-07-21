import 'package:shelf/shelf.dart';

/// [allowedOrigin] defaults to '*' for zero-config local development (the
/// production deployment serves the frontend from the same origin as the
/// API, so CORS doesn't even apply there). Set ALLOWED_ORIGIN to a specific
/// origin to lock this down when the API is exposed cross-origin.
Middleware corsMiddleware({String allowedOrigin = '*'}) {
  final headers = {
    'Access-Control-Allow-Origin': allowedOrigin,
    'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
  };

  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: headers);
      }
      final response = await innerHandler(request);
      return response.change(headers: {...headers, ...response.headers});
    };
  };
}
