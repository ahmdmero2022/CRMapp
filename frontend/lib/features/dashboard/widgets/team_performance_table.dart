import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/dashboard_stats.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../widgets/empty_state.dart';

final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

class TeamPerformanceTable extends StatelessWidget {
  const TeamPerformanceTable({super.key, required this.rows});

  final List<TeamPerformanceRow> rows;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (rows.isEmpty) {
      return SizedBox(
        height: 160,
        child: EmptyState(
          icon: Icons.groups_outlined,
          title: l10n.noLeadsYetTitle,
          subtitle: '',
        ),
      );
    }

    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 36,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 44,
        columnSpacing: 28,
        headingTextStyle: theme.textTheme.labelMedium
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        columns: [
          DataColumn(label: Text(l10n.teamPerformanceColumnMember)),
          DataColumn(label: Text(l10n.teamPerformanceColumnOpenDeals), numeric: true),
          DataColumn(label: Text(l10n.teamPerformanceColumnWonDeals), numeric: true),
          DataColumn(label: Text(l10n.teamPerformanceColumnWonValue), numeric: true),
        ],
        rows: [
          for (final row in rows)
            DataRow(cells: [
              DataCell(Text(row.name)),
              DataCell(Text('${row.openDeals}')),
              DataCell(Text('${row.wonDeals}')),
              DataCell(Text(_currency.format(row.wonValue))),
            ]),
        ],
      ),
    );
  }
}
