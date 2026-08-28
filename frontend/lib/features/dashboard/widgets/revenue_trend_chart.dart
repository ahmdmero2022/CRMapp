import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/dashboard_stats.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../widgets/empty_state.dart';

final _compactCurrency =
    NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 1);
final _monthLabel = DateFormat('MMM');

class RevenueTrendChart extends StatelessWidget {
  const RevenueTrendChart({super.key, required this.points});

  final List<RevenueTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (points.isEmpty || points.every((p) => p.value == 0)) {
      return SizedBox(
        height: 220,
        child: EmptyState(
          icon: Icons.show_chart,
          title: l10n.noRevenueYetTitle,
          subtitle: l10n.noRevenueYetSubtitle,
        ),
      );
    }

    final maxValue = points.map((p) => p.value).fold<double>(0, (a, b) => a > b ? a : b);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;

    return SizedBox(
      height: 240,
      child: LineChart(
        LineChartData(
          minY: 0,
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
                  if (i < 0 || i >= points.length) return const SizedBox.shrink();
                  final parts = points[i].month.split('-');
                  final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(_monthLabel.format(date),
                        style: const TextStyle(fontSize: 11)),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((spot) {
                final point = points[spot.x.toInt()];
                final parts = point.month.split('-');
                final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
                return LineTooltipItem(
                  '${DateFormat('MMMM yyyy').format(date)}\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: _compactCurrency.format(point.value),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: AppTheme.seed,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.seed.withOpacity(0.12),
              ),
              spots: [
                for (var i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), points[i].value),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
