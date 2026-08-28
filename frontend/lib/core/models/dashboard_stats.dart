import 'activity.dart';
import 'task.dart';

class DealsByStage {
  DealsByStage({
    required this.stageId,
    required this.name,
    required this.color,
    required this.dealCount,
    required this.totalValue,
  });

  final String stageId;
  final String name;
  final String color;
  final int dealCount;
  final double totalValue;

  factory DealsByStage.fromJson(Map<String, dynamic> json) => DealsByStage(
        stageId: json['stageId'] as String,
        name: json['name'] as String,
        color: json['color'] as String,
        dealCount: (json['dealCount'] as num).toInt(),
        totalValue: (json['totalValue'] as num).toDouble(),
      );
}

class RevenueTrendPoint {
  RevenueTrendPoint({required this.month, required this.value});

  final String month;
  final double value;

  factory RevenueTrendPoint.fromJson(Map<String, dynamic> json) =>
      RevenueTrendPoint(
        month: json['month'] as String,
        value: (json['value'] as num).toDouble(),
      );
}

class TeamPerformanceRow {
  TeamPerformanceRow({
    required this.userId,
    required this.name,
    required this.openDeals,
    required this.wonDeals,
    required this.wonValue,
  });

  final String userId;
  final String name;
  final int openDeals;
  final int wonDeals;
  final double wonValue;

  factory TeamPerformanceRow.fromJson(Map<String, dynamic> json) =>
      TeamPerformanceRow(
        userId: json['userId'] as String,
        name: json['name'] as String,
        openDeals: (json['openDeals'] as num).toInt(),
        wonDeals: (json['wonDeals'] as num).toInt(),
        wonValue: (json['wonValue'] as num).toDouble(),
      );
}

class DashboardStats {
  DashboardStats({
    required this.totalContacts,
    required this.totalCompanies,
    required this.totalLeads,
    required this.openDeals,
    required this.wonDealsValue,
    required this.openDealsValue,
    required this.tasksDueToday,
    required this.overdueTasks,
    required this.dealsByStage,
    required this.leadsByStatus,
    required this.recentActivities,
    required this.upcomingTasks,
    required this.conversionRate,
    required this.revenueTrend,
    required this.teamPerformance,
    this.revenueDeltaPercent,
    this.leadsDeltaPercent,
  });

  final int totalContacts;
  final int totalCompanies;
  final int totalLeads;
  final int openDeals;
  final double wonDealsValue;
  final double openDealsValue;
  final int tasksDueToday;
  final int overdueTasks;
  final List<DealsByStage> dealsByStage;
  final Map<String, int> leadsByStatus;
  final List<Activity> recentActivities;
  final List<CrmTask> upcomingTasks;
  final double conversionRate;
  final List<RevenueTrendPoint> revenueTrend;
  final List<TeamPerformanceRow> teamPerformance;
  final double? revenueDeltaPercent;
  final double? leadsDeltaPercent;

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
        totalContacts: (json['totalContacts'] as num).toInt(),
        totalCompanies: (json['totalCompanies'] as num).toInt(),
        totalLeads: (json['totalLeads'] as num).toInt(),
        openDeals: (json['openDeals'] as num).toInt(),
        wonDealsValue: (json['wonDealsValue'] as num).toDouble(),
        openDealsValue: (json['openDealsValue'] as num).toDouble(),
        tasksDueToday: (json['tasksDueToday'] as num).toInt(),
        overdueTasks: (json['overdueTasks'] as num).toInt(),
        dealsByStage: (json['dealsByStage'] as List)
            .map((e) => DealsByStage.fromJson(e as Map<String, dynamic>))
            .toList(),
        leadsByStatus: (json['leadsByStatus'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toInt())),
        recentActivities: (json['recentActivities'] as List)
            .map((e) => Activity.fromJson(e as Map<String, dynamic>))
            .toList(),
        upcomingTasks: (json['upcomingTasks'] as List)
            .map((e) => CrmTask.fromJson(e as Map<String, dynamic>))
            .toList(),
        conversionRate: (json['conversionRate'] as num?)?.toDouble() ?? 0.0,
        revenueTrend: (json['revenueTrend'] as List? ?? [])
            .map((e) => RevenueTrendPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        teamPerformance: (json['teamPerformance'] as List? ?? [])
            .map((e) => TeamPerformanceRow.fromJson(e as Map<String, dynamic>))
            .toList(),
        revenueDeltaPercent: (json['revenueDeltaPercent'] as num?)?.toDouble(),
        leadsDeltaPercent: (json['leadsDeltaPercent'] as num?)?.toDouble(),
      );
}
