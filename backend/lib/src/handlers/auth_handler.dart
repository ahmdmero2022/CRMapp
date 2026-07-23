import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../auth/auth_service.dart';
import '../db/database.dart';
import '../middleware/auth_middleware.dart';
import '../models/models.dart';
import '../utils/responses.dart';

const _avatarColors = [
  '#6366F1',
  '#EC4899',
  '#22C55E',
  '#F59E0B',
  '#3B82F6',
  '#EF4444',
  '#14B8A6',
  '#A855F7',
];

class AuthHandler {
  AuthHandler(this.appDb, this.auth);

  final AppDatabase appDb;
  final AuthService auth;

  Router get router {
    final router = Router();
    router.post('/register', _register);
    router.post('/login', _login);
    router.get('/me', Pipeline().addMiddleware(authMiddleware(auth)).addHandler(_me));
    router.put('/change-password',
        Pipeline().addMiddleware(authMiddleware(auth)).addHandler(_changePassword));
    return router;
  }

  Future<Response> _register(Request request) async {
    final body = await readJsonBody(request);
    if (body == null) return jsonError('Invalid JSON body');

    final name = (body['name'] as String?)?.trim();
    final email = (body['email'] as String?)?.trim().toLowerCase();
    final password = body['password'] as String?;

    if (name == null || name.isEmpty) return jsonError('Name is required');
    if (email == null || email.isEmpty) return jsonError('Email is required');
    if (password == null || password.length < 6) {
      return jsonError('Password must be at least 6 characters');
    }

    final existing = appDb.db
        .select('SELECT id FROM users WHERE email = ?', [email]);
    if (existing.isNotEmpty) {
      return jsonError('An account with this email already exists', status: 409);
    }

    final id = AppDatabase.uuid.v4();
    final salt = auth.generateSalt();
    final hash = auth.hashPassword(password, salt);
    final now = DateTime.now().toIso8601String();
    final color = _avatarColors[id.hashCode % _avatarColors.length];

    appDb.db.execute(
      'INSERT INTO users (id, name, email, password_hash, password_salt, role, avatar_color, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [id, name, email, hash, salt, 'member', color, now],
    );

    final token = auth.issueToken(id);
    final user = User(
      id: id,
      name: name,
      email: email,
      role: 'member',
      avatarColor: color,
      createdAt: now,
    );
    return jsonResponse({'token': token, 'user': user.toJson()}, status: 201);
  }

  Future<Response> _login(Request request) async {
    final body = await readJsonBody(request);
    if (body == null) return jsonError('Invalid JSON body');

    final email = (body['email'] as String?)?.trim().toLowerCase();
    final password = body['password'] as String?;
    if (email == null || password == null) {
      return jsonError('Email and password are required');
    }

    final rows = appDb.db.select('SELECT * FROM users WHERE email = ?', [email]);
    if (rows.isEmpty) return unauthorized('Invalid email or password');

    final row = rows.first;
    final valid = auth.verifyPassword(
      password,
      row['password_salt'] as String,
      row['password_hash'] as String,
    );
    if (!valid) return unauthorized('Invalid email or password');

    final user = User.fromRow(row);
    final token = auth.issueToken(user.id);
    return jsonResponse({'token': token, 'user': user.toJson()});
  }

  Future<Response> _me(Request request) async {
    final rows = appDb.db
        .select('SELECT * FROM users WHERE id = ?', [request.userId]);
    if (rows.isEmpty) return notFound('User');
    return jsonResponse({'user': User.fromRow(rows.first).toJson()});
  }

  Future<Response> _changePassword(Request request) async {
    final body = await readJsonBody(request);
    if (body == null) return jsonError('Invalid JSON body');

    final currentPassword = body['currentPassword'] as String?;
    final newPassword = body['newPassword'] as String?;
    if (currentPassword == null || currentPassword.isEmpty) {
      return jsonError('Current password is required');
    }
    if (newPassword == null || newPassword.length < 6) {
      return jsonError('New password must be at least 6 characters');
    }

    final rows =
        appDb.db.select('SELECT * FROM users WHERE id = ?', [request.userId]);
    if (rows.isEmpty) return notFound('User');
    final row = rows.first;

    final valid = auth.verifyPassword(
      currentPassword,
      row['password_salt'] as String,
      row['password_hash'] as String,
    );
    if (!valid) return jsonError('Current password is incorrect', status: 401);

    final salt = auth.generateSalt();
    final hash = auth.hashPassword(newPassword, salt);
    appDb.db.execute(
      'UPDATE users SET password_hash = ?, password_salt = ? WHERE id = ?',
      [hash, salt, request.userId],
    );

    return jsonResponse({'success': true});
  }
}
