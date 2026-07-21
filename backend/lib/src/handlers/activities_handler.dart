import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/database.dart';
import '../middleware/auth_middleware.dart';
import '../models/models.dart';
import '../utils/responses.dart';

class ActivitiesHandler {
  ActivitiesHandler(this.appDb);

  final AppDatabase appDb;

  Router get router {
    final router = Router();
    router.get('/', _list);
    router.post('/', _create);
    router.delete('/<id>', _delete);
    return router;
  }

  Future<Response> _list(Request request) async {
    final relatedType = request.url.queryParameters['relatedType'];
    final relatedId = request.url.queryParameters['relatedId'];
    final limit = int.tryParse(request.url.queryParameters['limit'] ?? '') ?? 50;

    final clauses = <String>[];
    final params = <dynamic>[];
    if (relatedType != null && relatedType.isNotEmpty) {
      clauses.add('a.related_type = ?');
      params.add(relatedType);
    }
    if (relatedId != null && relatedId.isNotEmpty) {
      clauses.add('a.related_id = ?');
      params.add(relatedId);
    }
    final where = clauses.isEmpty ? '' : 'WHERE ${clauses.join(' AND ')}';
    params.add(limit);
    final rows = appDb.db.select(
        'SELECT a.*, u.name as owner_name FROM activities a LEFT JOIN users u ON u.id = a.owner_id $where ORDER BY a.created_at DESC LIMIT ?',
        params);
    return jsonResponse(rows.map((r) => Activity.fromRow(r).toJson()).toList());
  }

  Future<Response> _create(Request request) async {
    final body = await readJsonBody(request);
    if (body == null) return jsonError('Invalid JSON body');
    final content = (body['content'] as String?)?.trim();
    final relatedType = body['relatedType'] as String?;
    final relatedId = body['relatedId'] as String?;
    if (content == null || content.isEmpty) return jsonError('Content is required');
    if (relatedType == null || relatedId == null) {
      return jsonError('relatedType and relatedId are required');
    }

    final id = AppDatabase.uuid.v4();
    final now = DateTime.now().toIso8601String();
    appDb.db.execute(
      'INSERT INTO activities (id, type, content, related_type, related_id, owner_id, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        id,
        body['type'] ?? 'note',
        content,
        relatedType,
        relatedId,
        request.userId,
        now,
      ],
    );
    final rows = appDb.db.select(
        'SELECT a.*, u.name as owner_name FROM activities a LEFT JOIN users u ON u.id = a.owner_id WHERE a.id = ?',
        [id]);
    return jsonResponse(Activity.fromRow(rows.first).toJson(), status: 201);
  }

  Future<Response> _delete(Request request, String id) async {
    final existing = appDb.db.select('SELECT id FROM activities WHERE id = ?', [id]);
    if (existing.isEmpty) return notFound('Activity');
    appDb.db.execute('DELETE FROM activities WHERE id = ?', [id]);
    return Response(204);
  }
}
