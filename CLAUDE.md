# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

A full-stack CRM built entirely in Flutter & Dart: a Flutter web frontend (Material 3, Riverpod, go_router) backed by a Dart REST API (shelf) with a file-based SQLite database. Two independent Dart packages live side by side:

```
CRMapp/
├── backend/    Dart REST API (shelf + shelf_router + sqlite3)
└── frontend/   Flutter web app (Riverpod + go_router + fl_chart)
```

There is no seeded demo account — register a new user via the app. All authenticated users share one workspace (no per-user data scoping), though `owner_id` columns already exist on every table if that's added later.

## Commands

### Backend (`cd backend`)

```bash
dart pub get                    # install deps
dart run bin/server.dart        # run the API on :8080 (creates/migrates backend/data/crm.db on first run)
dart analyze                    # lint (package:lints/recommended.yaml)
dart test                       # run tests (no test/ directory exists yet)
```

Backend env vars (all optional): `PORT` (default 8080), `DB_PATH` (default `data/crm.db`), `JWT_SECRET` (dev default — **must** be set in production), `WEB_ROOT` (default `../frontend/build/web`, the compiled frontend it serves as static files).

### Frontend (`cd frontend`)

```bash
flutter pub get                 # install deps
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080   # live-reload dev against a separate backend
flutter analyze                 # lint (package:flutter_lints)
flutter test                    # run tests (no test/ directory exists yet)
flutter build web --release --web-renderer html   # production build, output at frontend/build/web
```

`API_BASE_URL` defaults to `''` (same-origin) — only pass `--dart-define` when running the frontend against a backend on a different origin. The `--web-renderer html` build flag is intentional: it avoids downloading Google's CanvasKit runtime from an external CDN, so the built app works fully offline/air-gapped.

### Full stack, one process

```bash
cd frontend && flutter build web --release --web-renderer html
cd ../backend && dart pub get && dart run bin/server.dart
```

Visit `http://localhost:8080` — the backend serves the compiled Flutter app and `/api/*` from the same origin (no CORS/base-URL config needed). If `WEB_ROOT` doesn't exist, the server logs a note and runs API-only.

There is no root-level build/test runner — always `cd backend` or `cd frontend` first.

## Backend architecture (`backend/lib/src`)

Single-process shelf app, wired up entirely in `bin/server.dart`:

