import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/dashboard_stats.dart';
import '../../core/providers/dashboard_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fade_slide_in.dart';
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
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.of(context).size.width;
    final statCrossAxisCount = width > 1200 ? 4 : (width > 700 ? 2 : 1);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: l10n.overviewTitle,
            subtitle: l10n.overviewSubtitle,
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
              FadeSlideIn(
                delay: FadeSlideIn.staggerDelay(0),
                child: StatCard(
                  label: l10n.statContacts,
                  value: '${stats.totalContacts}',
                  icon: Icons.people,
                  color: AppTheme.info,
                ),
              ),
              FadeSlideIn(
                delay: FadeSlideIn.staggerDelay(1),
                child: StatCard(
                  label: l10n.statCompanies,
                  value: '${stats.totalCompanies}',
                  icon: Icons.apartment,
                  color: AppTheme.seed,
                ),
              ),
              FadeSlideIn(
                delay: FadeSlideIn.staggerDelay(2),
                child: StatCard(
                  label: l10n.statOpenDeals,
                  value: '${stats.openDeals}',
                  subtitle: l10n.pipelineValueSubtitle(
                      _currencyFormat.format(stats.openDealsValue)),
                  icon: Icons.trending_up,
                  color: AppTheme.warning,
                ),
              ),
              FadeSlideIn(
                delay: FadeSlideIn.staggerDelay(3),
                child: StatCard(
                  label: l10n.statWonRevenue,
                  value: _currencyFormat.format(stats.wonDealsValue),
                  icon: Icons.emoji_events,
                  color: AppTheme.success,
                ),
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
              FadeSlideIn(
                delay: FadeSlideIn.staggerDelay(4),
                child: StatCard(
                  label: l10n.statTotalLeads,
                  value: '${stats.totalLeads}',
                  icon: Icons.filter_alt,
                  color: AppTheme.seed,
                ),
              ),
              FadeSlideIn(
                delay: FadeSlideIn.staggerDelay(5),
                child: StatCard(
                  label: l10n.statTasksDueToday,
                  value: '${stats.tasksDueToday}',
                  icon: Icons.today,
                  color: AppTheme.info,
                ),
              ),
              FadeSlideIn(
                delay: FadeSlideIn.staggerDelay(6),
                child: StatCard(
                  label: l10n.statOverdueTasks,
                  value: '${stats.overdueTasks}',
                  icon: Icons.warning_amber,
                  color: stats.overdueTasks > 0
                      ? AppTheme.danger
                      : AppTheme.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              final pipelineCard = _ChartCard(
                title: l10n.pipelineByStageTitle,
                child: DealsByStageChart(stages: stats.dealsByStage),
              );
              final leadsCard = _ChartCard(
                title: l10n.leadsByStatusTitle,
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
                title: l10n.recentActivityTitle,
                child: RecentActivityList(activities: stats.recentActivities),
              );
              final tasksCard = _ChartCard(
                title: l10n.upcomingTasksTitle,
                action: TextButton(
                  onPressed: () => context.go('/tasks'),
                  child: Text(l10n.viewAllLink),
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
