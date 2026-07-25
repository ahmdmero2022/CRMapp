import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/database.dart';
import '../middleware/auth_middleware.dart';
import '../models/models.dart';
import '../utils/list_query.dart';
import '../utils/responses.dart';

const _dealSelect = '''
  SELECT d.*,
    (con.first_name || ' ' || con.last_name) as contact_name,
    co.name as company_name
  FROM deals d
  LEFT JOIN contacts con ON con.id = d.contact_id
  LEFT JOIN companies co ON co.id = d.company_id
''';

const _dealFrom = '''
  FROM deals d
  LEFT JOIN contacts con ON con.id = d.contact_id
  LEFT JOIN companies co ON co.id = d.company_id
''';

const _dealSortColumns = {
  'title': 'd.title COLLATE NOCASE',
  'value': 'd.value',
  'expectedCloseDate': 'd.expected_close_date',
  'createdAt': 'd.created_at',
};

class DealsHandler {
  DealsHandler(this.appDb);

  final AppDatabase appDb;

  Router get router {
    final router = Router();
    router.get('/', _list);
    router.post('/', _create);
    router.get('/<id>', _get);
    router.put('/<id>', _update);
    router.patch('/<id>/stage', _updateStage);
    router.delete('/<id>', _delete);
    return router;
  }

  Future<Response> _list(Request request) async {
    final stageId = request.url.queryParameters['stageId'];
    final status = request.url.queryParameters['status'];
    final companyId = request.url.queryParameters['companyId'];
    final contactId = request.url.queryParameters['contactId'];
    final search = request.url.queryParameters['search'];
    final clauses = <String>[];
    final params = <dynamic>[];
    if (stageId != null && stageId.isNotEmpty) {
      clauses.add('d.stage_id = ?');
      params.add(stageId);
    }
    if (status != null && status.isNotEmpty) {
      clauses.add('d.status = ?');
      params.add(status);
    }
    if (companyId != null && companyId.isNotEmpty) {
      clauses.add('d.company_id = ?');
      params.add(companyId);
    }
    if (contactId != null && contactId.isNotEmpty) {
      clauses.add('d.contact_id = ?');
      params.add(contactId);
    }
    if (search != null && search.isNotEmpty) {
      clauses.add('d.title LIKE ?');
      params.add('%$search%');
    }
    final where = clauses.isEmpty ? '' : 'WHERE ${clauses.join(' AND ')}';
    final total = appDb.db
        .select('SELECT COUNT(*) as c $_dealFrom $where', params)
        .first['c'] as int;
    final orderBy =
        buildOrderBy(request, _dealSortColumns, 'd.created_at DESC');
    final pagination = parsePagination(request, defaultLimit: 200, maxLimit: 500);
    final rows = appDb.db.select(
        '$_dealSelect $where ORDER BY $orderBy LIMIT ? OFFSET ?',
        [...params, pagination.limit, pagination.offset]);
    return jsonListResponse(
        rows.map((r) => Deal.fromRow(r).toJson()).toList(), total);
  }

  Future<Response> _get(Request request, String id) async {
    final rows = appDb.db.select('$_dealSelect WHERE d.id = ?', [id]);
    if (rows.isEmpty) return notFound('Deal');
    final deal = Deal.fromRow(rows.first).toJson();
    final activities = appDb.db.select(
        "SELECT a.*, u.name as owner_name FROM activities a LEFT JOIN users u ON u.id = a.owner_id WHERE a.related_type = 'deal' AND a.related_id = ? ORDER BY a.created_at DESC",
        [id]);
    final tasks = appDb.db.select(
        "SELECT * FROM tasks WHERE related_type = 'deal' AND related_id = ? ORDER BY due_date IS NULL, due_date",
        [id]);
    deal['activities'] =
        activities.map((r) => Activity.fromRow(r).toJson()).toList();
    deal['tasks'] = tasks.map((r) => Task.fromRow(r).toJson()).toList();
    return jsonResponse(deal);
  }

