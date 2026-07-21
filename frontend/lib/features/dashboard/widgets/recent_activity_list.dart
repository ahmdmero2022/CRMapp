import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/activity.dart';
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
    if (activities.isEmpty) {
      return const SizedBox(
        height: 160,
        child: EmptyState(icon: Icons.history, title: 'No activity yet'),
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
                        '${activity.ownerName ?? 'Someone'} · ${_relativeTime(activity.createdAt)}',
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

String _relativeTime(String iso) {
  final date = DateTime.tryParse(iso);
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat.yMMMd().format(date);
}
