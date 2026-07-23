import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/task.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../widgets/empty_state.dart';

class UpcomingTasksList extends StatelessWidget {
  const UpcomingTasksList({super.key, required this.tasks});

  final List<CrmTask> tasks;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (tasks.isEmpty) {
      return SizedBox(
        height: 160,
        child: EmptyState(icon: Icons.check_circle_outline, title: l10n.allCaughtUpTitle),
      );
    }
    return Column(
      children: [
        for (final task in tasks)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.priorityColor(task.priority),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title, style: Theme.of(context).textTheme.bodyMedium),
                      if (task.relatedLabel != null)
                        Text(task.relatedLabel!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                if (task.dueDate != null)
                  Text(
                    DateFormat.MMMd().format(DateTime.parse(task.dueDate!)),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: task.isOverdue
                            ? AppTheme.danger
                            : Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
