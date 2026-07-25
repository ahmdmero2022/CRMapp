import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/database.dart';
import '../utils/responses.dart';

/// Cross-entity search: given `?q=`, returns a handful of matches from each
/// resource table for the global search screen. Each result is trimmed down
/// to id/label/subtitle — full records are fetched via the resource's own
/// detail/list endpoint once the user picks a result.
class SearchHandler {
  SearchHandler(this.appDb);

  final AppDatabase appDb;

  Router get router {
    final router = Router();
    router.get('/', _search);
    return router;
  }

  static const _empty = {
    'contacts': [],
    'companies': [],
    'leads': [],
    'deals': [],
    'tasks': [],
  };

  Future<Response> _search(Request request) async {
    final q = request.url.queryParameters['q']?.trim() ?? '';
    if (q.isEmpty) return jsonResponse(_empty);
    final like = '%$q%';

    final contacts = appDb.db.select(
      'SELECT id, first_name, last_name, email FROM contacts '
      'WHERE first_name LIKE ? OR last_name LIKE ? OR email LIKE ? LIMIT 5',
      [like, like, like],
    );
    final companies = appDb.db.select(
      'SELECT id, name, industry FROM companies WHERE name LIKE ? LIMIT 5',
      [like],
    );
    final leads = appDb.db.select(
      'SELECT id, name, status FROM leads '
      'WHERE name LIKE ? OR email LIKE ? OR company_name LIKE ? LIMIT 5',
      [like, like, like],
    );
    final deals = appDb.db.select(
      'SELECT id, title, value FROM deals WHERE title LIKE ? LIMIT 5',
      [like],
    );
    final tasks = appDb.db.select(
      'SELECT id, title, due_date FROM tasks WHERE title LIKE ? LIMIT 5',
      [like],
    );

    return jsonResponse({
      'contacts': contacts
          .map((r) => {
                'id': r['id'],
                'label': '${r['first_name']} ${r['last_name']}',
                'subtitle': r['email'],
              })
          .toList(),
      'companies': companies
          .map((r) => {
                'id': r['id'],
                'label': r['name'],
                'subtitle': r['industry'],
              })
          .toList(),
      'leads': leads
          .map((r) => {
                'id': r['id'],
                'label': r['name'],
                'subtitle': r['status'],
              })
          .toList(),
      'deals': deals
          .map((r) => {
                'id': r['id'],
                'label': r['title'],
                'subtitle': r['value']?.toString(),
              })
          .toList(),
      'tasks': tasks
          .map((r) => {
                'id': r['id'],
                'label': r['title'],
                'subtitle': r['due_date'],
              })
          .toList(),
    });
  }
}
