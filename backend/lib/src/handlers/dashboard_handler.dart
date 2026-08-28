import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/database.dart';
import '../models/models.dart';
import '../utils/responses.dart';

class DashboardHandler {
  DashboardHandler(this.appDb);

  final AppDatabase appDb;

  Router get router {
    final router = Router();
    router.get('/stats', _stats);
    return router;
  }

  Future<Response> _stats(Request request) async {
    final db = appDb.db;
    final totalContacts = db.select('SELECT COUNT(*) c FROM contacts').first['c'] as int;
    final totalCompanies = db.select('SELECT COUNT(*) c FROM companies').first['c'] as int;
    final totalLeads = db.select('SELECT COUNT(*) c FROM leads').first['c'] as int;
    final openDeals = db.select("SELECT COUNT(*) c FROM deals WHERE status = 'open'").first['c'] as int;
    final wonDealsValue = (db.select(
                "SELECT COALESCE(SUM(value), 0) v FROM deals WHERE status = 'won'")
            .first['v'] as num)
        .toDouble();
    final openDealsValue = (db.select(
                "SELECT COALESCE(SUM(value), 0) v FROM deals WHERE status = 'open'")
            .first['v'] as num)
        .toDouble();
    final today = DateTime.now();
    final todayStr = today.toIso8601String().substring(0, 10);
    final tasksDueToday = db.select(
        "SELECT COUNT(*) c FROM tasks WHERE status = 'pending' AND due_date LIKE ?",
        ['$todayStr%']).first['c'] as int;
    final overdueTasks = db.select(
        "SELECT COUNT(*) c FROM tasks WHERE status = 'pending' AND due_date < ?",
        [todayStr]).first['c'] as int;

    final dealsByStageRows = db.select('''
      SELECT ps.id, ps.name, ps.color, ps.order_index,
        COUNT(d.id) as deal_count,
        COALESCE(SUM(CASE WHEN d.status != 'lost' THEN d.value ELSE 0 END), 0) as total_value
      FROM pipeline_stages ps
      LEFT JOIN deals d ON d.stage_id = ps.id
      GROUP BY ps.id
      ORDER BY ps.order_index
    ''');
    final dealsByStage = dealsByStageRows
        .map((r) => {
              'stageId': r['id'],
              'name': r['name'],
              'color': r['color'],
              'dealCount': r['deal_count'],
              'totalValue': (r['total_value'] as num).toDouble(),
            })
        .toList();

    final leadsByStatusRows = db.select(
        'SELECT status, COUNT(*) as c FROM leads GROUP BY status');
    final leadsByStatus = {
      for (final r in leadsByStatusRows) r['status'] as String: r['c'] as int
    };

    final recentActivitiesRows = db.select(
        'SELECT a.*, u.name as owner_name FROM activities a LEFT JOIN users u ON u.id = a.owner_id ORDER BY a.created_at DESC LIMIT 8');
    final recentActivities =
        recentActivitiesRows.map((r) => Activity.fromRow(r).toJson()).toList();

    final upcomingTasksRows = db.select(
        "SELECT * FROM tasks WHERE status = 'pending' ORDER BY due_date IS NULL, due_date ASC LIMIT 6");
    final upcomingTasks =
        upcomingTasksRows.map((r) => Task.fromRow(r).toJson()).toList();

    final convertedLeads = db
        .select("SELECT COUNT(*) c FROM leads WHERE status = 'converted'")
        .first['c'] as int;
    final conversionRate =
        totalLeads > 0 ? (convertedLeads / totalLeads) * 100 : 0.0;

    // Last 6 calendar months of won-deal revenue, zero-filled for months with
    // no wins. `updated_at` is used as a "won at" proxy since deals have no
    // dedicated won-date column — it's refreshed whenever a deal's stage (and
    // therefore status) changes, see DealsHandler._updateStage.
    String monthKey(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';
    final sixMonthsAgo = DateTime(today.year, today.month - 5, 1);
    final revenueRows = db.select(
      "SELECT strftime('%Y-%m', updated_at) as month, COALESCE(SUM(value), 0) as total FROM deals WHERE status = 'won' AND updated_at >= ? GROUP BY month",
      [sixMonthsAgo.toIso8601String()],
    );
    final revenueByMonth = {
      for (final r in revenueRows)
        r['month'] as String: (r['total'] as num).toDouble()
    };
    final revenueTrend = [
      for (var i = 5; i >= 0; i--)
        () {
          final month = monthKey(DateTime(today.year, today.month - i, 1));
          return {'month': month, 'value': revenueByMonth[month] ?? 0.0};
        }(),
    ];
    final revenueDeltaPercent = revenueTrend.length >= 2 &&
            (revenueTrend[revenueTrend.length - 2]['value'] as double) > 0
        ? ((revenueTrend.last['value'] as double) -
                (revenueTrend[revenueTrend.length - 2]['value'] as double)) /
            (revenueTrend[revenueTrend.length - 2]['value'] as double) *
            100
        : null;

    final thisMonthStart = DateTime(today.year, today.month, 1).toIso8601String();
    final lastMonthStart =
        DateTime(today.year, today.month - 1, 1).toIso8601String();
    final newLeadsThisMonth = db.select(
        'SELECT COUNT(*) c FROM leads WHERE created_at >= ?',
        [thisMonthStart]).first['c'] as int;
    final newLeadsLastMonth = db.select(
        'SELECT COUNT(*) c FROM leads WHERE created_at >= ? AND created_at < ?',
        [lastMonthStart, thisMonthStart]).first['c'] as int;
    final leadsDeltaPercent = newLeadsLastMonth > 0
        ? (newLeadsThisMonth - newLeadsLastMonth) / newLeadsLastMonth * 100
        : null;

    final teamRows = db.select('''
      SELECT u.id, u.name,
        COUNT(CASE WHEN d.status = 'open' THEN 1 END) as open_count,
        COUNT(CASE WHEN d.status = 'won' THEN 1 END) as won_count,
        COALESCE(SUM(CASE WHEN d.status = 'won' THEN d.value ELSE 0 END), 0) as won_value
      FROM users u
      LEFT JOIN deals d ON d.owner_id = u.id
      GROUP BY u.id, u.name
      ORDER BY won_value DESC, open_count DESC
    ''');
    final teamPerformance = teamRows
        .map((r) => {
              'userId': r['id'],
              'name': r['name'],
              'openDeals': r['open_count'],
              'wonDeals': r['won_count'],
              'wonValue': (r['won_value'] as num).toDouble(),
            })
        .toList();

    return jsonResponse({
      'totalContacts': totalContacts,
      'totalCompanies': totalCompanies,
      'totalLeads': totalLeads,
      'openDeals': openDeals,
      'wonDealsValue': wonDealsValue,
      'openDealsValue': openDealsValue,
      'tasksDueToday': tasksDueToday,
      'overdueTasks': overdueTasks,
      'dealsByStage': dealsByStage,
      'leadsByStatus': leadsByStatus,
      'recentActivities': recentActivities,
      'upcomingTasks': upcomingTasks,
      'conversionRate': conversionRate,
      'revenueTrend': revenueTrend,
      'teamPerformance': teamPerformance,
      'revenueDeltaPercent': revenueDeltaPercent,
      'leadsDeltaPercent': leadsDeltaPercent,
    });
  }
}
