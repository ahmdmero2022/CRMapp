import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/database.dart';
import '../models/models.dart';
import '../utils/responses.dart';

class PipelineStagesHandler {
  PipelineStagesHandler(this.appDb);

  final AppDatabase appDb;

  Router get router {
    final router = Router();
    router.get('/', _list);
    return router;
  }

  Future<Response> _list(Request request) async {
    final rows = appDb.db
        .select('SELECT * FROM pipeline_stages ORDER BY order_index');
    return jsonResponse(
        rows.map((r) => PipelineStage.fromRow(r).toJson()).toList());
  }
}
