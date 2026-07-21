import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/database.dart';
import '../middleware/auth_middleware.dart';
import '../models/models.dart';
import '../utils/responses.dart';

class TasksHandler {
  TasksHandler(this.appDb);

  final AppDatabase appDb;

  Router get router {
    final router = Router();
    router.get('/', _list);
    router.post('/', _create);
    router.get('/<id>', _get);
    router.put('/<id>', _update);
    router.patch('/<id>/complete', _complete);
    router.delete('/<id>', _delete);
    return router;
  }

  String? _relatedLabel(String? type, String? id) {
    if (type == null || id == null) return null;
    switch (type) {
      case 'contact':
        final r = appDb.db.select(
            'SELECT first_name, last_name FROM contacts WHERE id = ?', [id]);
        if (r.isEmpty) return null;
        return '${r.first['first_name']} ${r.first['last_name']}';
      case 'company':
        final r = appDb.db.select('SELECT name FROM companies WHERE id = ?', [id]);
        return r.isEmpty ? null : r.first['name'] as String;
      case 'deal':
        final r = appDb.db.select('SELECT title FROM deals WHERE id = ?', [id]);
        return r.isEmpty ? null : r.first['title'] as String;
      case 'lead':
        final r = appDb.db.select('SELECT name FROM leads WHERE id = ?', [id]);
        return r.isEmpty ? null : r.first['name'] as String;
    }
    return null;
  }

  Map<String, dynamic> _withLabel(Task t) {
    final json = t.toJson();
    json['relatedLabel'] = _relatedLabel(t.relatedType, t.relatedId);
    return json;
  }

  Future<Response> _list(Request request) async {
    final status = request.url.queryParameters['status'];
    final relatedType = request.url.queryParameters['relatedType'];
    final relatedId = request.url.queryParameters['relatedId'];

    final clauses = <String>[];
    final params = <dynamic>[];
    if (status != null && status.isNotEmpty) {
      clauses.add('status = ?');
      params.add(status);
    }
    if (relatedType != null && relatedType.isNotEmpty) {
      clauses.add('related_type = ?');
      params.add(relatedType);
    }
    if (relatedId != null && relatedId.isNotEmpty) {
      clauses.add('related_id = ?');
      params.add(relatedId);
    }
    final where = clauses.isEmpty ? '' : 'WHERE ${clauses.join(' AND ')}';
    final rows = appDb.db.select(
        'SELECT * FROM tasks $where ORDER BY status ASC, due_date IS NULL, due_date ASC',
        params);
    return jsonResponse(rows.map((r) => _withLabel(Task.fromRow(r))).toList());
  }

  Future<Response> _get(Request request, String id) async {
    final rows = appDb.db.select('SELECT * FROM tasks WHERE id = ?', [id]);
    if (rows.isEmpty) return notFound('Task');
    return jsonResponse(_withLabel(Task.fromRow(rows.first)));
  }

  Future<Response> _create(Request request) async {
    final body = await readJsonBody(request);
    if (body == null) return jsonError('Invalid JSON body');
    final title = (body['title'] as String?)?.trim();
    if (title == null || title.isEmpty) return jsonError('Title is required');

    final id = AppDatabase.uuid.v4();
    final now = DateTime.now().toIso8601String();
    appDb.db.execute(
      'INSERT INTO tasks (id, title, description, due_date, priority, status, related_type, related_id, owner_id, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        id,
        title,
        body['description'],
        body['dueDate'],
        body['priority'] ?? 'medium',
        body['status'] ?? 'pending',
        body['relatedType'],
        body['relatedId'],
        request.userId,
        now,
        now,
      ],
    );
    final rows = appDb.db.select('SELECT * FROM tasks WHERE id = ?', [id]);
    return jsonResponse(_withLabel(Task.fromRow(rows.first)), status: 201);
  }

  Future<Response> _update(Request request, String id) async {
    final existing = appDb.db.select('SELECT * FROM tasks WHERE id = ?', [id]);
    if (existing.isEmpty) return notFound('Task');
    final body = await readJsonBody(request);
    if (body == null) return jsonError('Invalid JSON body');

    final current = Task.fromRow(existing.first);
    final now = DateTime.now().toIso8601String();
    appDb.db.execute(
      'UPDATE tasks SET title = ?, description = ?, due_date = ?, priority = ?, status = ?, related_type = ?, related_id = ?, updated_at = ? WHERE id = ?',
      [
        (body['title'] as String?)?.trim() ?? current.title,
        body.containsKey('description') ? body['description'] : current.description,
        body.containsKey('dueDate') ? body['dueDate'] : current.dueDate,
        body['priority'] as String? ?? current.priority,
        body['status'] as String? ?? current.status,
        body.containsKey('relatedType') ? body['relatedType'] : current.relatedType,
        body.containsKey('relatedId') ? body['relatedId'] : current.relatedId,
        now,
        id,
      ],
    );
    final rows = appDb.db.select('SELECT * FROM tasks WHERE id = ?', [id]);
    return jsonResponse(_withLabel(Task.fromRow(rows.first)));
  }

  Future<Response> _complete(Request request, String id) async {
    final existing = appDb.db.select('SELECT * FROM tasks WHERE id = ?', [id]);
    if (existing.isEmpty) return notFound('Task');
    final body = await readJsonBody(request);
    final done = body?['done'] as bool? ?? true;
    final now = DateTime.now().toIso8601String();
    appDb.db.execute('UPDATE tasks SET status = ?, updated_at = ? WHERE id = ?',
        [done ? 'completed' : 'pending', now, id]);
    final rows = appDb.db.select('SELECT * FROM tasks WHERE id = ?', [id]);
    return jsonResponse(_withLabel(Task.fromRow(rows.first)));
  }

  Future<Response> _delete(Request request, String id) async {
    final existing = appDb.db.select('SELECT id FROM tasks WHERE id = ?', [id]);
    if (existing.isEmpty) return notFound('Task');
    appDb.db.execute('DELETE FROM tasks WHERE id = ?', [id]);
    return Response(204);
  }
}
