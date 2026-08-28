import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/database.dart';
import '../models/models.dart';
import '../utils/responses.dart';

class UsersHandler {
  UsersHandler(this.appDb);

  final AppDatabase appDb;

  Router get router {
    final router = Router();
    router.get('/', _list);
    return router;
  }

  Future<Response> _list(Request request) async {
    final rows = appDb.db.select('SELECT * FROM users ORDER BY name COLLATE NOCASE');
    return jsonResponse(rows.map((r) => User.fromRow(r).toJson()).toList());
  }
}
