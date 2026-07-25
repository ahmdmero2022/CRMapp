import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/database.dart';
import '../middleware/auth_middleware.dart';
import '../models/models.dart';
import '../utils/list_query.dart';
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

const _contactSelect = '''
  SELECT c.*, co.name as company_name
  FROM contacts c
  LEFT JOIN companies co ON co.id = c.company_id
''';

const _contactFrom = '''
  FROM contacts c
  LEFT JOIN companies co ON co.id = c.company_id
''';

const _contactSortColumns = {
  'name': 'c.first_name COLLATE NOCASE, c.last_name COLLATE NOCASE',
  'email': 'c.email COLLATE NOCASE',
  'createdAt': 'c.created_at',
};

class ContactsHandler {
  ContactsHandler(this.appDb);

  final AppDatabase appDb;

  Router get router {
    final router = Router();
    router.get('/', _list);
    router.post('/', _create);
    router.get('/<id>', _get);
    router.put('/<id>', _update);
    router.delete('/<id>', _delete);
    return router;
  }

  Future<Response> _list(Request request) async {
    final search = request.url.queryParameters['search'];
    final companyId = request.url.queryParameters['companyId'];

    final clauses = <String>[];
    final params = <dynamic>[];
    if (search != null && search.isNotEmpty) {
      clauses.add(
          '(c.first_name LIKE ? OR c.last_name LIKE ? OR c.email LIKE ?)');
      params.addAll(['%$search%', '%$search%', '%$search%']);
    }
    if (companyId != null && companyId.isNotEmpty) {
      clauses.add('c.company_id = ?');
      params.add(companyId);
    }
    final where = clauses.isEmpty ? '' : 'WHERE ${clauses.join(' AND ')}';
    final total = appDb.db
        .select('SELECT COUNT(*) as c $_contactFrom $where', params)
        .first['c'] as int;
    final orderBy = buildOrderBy(
        request, _contactSortColumns, 'c.first_name COLLATE NOCASE ASC');
    final pagination = parsePagination(request);
    final rows = appDb.db.select(
        '$_contactSelect $where ORDER BY $orderBy LIMIT ? OFFSET ?',
        [...params, pagination.limit, pagination.offset]);
    return jsonListResponse(
        rows.map((r) => Contact.fromRow(r).toJson()).toList(), total);
  }

  Future<Response> _get(Request request, String id) async {
    final rows = appDb.db.select('$_contactSelect WHERE c.id = ?', [id]);
    if (rows.isEmpty) return notFound('Contact');
    final contact = Contact.fromRow(rows.first).toJson();

    final deals = appDb.db.select(
        'SELECT d.*, co.name as company_name FROM deals d LEFT JOIN companies co ON co.id = d.company_id WHERE d.contact_id = ? ORDER BY d.created_at DESC',
        [id]);
    final tasks = appDb.db.select(
        "SELECT * FROM tasks WHERE related_type = 'contact' AND related_id = ? ORDER BY due_date IS NULL, due_date",
        [id]);
    final activities = appDb.db.select(
        "SELECT a.*, u.name as owner_name FROM activities a LEFT JOIN users u ON u.id = a.owner_id WHERE a.related_type = 'contact' AND a.related_id = ? ORDER BY a.created_at DESC",
        [id]);

    contact['deals'] = deals.map((r) => Deal.fromRow(r).toJson()).toList();
    contact['tasks'] = tasks.map((r) => Task.fromRow(r).toJson()).toList();
    contact['activities'] =
        activities.map((r) => Activity.fromRow(r).toJson()).toList();
    return jsonResponse(contact);
  }

  Future<Response> _create(Request request) async {
    final body = await readJsonBody(request);
    if (body == null) return jsonError('Invalid JSON body');
    final firstName = (body['firstName'] as String?)?.trim();
    final lastName = (body['lastName'] as String?)?.trim();
    if (firstName == null || firstName.isEmpty) {
      return jsonError('First name is required');
    }
    if (lastName == null || lastName.isEmpty) {
      return jsonError('Last name is required');
    }

    final id = AppDatabase.uuid.v4();
    final now = DateTime.now().toIso8601String();
    final color = _avatarColors[id.hashCode % _avatarColors.length];

    appDb.db.execute(
      'INSERT INTO contacts (id, first_name, last_name, email, phone, job_title, company_id, owner_id, tags, notes, avatar_color, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        id,
        firstName,
        lastName,
        body['email'],
        body['phone'],
        body['jobTitle'],
        body['companyId'],
        request.userId,
        body['tags'],
        body['notes'],
        color,
        now,
        now,
      ],
    );
    final rows = appDb.db.select('$_contactSelect WHERE c.id = ?', [id]);
    return jsonResponse(Contact.fromRow(rows.first).toJson(), status: 201);
  }

  Future<Response> _update(Request request, String id) async {
    final existing = appDb.db.select('SELECT * FROM contacts WHERE id = ?', [id]);
    if (existing.isEmpty) return notFound('Contact');
    final body = await readJsonBody(request);
    if (body == null) return jsonError('Invalid JSON body');

    final current = Contact.fromRow(existing.first);
    final now = DateTime.now().toIso8601String();
    appDb.db.execute(
      'UPDATE contacts SET first_name = ?, last_name = ?, email = ?, phone = ?, job_title = ?, company_id = ?, tags = ?, notes = ?, updated_at = ? WHERE id = ?',
      [
        (body['firstName'] as String?)?.trim() ?? current.firstName,
        (body['lastName'] as String?)?.trim() ?? current.lastName,
        body.containsKey('email') ? body['email'] : current.email,
        body.containsKey('phone') ? body['phone'] : current.phone,
        body.containsKey('jobTitle') ? body['jobTitle'] : current.jobTitle,
        body.containsKey('companyId') ? body['companyId'] : current.companyId,
        body.containsKey('tags') ? body['tags'] : current.tags,
        body.containsKey('notes') ? body['notes'] : current.notes,
        now,
        id,
      ],
    );
    final rows = appDb.db.select('$_contactSelect WHERE c.id = ?', [id]);
    return jsonResponse(Contact.fromRow(rows.first).toJson());
  }

  Future<Response> _delete(Request request, String id) async {
    final existing = appDb.db.select('SELECT id FROM contacts WHERE id = ?', [id]);
    if (existing.isEmpty) return notFound('Contact');
    appDb.db.execute('DELETE FROM contacts WHERE id = ?', [id]);
    return Response(204);
  }
}
