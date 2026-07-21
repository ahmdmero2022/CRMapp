import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/activity.dart';
import '../../core/models/deal.dart';
import '../../core/models/task.dart';
import '../../core/providers/deals_provider.dart';
import '../../core/providers/detail_providers.dart';
import '../../core/providers/repositories.dart';
import '../../widgets/confirm_dialog.dart';
import '../tasks/task_form_dialog.dart';
import 'deal_form_dialog.dart';

Future<void> showDealDetailDialog(BuildContext context, String dealId) {
  return showDialog(
    context: context,
    builder: (context) => DealDetailDialog(dealId: dealId),
  );
}

class DealDetailDialog extends ConsumerWidget {
  const DealDetailDialog({super.key, required this.dealId});
  final String dealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(dealDetailProvider(dealId));
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: detailAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(child: Text(err.toString())),
            data: (data) {
              final deal = Deal.fromJson(data);
              final tasks =
                  (data['tasks'] as List).map((e) => CrmTask.fromJson(e)).toList();
              final activities = (data['activities'] as List)
                  .map((e) => Activity.fromJson(e))
                  .toList();

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(deal.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () async {
                            final result =
                                await showDealFormDialog(context, existing: deal);
                            if (result == null) return;
                            await ref
                                .read(dealsControllerProvider.notifier)
                                .update(dealId, result.body);
                            ref.invalidate(dealDetailProvider(dealId));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final confirmed = await confirmDialog(context,
                                title: 'Delete deal', message: 'Delete "${deal.title}"?');
                            if (!confirmed) return;
                            await ref
                                .read(dealsControllerProvider.notifier)
                                .delete(dealId);
                            if (context.mounted) Navigator.of(context).pop();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 20,
                      runSpacing: 8,
                      children: [
                        _StatChip(label: 'Value', value: currency.format(deal.value)),
                        _StatChip(label: 'Probability', value: '${deal.probability}%'),
                        _StatChip(
                            label: 'Status',
                            value: deal.status[0].toUpperCase() + deal.status.substring(1)),
                        if (deal.companyName != null)
                          _StatChip(label: 'Company', value: deal.companyName!),
                        if (deal.contactName != null)
                          _StatChip(label: 'Contact', value: deal.contactName!),
                        if (deal.expectedCloseDate != null)
                          _StatChip(
                              label: 'Expected close',
                              value: DateFormat.yMMMd()
                                  .format(DateTime.parse(deal.expectedCloseDate!))),
                      ],
                    ),
                    if (deal.notes != null && deal.notes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Notes', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(deal.notes!),
                    ],
                    const Divider(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Tasks',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final result = await showTaskFormDialog(context,
                                initialRelatedType: 'deal', initialRelatedId: dealId);
                            if (result == null) return;
                            await ref.read(tasksRepositoryProvider).create(result.body);
                            ref.invalidate(dealDetailProvider(dealId));
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add task'),
                        ),
                      ],
                    ),
                    if (tasks.isEmpty)
                      const Text('No tasks yet.')
                    else
                      for (final task in tasks)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: Icon(task.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked),
                          title: Text(task.title),
                        ),
                    const Divider(height: 32),
                    Text('Activity',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    if (activities.isEmpty)
                      const Text('No activity yet.')
                    else
                      for (final activity in activities)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text('• ${activity.content}'),
                        ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
