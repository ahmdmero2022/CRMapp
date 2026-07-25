import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dotenv/dotenv.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

import 'package:backend/src/auth/auth_service.dart';
import 'package:backend/src/db/database.dart';
import 'package:backend/src/handlers/activities_handler.dart';
import 'package:backend/src/handlers/auth_handler.dart';
import 'package:backend/src/handlers/companies_handler.dart';
import 'package:backend/src/handlers/contacts_handler.dart';
import 'package:backend/src/handlers/dashboard_handler.dart';
import 'package:backend/src/handlers/deals_handler.dart';
import 'package:backend/src/handlers/leads_handler.dart';
import 'package:backend/src/handlers/pipeline_stages_handler.dart';
import 'package:backend/src/handlers/tasks_handler.dart';
import 'package:backend/src/middleware/auth_middleware.dart';
import 'package:backend/src/middleware/cors_middleware.dart';
import 'package:backend/src/utils/responses.dart';

Future<void> main(List<String> args) async {
  final env = DotEnv(includePlatformEnvironment: true)..load();

  final port = int.tryParse(env['PORT'] ?? '8080') ?? 8080;
  final dbPath = env['DB_PATH'] ?? 'data/crm.db';
  final webRoot = env['WEB_ROOT'] ?? '../frontend/build/web';

  final envSecret = env['JWT_SECRET'];
  final jwtSecret = (envSecret == null || envSecret.isEmpty)
      ? _generateRandomSecret()
      : envSecret;
  if (envSecret == null || envSecret.isEmpty) {
    stderr.writeln(
        'WARNING: JWT_SECRET is not set. Generated a random secret for this '
        'process — existing sessions will be invalidated on every restart. '
        'Set JWT_SECRET explicitly in production.');
  }

  final appDb = AppDatabase.open(dbPath);
  final auth = AuthService(jwtSecret);

  final apiRouter = Router();
  apiRouter.mount('/api/auth', AuthHandler(appDb, auth).router.call);

  final protected = Pipeline().addMiddleware(authMiddleware(auth));

  apiRouter.mount(
      '/api/companies', protected.addHandler(CompaniesHandler(appDb).router.call));
  apiRouter.mount(
      '/api/contacts', protected.addHandler(ContactsHandler(appDb).router.call));
  apiRouter.mount(
      '/api/leads', protected.addHandler(LeadsHandler(appDb).router.call));
  apiRouter.mount(
      '/api/deals', protected.addHandler(DealsHandler(appDb).router.call));
  apiRouter.mount('/api/pipeline-stages',
      protected.addHandler(PipelineStagesHandler(appDb).router.call));
  apiRouter.mount(
      '/api/tasks', protected.addHandler(TasksHandler(appDb).router.call));
  apiRouter.mount('/api/activities',
      protected.addHandler(ActivitiesHandler(appDb).router.call));
  apiRouter.mount('/api/dashboard',
      protected.addHandler(DashboardHandler(appDb).router.call));

  apiRouter.get('/api/health', (Request request) => jsonResponse({'status': 'ok'}));

  final staticDir = Directory(webRoot);
  final staticHandler = staticDir.existsSync()
      ? createStaticHandler(webRoot, defaultDocument: 'index.html')
      : null;

  final handler = const Pipeline()
      .addMiddleware(corsMiddleware(
          allowedOrigin: Platform.environment['ALLOWED_ORIGIN'] ?? '*'))
      .addMiddleware(logRequests())
      .addHandler((Request request) async {
    if (request.url.path.startsWith('api/')) {
      return apiRouter.call(request);
    }
    if (staticHandler != null) {
      final response = await staticHandler(request);
      if (response.statusCode != 404) return response;
      // SPA fallback: unknown non-API paths serve index.html for client routing.
      return staticHandler(Request('GET', request.requestedUri.replace(path: '/')));
    }
    return jsonError('Not found', status: 404);
  });

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  print('CRM backend listening on http://${server.address.host}:${server.port}');
  print('Database: $dbPath');
  if (staticHandler == null) {
    print('Note: frontend build not found at $webRoot (API-only mode).');
  }
}

String _generateRandomSecret() {
  final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
  return base64Url.encode(bytes);
}
