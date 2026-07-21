import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Handles password hashing (salted PBKDF2-style stretching over HMAC-SHA256)
/// and signed, stateless session tokens (HMAC-signed JSON, similar shape to
/// a JWT but dependency-free) for the CRM API.
class AuthService {
  AuthService(this._secret);

  final String _secret;
  static const _iterations = 20000;
  static final _rand = Random.secure();

  String generateSalt() {
    final bytes = List<int>.generate(16, (_) => _rand.nextInt(256));
    return base64Url.encode(bytes);
  }

  String hashPassword(String password, String salt) {
    List<int> result = utf8.encode(password + salt);
    for (var i = 0; i < _iterations; i++) {
      result = Hmac(sha256, utf8.encode(salt)).convert(result).bytes;
    }
    return base64Url.encode(result);
  }

  bool verifyPassword(String password, String salt, String expectedHash) {
    final actual = hashPassword(password, salt);
    return _constantTimeEquals(actual, expectedHash);
  }

  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  /// Creates a signed token encoding {userId, exp}. Format: base64(payload).base64(signature)
  String issueToken(String userId, {Duration ttl = const Duration(days: 7)}) {
    final payload = jsonEncode({
      'sub': userId,
      'exp': DateTime.now().add(ttl).millisecondsSinceEpoch,
    });
    final payloadB64 = base64Url.encode(utf8.encode(payload));
    final sig = Hmac(sha256, utf8.encode(_secret)).convert(utf8.encode(payloadB64));
    final sigB64 = base64Url.encode(sig.bytes);
    return '$payloadB64.$sigB64';
  }

  /// Returns the userId if the token is valid and unexpired, else null.
  String? verifyToken(String token) {
    final parts = token.split('.');
    if (parts.length != 2) return null;
    final payloadB64 = parts[0];
    final sigB64 = parts[1];
    final expectedSig =
        Hmac(sha256, utf8.encode(_secret)).convert(utf8.encode(payloadB64));
    final expectedSigB64 = base64Url.encode(expectedSig.bytes);
    if (!_constantTimeEquals(sigB64, expectedSigB64)) return null;
    try {
      final payload =
          jsonDecode(utf8.decode(base64Url.decode(payloadB64))) as Map;
      final exp = payload['exp'] as int;
      if (DateTime.now().millisecondsSinceEpoch > exp) return null;
      return payload['sub'] as String;
    } catch (_) {
      return null;
    }
  }
}
