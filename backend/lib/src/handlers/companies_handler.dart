import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/database.dart';
import '../middleware/auth_middleware.dart';
import '../models/models.dart';
import '../utils/responses.dart';

class CompaniesHandler {
  CompaniesHandler(this.appDb);

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

  Company _withCounts(Company c) {
    final contactCount = appDb.db.select(
        'SELECT COUNT(*) as c FROM contacts WHERE company_id = ?',
        [c.id]).first['c'] as int;
    final dealCount = appDb.db.select(
        'SELECT COUNT(*) as c FROM deals WHERE company_id = ?',
        [c.id]).first['c'] as int;
    return c.copyWithCounts(contactCount: contactCount, dealCount: dealCount);
  }

  Future<Response> _list(Request request) async {
    final search = request.url.queryParameters['search'];
    List<dynamic> rows;
    if (search != null && search.isNotEmpty) {
      rows = appDb.db.select(
        'SELECT * FROM companies WHERE name LIKE ? ORDER BY name COLLATE NOCASE',
        ['%$search%'],
      );
    } else {
      rows = appDb.db
          .select('SELECT * FROM companies ORDER BY name COLLATE NOCASE');
    }
    final companies =
        rows.map((r) => _withCounts(Company.fromRow(r)).toJson()).toList();
    return jsonResponse(companies);
  }

  Future<Response> _get(Request request, String id) async {
    final rows = appDb.db.select('SELECT * FROM companies WHERE id = ?', [id]);
    if (rows.isEmpty) return notFound('Company');
    return jsonResponse(_withCounts(Company.fromRow(rows.first)).toJson());
  }

  Future<Response> _create(Request request) async {
    final body = await readJsonBody(request);
    if (body == null) return jsonError('Invalid JSON body');
    final name = (body['name'] as String?)?.trim();
    if (name == null || name.isEmpty) return jsonError('Name is required');

    final id = AppDatabase.uuid.v4();
    final now = DateTime.now().toIso8601String();
    appDb.db.execute(
      'INSERT INTO companies (id, name, industry, website, phone, address, notes, owner_id, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        id,
        name,
        body['industry'],
        body['website'],
        body['phone'],
        body['address'],
        body['notes'],
        request.userId,
        now,
        now,
      ],
    );
    final rows = appDb.db.select('SELECT * FROM companies WHERE id = ?', [id]);
    return jsonResponse(_withCounts(Company.fromRow(rows.first)).toJson(), status: 201);
  }

  Future<Response> _update(Request request, String id) async {
    final existing = appDb.db.select('SELECT * FROM companies WHERE id = ?', [id]);
    if (existing.isEmpty) return notFound('Company');
    final body = await readJsonBody(request);
    if (body == null) return jsonError('Invalid JSON body');

    final current = Company.fromRow(existing.first);
    final now = DateTime.now().toIso8601String();
    appDb.db.execute(
      'UPDATE companies SET name = ?, industry = ?, website = ?, phone = ?, address = ?, notes = ?, updated_at = ? WHERE id = ?',
      [
        (body['name'] as String?)?.trim() ?? current.name,
        body.containsKey('industry') ? body['industry'] : current.industry,
        body.containsKey('website') ? body['website'] : current.website,
        body.containsKey('phone') ? body['phone'] : current.phone,
        body.containsKey('address') ? body['address'] : current.address,
        body.containsKey('notes') ? body['notes'] : current.notes,
        now,
        id,
      ],
    );
    final rows = appDb.db.select('SELECT * FROM companies WHERE id = ?', [id]);
    return jsonResponse(_withCounts(Company.fromRow(rows.first)).toJson());
  }

  Future<Response> _delete(Request request, String id) async {
    final existing = appDb.db.select('SELECT id FROM companies WHERE id = ?', [id]);
    if (existing.isEmpty) return notFound('Company');
    appDb.db.execute('DELETE FROM companies WHERE id = ?', [id]);
    return Response(204);
  }
}
