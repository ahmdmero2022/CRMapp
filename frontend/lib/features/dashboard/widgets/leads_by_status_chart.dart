import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/empty_state.dart';

const _statusColors = {
  'new': AppTheme.info,
  'contacted': AppTheme.seed,
  'qualified': AppTheme.success,
  'unqualified': AppTheme.danger,
  'converted': AppTheme.warning,
};

class LeadsByStatusChart extends StatelessWidget {
  const LeadsByStatusChart({super.key, required this.leadsByStatus});

  final Map<String, int> leadsByStatus;

  @override
  Widget build(BuildContext context) {
    final total = leadsByStatus.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) {
      return const SizedBox(
        height: 220,
        child: EmptyState(
          icon: Icons.pie_chart_outline,
          title: 'No leads yet',
        ),
      );
    }

    final entries = leadsByStatus.entries.where((e) => e.value > 0).toList();

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 36,
              sections: [
                for (final e in entries)
                  PieChartSectionData(
                    value: e.value.toDouble(),
                    color: _statusColors[e.key] ?? AppTheme.seed,
                    title: '${e.value}',
                    titleStyle: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    radius: 48,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final e in entries)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _statusColors[e.key] ?? AppTheme.seed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(e.key, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
