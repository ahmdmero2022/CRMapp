# CRM App

A full-stack CRM (Customer Relationship Management) application built entirely in **Flutter & Dart** — a Flutter web frontend with Material 3 design, backed by a Dart REST API and a SQLite database.

## Run it on GitHub (Codespaces)

Click **Code → Codespaces → Create codespace on main** on this repo. The devcontainer (`.devcontainer/devcontainer.json`) comes with Flutter/Dart preinstalled, builds the frontend and starts the backend automatically, and forwards port `8080` — open that forwarded port and the app is live, database included. No local setup needed.

CI (`.github/workflows/ci.yml`) runs `dart analyze`/`dart test` for the backend and `flutter analyze`/`flutter build web` for the frontend on every push and pull request.

## Features

- **Authentication** — register/login with hashed passwords (salted PBKDF2-style HMAC) and signed session tokens
- **Dashboard** — live stats, pipeline-by-stage bar chart, leads-by-status pie chart, recent activity feed, upcoming tasks
- **Contacts** — CRUD, search, company linkage, per-contact activity timeline, tasks, and linked deals
- **Companies** — CRUD, search, linked contacts and deals with rollup counts
- **Leads** — CRUD, status pipeline (new → contacted → qualified/unqualified → converted), one-click **convert to contact + deal**
- **Deals pipeline** — Kanban board with drag-and-drop between stages, per-stage totals, deal detail with tasks/activity
- **Tasks** — due dates, priority, completion toggle, linkable to any contact/company/lead/deal
- **Activity timeline** — notes and auto-logged status-change events on every record

## Architecture

```
CRMapp/
├── backend/    Dart REST API (shelf + shelf_router + sqlite3)
└── frontend/   Flutter web app (Riverpod + go_router + fl_chart)
```

### Backend (`/backend`)

- **Framework**: [`shelf`](https://pub.dev/packages/shelf) + [`shelf_router`](https://pub.dev/packages/shelf_router)
- **Database**: SQLite via [`sqlite3`](https://pub.dev/packages/sqlite3) (file-based, zero setup — lives at `backend/data/crm.db`)
- **Auth**: salted/stretched password hashes + custom HMAC-signed bearer tokens (no external JWT dependency)
- **API**: JSON REST under `/api/*` — see [`backend/lib/src/handlers`](backend/lib/src/handlers) for every route
- Also serves the built Flutter web app as static files, so a single running process can host the whole product

### Frontend (`/frontend`)

- **State management**: [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod) — repository classes wrap the REST API, list controllers expose `AsyncValue<List<T>>` with optimistic updates (kanban drag, task-complete toggle)
- **Routing**: [`go_router`](https://pub.dev/packages/go_router) with an auth-aware redirect guard and a persistent shell (nav rail on wide screens, bottom nav on narrow)
- **Charts**: [`fl_chart`](https://pub.dev/packages/fl_chart)
- **Design**: Material 3, light/dark theme, responsive layouts throughout

## Running locally

### Prerequisites

- [Dart SDK](https://dart.dev/get-dart) 3.5+
- [Flutter SDK](https://flutter.dev) 3.24+ (includes Dart)

### 1. Run the backend API only (fastest for API development)

```bash
cd backend
dart pub get
dart run bin/server.dart
```

The API listens on `http://localhost:8080/api/*`. On first run it creates `backend/data/crm.db` and seeds the default pipeline stages (New, Qualified, Proposal, Negotiation, Won, Lost).

Environment variables (all optional):

| Variable      | Default              | Purpose                              |
|---------------|----------------------|---------------------------------------|
| `PORT`        | `8080`               | HTTP port                             |
| `DB_PATH`     | `data/crm.db`         | SQLite file location                  |
| `JWT_SECRET`  | random per boot        | HMAC signing secret — **set this in production** (otherwise sessions are invalidated on every restart) |
| `ALLOWED_ORIGIN` | `*`                 | CORS origin allowed to call the API — restrict this if the API is ever exposed cross-origin |
| `WEB_ROOT`    | `../frontend/build/web` | Directory of the built frontend to serve |

### 2. Run the frontend against that API (live-reload development)

```bash
cd frontend
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

### 3. Production-style: one process serving both

```bash
cd frontend
flutter build web --release --web-renderer html
cd ../backend
dart pub get
dart run bin/server.dart
```

Visit `http://localhost:8080` — the backend serves the compiled Flutter app and the `/api` routes from the same origin, so no CORS/base-URL configuration is needed.

> **Note on web renderer**: the app is built with `--web-renderer html` so it never depends on downloading Google's CanvasKit runtime from an external CDN at startup — it works fully offline/air-gapped once built.

## Default flow

There's no seeded demo account — register a new user from the app's "Create one" link on first run. Every account currently shares the same workspace (all records are visible to all users), which keeps a small-team CRM simple; `owner_id` columns are already in place if per-user scoping is wanted later.
