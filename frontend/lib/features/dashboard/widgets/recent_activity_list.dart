import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/activity.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../widgets/empty_state.dart';

IconData _iconForType(String type) {
  switch (type) {
    case 'call':
      return Icons.call;
    case 'email':
      return Icons.email_outlined;
    case 'meeting':
      return Icons.groups_outlined;
    case 'status_change':
      return Icons.swap_horiz;
    default:
      return Icons.sticky_note_2_outlined;
  }
}

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key, required this.activities});

  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (activities.isEmpty) {
      return SizedBox(
        height: 160,
        child: EmptyState(icon: Icons.history, title: l10n.noActivityYetTitle),
      );
    }
    return Column(
      children: [
        for (final activity in activities)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(_iconForType(activity.type),
                      size: 16, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activity.content,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 2),
                      Text(
                        '${activity.ownerName ?? l10n.someoneFallback} · ${_relativeTime(l10n, activity.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

String _relativeTime(AppLocalizations l10n, String iso) {
  final date = DateTime.tryParse(iso);
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return l10n.justNowLabel;
  if (diff.inMinutes < 60) return l10n.minutesAgoLabel(diff.inMinutes);
  if (diff.inHours < 24) return l10n.hoursAgoLabel(diff.inHours);
  if (diff.inDays < 7) return l10n.daysAgoLabel(diff.inDays);
  return DateFormat.yMMMd().format(date);
}
