import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/database.dart';
import '../middleware/auth_middleware.dart';
import '../models/models.dart';
import '../utils/list_query.dart';
import '../utils/responses.dart';

const _leadSortColumns = {
  'name': 'name COLLATE NOCASE',
  'status': 'status',
  'estimatedValue': 'estimated_value',
  'createdAt': 'created_at',
};

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

class LeadsHandler {
  LeadsHandler(this.appDb);

  final AppDatabase appDb;

  Router get router {
    final router = Router();
    router.get('/', _list);
    router.post('/', _create);
    router.get('/<id>', _get);
    router.put('/<id>', _update);
    router.delete('/<id>', _delete);
    router.post('/<id>/convert', _convert);
    return router;
  }

  Future<Response> _list(Request request) async {
    final status = request.url.queryParameters['status'];
    final search = request.url.queryParameters['search'];

    final clauses = <String>[];
    final params = <dynamic>[];
    if (status != null && status.isNotEmpty) {
      clauses.add('status = ?');
      params.add(status);
    }
    if (search != null && search.isNotEmpty) {
      clauses.add('(name LIKE ? OR email LIKE ? OR company_name LIKE ?)');
      params.addAll(['%$search%', '%$search%', '%$search%']);
    }
    final where = clauses.isEmpty ? '' : 'WHERE ${clauses.join(' AND ')}';
    final total = appDb.db
        .select('SELECT COUNT(*) as c FROM leads $where', params)
        .first['c'] as int;
    final orderBy = buildOrderBy(request, _leadSortColumns, 'created_at DESC');
    final pagination = parsePagination(request);
    final rows = appDb.db.select(
        'SELECT * FROM leads $where ORDER BY $orderBy LIMIT ? OFFSET ?',
        [...params, pagination.limit, pagination.offset]);
    return jsonListResponse(
        rows.map((r) => Lead.fromRow(r).toJson()).toList(), total);
  }

  Future<Response> _get(Request request, String id) async {
    final rows = appDb.db.select('SELECT * FROM leads WHERE id = ?', [id]);
    if (rows.isEmpty) return notFound('Lead');
    final lead = Lead.fromRow(rows.first).toJson();
    final activities = appDb.db.select(
        "SELECT a.*, u.name as owner_name FROM activities a LEFT JOIN users u ON u.id = a.owner_id WHERE a.related_type = 'lead' AND a.related_id = ? ORDER BY a.created_at DESC",
        [id]);
    lead['activities'] =
        activities.map((r) => Activity.fromRow(r).toJson()).toList();
    return jsonResponse(lead);
  }