  Future<Response> _create(Request request) async {
    final body = await readJsonBody(request);
    if (body == null) return jsonError('Invalid JSON body');
    final title = (body['title'] as String?)?.trim();
    if (title == null || title.isEmpty) return jsonError('Title is required');

    var stageId = body['stageId'] as String?;
    if (stageId == null || stageId.isEmpty) {
      final firstStage = appDb.db.select(
          'SELECT id FROM pipeline_stages ORDER BY order_index LIMIT 1');
      if (firstStage.isEmpty) return jsonError('No pipeline stages configured');
      stageId = firstStage.first['id'] as String;
    } else {
      final stageExists =
          appDb.db.select('SELECT id FROM pipeline_stages WHERE id = ?', [stageId]);
      if (stageExists.isEmpty) return jsonError('Invalid stageId');
    }

    final id = AppDatabase.uuid.v4();
    final now = DateTime.now().toIso8601String();
    appDb.db.execute(
      'INSERT INTO deals (id, title, value, stage_id, contact_id, company_id, owner_id, expected_close_date, probability, status, notes, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        id,
        title,
        (body['value'] as num?)?.toDouble() ?? 0,
        stageId,
        body['contactId'],
        body['companyId'],
        request.userId,
        body['expectedCloseDate'],
        (body['probability'] as num?)?.toInt() ?? 50,
        body['status'] ?? 'open',
        body['notes'],
        now,
        now,
      ],
    );
    final rows = appDb.db.select('$_dealSelect WHERE d.id = ?', [id]);
    return jsonResponse(Deal.fromRow(rows.first).toJson(), status: 201);
  }

  Future<Response> _update(Request request, String id) async {
    final existing = appDb.db.select('SELECT * FROM deals WHERE id = ?', [id]);
    if (existing.isEmpty) return notFound('Deal');
    final body = await readJsonBody(request);
    if (body == null) return jsonError('Invalid JSON body');

    final current = Deal.fromRow(existing.first);
    final now = DateTime.now().toIso8601String();
    appDb.db.execute(
      'UPDATE deals SET title = ?, value = ?, contact_id = ?, company_id = ?, expected_close_date = ?, probability = ?, status = ?, notes = ?, updated_at = ? WHERE id = ?',
      [
        (body['title'] as String?)?.trim() ?? current.title,
        (body['value'] as num?)?.toDouble() ?? current.value,
        body.containsKey('contactId') ? body['contactId'] : current.contactId,
        body.containsKey('companyId') ? body['companyId'] : current.companyId,
        body.containsKey('expectedCloseDate')
            ? body['expectedCloseDate']
            : current.expectedCloseDate,
        (body['probability'] as num?)?.toInt() ?? current.probability,
        body['status'] as String? ?? current.status,
        body.containsKey('notes') ? body['notes'] : current.notes,
        now,
        id,
      ],
    );
    final rows = appDb.db.select('$_dealSelect WHERE d.id = ?', [id]);
    return jsonResponse(Deal.fromRow(rows.first).toJson());
  }

  /// Dedicated endpoint for kanban drag-and-drop: moves a deal to a new
  /// pipeline stage and logs the transition as an activity.
  Future<Response> _updateStage(Request request, String id) async {
    final existing = appDb.db.select('SELECT * FROM deals WHERE id = ?', [id]);
    if (existing.isEmpty) return notFound('Deal');
    final body = await readJsonBody(request);
    if (body == null) return jsonError('Invalid JSON body');
    final stageId = body['stageId'] as String?;
    if (stageId == null || stageId.isEmpty) return jsonError('stageId is required');

    final stageRows =
        appDb.db.select('SELECT * FROM pipeline_stages WHERE id = ?', [stageId]);
    if (stageRows.isEmpty) return jsonError('Invalid stageId');
    final stage = PipelineStage.fromRow(stageRows.first);

    final current = Deal.fromRow(existing.first);
    final now = DateTime.now().toIso8601String();
    var status = current.status;
    if (stage.name == 'Won') status = 'won';
    if (stage.name == 'Lost') status = 'lost';
    if (stage.name != 'Won' && stage.name != 'Lost') status = 'open';

    appDb.db.execute(
      'UPDATE deals SET stage_id = ?, status = ?, updated_at = ? WHERE id = ?',
      [stageId, status, now, id],
    );
    appDb.db.execute(
      'INSERT INTO activities (id, type, content, related_type, related_id, owner_id, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        AppDatabase.uuid.v4(),
        'status_change',
        'Deal moved to stage "${stage.name}"',
        'deal',
        id,
        request.userId,
        now,
      ],
    );
    final rows = appDb.db.select('$_dealSelect WHERE d.id = ?', [id]);
    return jsonResponse(Deal.fromRow(rows.first).toJson());
  }

  Future<Response> _delete(Request request, String id) async {
    final existing = appDb.db.select('SELECT id FROM deals WHERE id = ?', [id]);
    if (existing.isEmpty) return notFound('Deal');
    appDb.db.execute('DELETE FROM deals WHERE id = ?', [id]);
    return Response(204);
  }
}
