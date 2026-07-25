import 'dart:io';

import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

/// Wraps the single SQLite connection used by the whole server and owns
/// schema creation + seed data. Kept as one class so handlers can share
/// a consistent view of the DB without threading a raw [Database] around.
class AppDatabase {
  AppDatabase._(this.db);

  final Database db;
  static const uuid = Uuid();

  factory AppDatabase.open(String path) {
    final file = File(path);
    if (!file.parent.existsSync()) {
      file.parent.createSync(recursive: true);
    }
    final db = sqlite3.open(path);
    db.execute('PRAGMA foreign_keys = ON;');
    final app = AppDatabase._(db);
    app._migrate();
    app._seedPipelineStages();
    return app;
  }

  void _migrate() {
    db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        password_salt TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'member',
        avatar_color TEXT NOT NULL,
        created_at TEXT NOT NULL
      );
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS companies (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        industry TEXT,
        website TEXT,
        phone TEXT,
        address TEXT,
        notes TEXT,
        owner_id TEXT REFERENCES users(id) ON DELETE SET NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS contacts (
        id TEXT PRIMARY KEY,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        job_title TEXT,
        company_id TEXT REFERENCES companies(id) ON DELETE SET NULL,
        owner_id TEXT REFERENCES users(id) ON DELETE SET NULL,
        tags TEXT,
        notes TEXT,
        avatar_color TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS pipeline_stages (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        color TEXT NOT NULL
      );
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS leads (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        source TEXT,
        status TEXT NOT NULL DEFAULT 'new',
        company_name TEXT,
        estimated_value REAL DEFAULT 0,
        owner_id TEXT REFERENCES users(id) ON DELETE SET NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS deals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        value REAL NOT NULL DEFAULT 0,
        stage_id TEXT NOT NULL REFERENCES pipeline_stages(id),
        contact_id TEXT REFERENCES contacts(id) ON DELETE SET NULL,
        company_id TEXT REFERENCES companies(id) ON DELETE SET NULL,
        owner_id TEXT REFERENCES users(id) ON DELETE SET NULL,
        expected_close_date TEXT,
        probability INTEGER NOT NULL DEFAULT 50,
        status TEXT NOT NULL DEFAULT 'open',
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        priority TEXT NOT NULL DEFAULT 'medium',
        status TEXT NOT NULL DEFAULT 'pending',
        related_type TEXT,
        related_id TEXT,
        owner_id TEXT REFERENCES users(id) ON DELETE SET NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS activities (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        content TEXT NOT NULL,
        related_type TEXT NOT NULL,
        related_id TEXT NOT NULL,
        owner_id TEXT REFERENCES users(id) ON DELETE SET NULL,
        created_at TEXT NOT NULL
      );
    ''');

    db.execute(
        'CREATE INDEX IF NOT EXISTS idx_contacts_company ON contacts(company_id);');
    db.execute(
        'CREATE INDEX IF NOT EXISTS idx_deals_stage ON deals(stage_id);');
    db.execute(
        'CREATE INDEX IF NOT EXISTS idx_activities_related ON activities(related_type, related_id);');
    db.execute(
        'CREATE INDEX IF NOT EXISTS idx_tasks_related ON tasks(related_type, related_id);');
  }

  void _seedPipelineStages() {
    final count =
        db.select('SELECT COUNT(*) as c FROM pipeline_stages').first['c']
            as int;
    if (count > 0) {
      _rebrandLegacyStageColors();
      return;
    }

    final stages = [
      ('New', 0, '#60A5FA'),
      ('Qualified', 1, '#3B82F6'),
      ('Proposal', 2, '#2563EB'),
      ('Negotiation', 3, '#1D4ED8'),
      ('Won', 4, '#22C55E'),
      ('Lost', 5, '#EF4444'),
    ];
    final stmt = db.prepare(
        'INSERT INTO pipeline_stages (id, name, order_index, color) VALUES (?, ?, ?, ?)');
    for (final s in stages) {
      stmt.execute([uuid.v4(), s.$1, s.$2, s.$3]);
    }
    stmt.dispose();
  }

  /// The original seed used a violet/orange accent for New/Proposal/
  /// Negotiation; nudge those specific defaults onto the current blue ramp
  /// without touching colors a user has since customized.
  void _rebrandLegacyStageColors() {
    const legacyToNew = {
      'New': ('#6366F1', '#60A5FA'),
      'Proposal': ('#F59E0B', '#2563EB'),
      'Negotiation': ('#F97316', '#1D4ED8'),
    };
    for (final entry in legacyToNew.entries) {
      db.execute(
        'UPDATE pipeline_stages SET color = ? WHERE name = ? AND color = ?',
        [entry.value.$2, entry.key, entry.value.$1],
      );
    }
  }

  void dispose() => db.dispose();
}