  Future<Response> _create(Request request) async {
    final body = await readJsonBody(request);
    if (body == null) return jsonError('Invalid JSON body');
    final name = (body['name'] as String?)?.trim();
    if (name == null || name.isEmpty) return jsonError('Name is required');

    final id = AppDatabase.uuid.v4();
    final now = DateTime.now().toIso8601String();
    appDb.db.execute(
      'INSERT INTO leads (id, name, email, phone, source, status, company_name, estimated_value, owner_id, notes, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        id,
        name,
        body['email'],
        body['phone'],
        body['source'],
        body['status'] ?? 'new',
        body['companyName'],
        (body['estimatedValue'] as num?)?.toDouble() ?? 0,
        request.userId,
        body['notes'],
        now,
        now,
      ],
    );
    final rows = appDb.db.select('SELECT * FROM leads WHERE id = ?', [id]);
    return jsonResponse(Lead.fromRow(rows.first).toJson(), status: 201);
  }

  Future<Response> _update(Request request, String id) async {
    final existing = appDb.db.select('SELECT * FROM leads WHERE id = ?', [id]);
    if (existing.isEmpty) return notFound('Lead');
    final body = await readJsonBody(request);
    if (body == null) return jsonError('Invalid JSON body');

    final current = Lead.fromRow(existing.first);
    final now = DateTime.now().toIso8601String();
    final newStatus = body['status'] as String? ?? current.status;
    appDb.db.execute(
      'UPDATE leads SET name = ?, email = ?, phone = ?, source = ?, status = ?, company_name = ?, estimated_value = ?, notes = ?, updated_at = ? WHERE id = ?',
      [
        (body['name'] as String?)?.trim() ?? current.name,
        body.containsKey('email') ? body['email'] : current.email,
        body.containsKey('phone') ? body['phone'] : current.phone,
        body.containsKey('source') ? body['source'] : current.source,
        newStatus,
        body.containsKey('companyName') ? body['companyName'] : current.companyName,
        (body['estimatedValue'] as num?)?.toDouble() ?? current.estimatedValue,
        body.containsKey('notes') ? body['notes'] : current.notes,
        now,
        id,
      ],
    );
    if (newStatus != current.status) {
      appDb.db.execute(
        'INSERT INTO activities (id, type, content, related_type, related_id, owner_id, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [
          AppDatabase.uuid.v4(),
          'status_change',
          'Status changed from ${current.status} to $newStatus',
          'lead',
          id,
          request.userId,
          now,
        ],
      );
    }
    final rows = appDb.db.select('SELECT * FROM leads WHERE id = ?', [id]);
    return jsonResponse(Lead.fromRow(rows.first).toJson());
  }

  Future<Response> _delete(Request request, String id) async {
    final existing = appDb.db.select('SELECT id FROM leads WHERE id = ?', [id]);
    if (existing.isEmpty) return notFound('Lead');
    appDb.db.execute('DELETE FROM leads WHERE id = ?', [id]);
    return Response(204);
  }

  /// Converts a lead into a contact (and optionally a company + deal),
  /// marking the lead as 'converted'.
  Future<Response> _convert(Request request, String id) async {
    final rows = appDb.db.select('SELECT * FROM leads WHERE id = ?', [id]);
    if (rows.isEmpty) return notFound('Lead');
    final lead = Lead.fromRow(rows.first);
    if (lead.status == 'converted') {
      return jsonError('Lead already converted', status: 409);
    }

    final now = DateTime.now().toIso8601String();

    String? companyId;
    if (lead.companyName != null && lead.companyName!.trim().isNotEmpty) {
      final existingCompany = appDb.db.select(
          'SELECT id FROM companies WHERE name = ?', [lead.companyName]);
      if (existingCompany.isNotEmpty) {
        companyId = existingCompany.first['id'] as String;
      } else {
        companyId = AppDatabase.uuid.v4();
        appDb.db.execute(
          'INSERT INTO companies (id, name, owner_id, created_at, updated_at) VALUES (?, ?, ?, ?, ?)',
          [companyId, lead.companyName, request.userId, now, now],
        );
      }
    }

    final nameParts = lead.name.trim().split(RegExp(r'\s+'));
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '-';
    final contactId = AppDatabase.uuid.v4();
    final color = _avatarColors[contactId.hashCode % _avatarColors.length];
    appDb.db.execute(
      'INSERT INTO contacts (id, first_name, last_name, email, phone, company_id, owner_id, avatar_color, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        contactId,
        firstName,
        lastName,
        lead.email,
        lead.phone,
        companyId,
        request.userId,
        color,
        now,
        now,
      ],
    );

    final firstStage = appDb.db
        .select('SELECT id FROM pipeline_stages ORDER BY order_index LIMIT 1')
        .first['id'] as String;
    final dealId = AppDatabase.uuid.v4();
    appDb.db.execute(
      'INSERT INTO deals (id, title, value, stage_id, contact_id, company_id, owner_id, probability, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        dealId,
        '${lead.name} opportunity',
        lead.estimatedValue,
        firstStage,
        contactId,
        companyId,
        request.userId,
        50,
        'open',
        now,
        now,
      ],
    );

    appDb.db.execute(
      'UPDATE leads SET status = ?, updated_at = ? WHERE id = ?',
      ['converted', now, id],
    );
    appDb.db.execute(
      'INSERT INTO activities (id, type, content, related_type, related_id, owner_id, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        AppDatabase.uuid.v4(),
        'status_change',
        'Lead converted to contact and deal',
        'lead',
        id,
        request.userId,
        now,
      ],
    );

    return jsonResponse({
      'contactId': contactId,
      'dealId': dealId,
      'companyId': companyId,
    });
  }
}
