import 'package:shelf/shelf.dart';

import '../auth/auth_service.dart';
import '../utils/responses.dart';

/// Requires a valid `Authorization: Bearer <token>` header and injects the
/// resolved `userId` into the request context for downstream handlers.
Middleware authMiddleware(AuthService auth) {
  return (Handler innerHandler) {
    return (Request request) async {
      final header = request.headers['authorization'];
      if (header == null || !header.startsWith('Bearer ')) {
        return unauthorized('Missing bearer token');
      }
      final token = header.substring('Bearer '.length);
      final userId = auth.verifyToken(token);
      if (userId == null) {
        return unauthorized('Invalid or expired token');
      }
      final updated = request.change(context: {'userId': userId});
      return innerHandler(updated);
    };
  };
}

extension RequestUser on Request {
  String get userId => context['userId'] as String;
}
