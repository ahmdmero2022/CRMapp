import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/dashboard_stats.dart';
import '../../core/providers/dashboard_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import 'widgets/deals_by_stage_chart.dart';
import 'widgets/leads_by_status_chart.dart';
import 'widgets/recent_activity_list.dart';
import 'widgets/upcoming_tasks_list.dart';

final _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(dashboardStatsProvider.future),
      child: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(dashboardStatsProvider),
        ),
        data: (stats) => _DashboardBody(stats: stats),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final statCrossAxisCount = width > 1200 ? 4 : (width > 700 ? 2 : 1);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Overview',
            subtitle: "Here's what's happening with your business today.",
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: statCrossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: [
              StatCard(
                label: 'Contacts',
                value: '${stats.totalContacts}',
                icon: Icons.people,
                color: AppTheme.info,
              ),
              StatCard(
                label: 'Companies',
                value: '${stats.totalCompanies}',
                icon: Icons.apartment,
                color: AppTheme.seed,
              ),
              StatCard(
                label: 'Open Deals',
                value: '${stats.openDeals}',
                subtitle: '${_currencyFormat.format(stats.openDealsValue)} pipeline',
                icon: Icons.trending_up,
                color: AppTheme.warning,
              ),
              StatCard(
                label: 'Won Revenue',
                value: _currencyFormat.format(stats.wonDealsValue),
                icon: Icons.emoji_events,
                color: AppTheme.success,
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: statCrossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: [
              StatCard(
                label: 'Total Leads',
                value: '${stats.totalLeads}',
                icon: Icons.filter_alt,
                color: AppTheme.seed,
              ),
              StatCard(
                label: 'Tasks Due Today',
                value: '${stats.tasksDueToday}',
                icon: Icons.today,
                color: AppTheme.info,
              ),
              StatCard(
                label: 'Overdue Tasks',
                value: '${stats.overdueTasks}',
                icon: Icons.warning_amber,
                color: stats.overdueTasks > 0 ? AppTheme.danger : AppTheme.success,
              ),
            ],
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              final pipelineCard = _ChartCard(
                title: 'Pipeline by Stage',
                child: DealsByStageChart(stages: stats.dealsByStage),
              );
              final leadsCard = _ChartCard(
                title: 'Leads by Status',
                child: LeadsByStatusChart(leadsByStatus: stats.leadsByStatus),
              );
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: pipelineCard),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: leadsCard),
                  ],
                );
              }
              return Column(
                children: [
                  pipelineCard,
                  const SizedBox(height: 16),
                  leadsCard,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              final activityCard = _ChartCard(
                title: 'Recent Activity',
                child: RecentActivityList(activities: stats.recentActivities),
              );
              final tasksCard = _ChartCard(
                title: 'Upcoming Tasks',
                action: TextButton(
                  onPressed: () => context.go('/tasks'),
                  child: const Text('View all'),
                ),
                child: UpcomingTasksList(tasks: stats.upcomingTasks),
              );
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: activityCard),
                    const SizedBox(width: 16),
                    Expanded(child: tasksCard),
                  ],
                );
              }
              return Column(
                children: [
                  activityCard,
                  const SizedBox(height: 16),
                  tasksCard,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child, this.action});

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                if (action != null) action!,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
