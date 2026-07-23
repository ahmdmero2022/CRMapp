import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/dashboard_stats.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../widgets/empty_state.dart';

final _compactCurrency =
    NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 1);

class DealsByStageChart extends StatelessWidget {
  const DealsByStageChart({super.key, required this.stages});

  final List<DealsByStage> stages;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (stages.isEmpty || stages.every((s) => s.dealCount == 0)) {
      return SizedBox(
        height: 220,
        child: EmptyState(
          icon: Icons.bar_chart,
          title: l10n.noDealsYetTitle,
          subtitle: l10n.noDealsYetSubtitle,
        ),
      );
    }

    final maxValue = stages.map((s) => s.totalValue).fold<double>(0, (a, b) => a > b ? a : b);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;

    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          maxY: safeMax * 1.2,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) => Text(
                  _compactCurrency.format(value),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= stages.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(stages[i].name, style: const TextStyle(fontSize: 11)),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final stage = stages[groupIndex];
                return BarTooltipItem(
                  '${stage.name}\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text:
                          '${l10n.dealsCountShort(stage.dealCount)} · ${_compactCurrency.format(stage.totalValue)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                    ),
                  ],
                );
              },
            ),
          ),
          barGroups: [
            for (var i = 0; i < stages.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: stages[i].totalValue,
                    color: AppTheme.stageColor(stages[i].color),
                    width: 28,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