- **`db/database.dart`** — `AppDatabase` owns the one `sqlite3` connection, runs `CREATE TABLE IF NOT EXISTS` migrations and seeds the six default pipeline stages (New → Qualified → Proposal → Negotiation → Won/Lost) on startup. There's no migration framework — schema changes mean editing the `CREATE TABLE` statements directly (they must stay idempotent).
- **`auth/auth_service.dart`** — `AuthService` does salted/stretched HMAC-SHA256 password hashing (20k iterations, no bcrypt/argon2 dependency) and issues/verifies dependency-free signed session tokens: `base64(payload).base64(HMAC-SHA256 signature)`, payload is `{sub: userId, exp: epochMs}`. Not a real JWT — don't assume JWT libraries can read these tokens.
- **`middleware/auth_middleware.dart`** — validates the `Authorization: Bearer <token>` header and injects `userId` into `request.context`, exposed to handlers via the `RequestUser` extension (`request.userId`). Applied via a `Pipeline` wrapping every `/api/*` route except `/api/auth/*` and `/api/health`.
- **`handlers/*_handler.dart`** — one class per resource (companies, contacts, leads, deals, tasks, activities, pipeline_stages, dashboard, auth), each exposing a `Router get router` mounted at `/api/<resource>` in `bin/server.dart`. Handlers talk to SQLite directly via raw parameterized SQL (`appDb.db.select(...)` / `appDb.db.execute(...)`) — there is no ORM or query builder. Follow the existing handler as the template for a new one: `_list`/`_get`/`_create`/`_update`/`_delete` private methods, `readJsonBody`/`jsonResponse`/`jsonError`/`notFound` helpers from `utils/responses.dart`, and partial updates done via `body.containsKey('field') ? body['field'] : current.field`.
- **`models/models.dart`** — one class per table with `fromRow(Row)` (from sqlite3) and `toJson()` (camelCase keys for the API, even though DB columns are snake_case).
- IDs are UUIDv4 strings (`AppDatabase.uuid.v4()`), timestamps are ISO8601 strings, not SQLite datetime types.
- Cross-resource writes (e.g. `leads_handler.dart`'s `_convert`, or any status change) also insert an `activities` row (`type: 'status_change'`) — this is how the activity timeline / audit trail gets populated. Follow this pattern for any new status-changing endpoint.
- `related_type`/`related_id` (used by `tasks` and `activities`) is a lightweight polymorphic association to any of `contact`/`company`/`lead`/`deal` — always filter both columns together.

## Frontend architecture (`frontend/lib`)

- **`core/api/api_client.dart`** — thin `http`-based REST wrapper (`ApiClient`). Base URL is same-origin by default; attaches the bearer token via a `tokenProvider` callback (not stored directly, so it always reads the latest token from Riverpod state). Throws `ApiException` on non-2xx responses.
- **`core/providers/repositories.dart`** — one `XRepository` class per resource wrapping `ApiClient` calls and decoding JSON into `core/models/*` classes, plus a `Provider` for each (e.g. `contactsRepositoryProvider`). Add new API calls here, not directly in widgets/controllers.
- **`core/providers/list_notifier.dart`** — `ListNotifier<T>` is the shared base for every list-screen controller: loads into `AsyncValue<List<T>>` on construction and exposes `refresh({silent})`. Resource controllers (`core/providers/*_provider.dart`, e.g. `DealsController`) extend it and add CRUD methods that mutate through the repository then call `refresh()`.
- **Optimistic updates**: see `DealsController.moveToStage` in `core/providers/deals_provider.dart` — mutate local state immediately, call the API, `refresh(silent: true)` on success or full `refresh()` + rethrow on failure. Follow this pattern for other latency-sensitive interactions (e.g. task-complete toggle).
- **`core/router/app_router.dart`** — single `go_router` config (`routerProvider`). Auth-gated via a `redirect` callback reading `authProvider` plus a `ChangeNotifier` (`_AuthRefreshNotifier`) that listens to auth state changes and triggers router re-evaluation (`refreshListenable`). New authenticated routes go inside the `ShellRoute` (rendered inside `AppShell` — nav rail on wide screens, bottom nav on narrow); unauthenticated routes (login/register/splash) go outside it.
- **`core/providers/auth_provider.dart`** — `AuthController` persists the session token to `shared_preferences` and restores it on startup by calling `/auth/me`; `apiClientProvider` derives a fresh `ApiClient` from the current `authProvider` token.
- **`features/<resource>/`** — screens and dialogs per resource (e.g. `features/contacts/contacts_list_screen.dart`, `contact_detail_screen.dart`, `contact_form_dialog.dart`). Follow this screen/detail/form-dialog split for new resources.
- **`widgets/`** — small shared UI pieces (empty states, avatars, confirm dialogs, stat cards) reused across features.
- Model classes in `core/models/*.dart` mirror the backend's camelCase JSON shape via `fromJson`/`toJson`, matching `models/models.dart` on the backend field-for-field.

## Conventions to follow

- Every new backend list/detail/mutation endpoint needs a matching repository method and (if it's a list-backed screen) a `ListNotifier` subclass — the two sides are meant to be added together.
- Keep DB schema changes as additive, idempotent `CREATE TABLE IF NOT EXISTS` / `ALTER TABLE` statements in `db/database.dart._migrate()`; there's no migration tool.
- No test suite currently exists in either package — `dart test` / `flutter test` will report no tests found until one is added.
