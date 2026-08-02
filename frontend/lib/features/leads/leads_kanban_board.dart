import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/lead.dart';
import '../../core/providers/leads_provider.dart';
import '../../core/utils/enum_labels.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/hover_lift.dart';
import 'lead_form_dialog.dart';

const leadStatusColors = {
  'new': Color(0xFF60A5FA),
  'contacted': Color(0xFF1D4ED8),
  'qualified': Color(0xFF22C55E),
  'unqualified': Color(0xFFEF4444),
  'converted': Color(0xFFF59E0B),
};

final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

/// Kanban board for leads, grouped by [Lead.status] — mirrors
/// `DealsPipelineScreen`'s drag-and-drop board, but columns come from the
/// fixed [Lead.statuses] list instead of a fetched pipeline-stages table.
class LeadsKanbanBoard extends StatelessWidget {
  const LeadsKanbanBoard({super.key, required this.leads});

  final List<Lead> leads;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final status in Lead.statuses)
            _StatusColumn(
              status: status,
              leads: leads.where((l) => l.status == status).toList(),
            ),
        ],
      ),
    );
  }
}

class _StatusColumn extends ConsumerWidget {
  const _StatusColumn({required this.status, required this.leads});

  final String status;
  final List<Lead> leads;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final color = leadStatusColors[status] ?? Colors.grey;

    return DragTarget<Lead>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) async {
        try {
          await ref
              .read(leadsControllerProvider.notifier)
              .updateStatus(details.data.id, status);
        } catch (e) {
          if (context.mounted) showErrorSnackBar(context, e.toString());
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Container(
          width: 280,
          margin: const EdgeInsetsDirectional.only(end: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHovering
                ? color.withOpacity(0.08)
                : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovering ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(leadStatusLabel(l10n, status),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  Text('${leads.length}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: leads.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(l10n.noLeadsFoundTitle,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline)),
                        ),
                      )
                    : ListView.separated(
                        itemCount: leads.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _LeadCard(lead: leads[index]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LeadCard extends ConsumerWidget {
  const _LeadCard({required this.lead});
  final Lead lead;

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final result = await showLeadFormDialog(context, existing: lead);
    if (result == null) return;
    try {
      await ref.read(leadsControllerProvider.notifier).update(lead.id, result.body);
      if (context.mounted) showSuccessSnackBar(context, l10n.leadUpdatedMessage);
    } catch (e) {
      if (context.mounted) showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDialog(context,
        title: l10n.deleteLeadTitle, message: l10n.deleteLeadMessage(lead.name));
    if (!confirmed) return;
    await ref.read(leadsControllerProvider.notifier).delete(lead.id);
  }

  Future<void> _convert(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDialog(
      context,
      title: l10n.convertLeadTitle,
      message: l10n.convertLeadMessage(lead.name),
      confirmLabel: l10n.convertActionLabel,
      destructive: false,
    );
    if (!confirmed) return;
    try {
      await ref.read(leadsControllerProvider.notifier).convert(lead.id);
      if (context.mounted) showSuccessSnackBar(context, l10n.leadConvertedMessage);
    } catch (e) {
      if (context.mounted) showErrorSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final card = Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _edit(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(lead.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    onSelected: (value) {
                      if (value == 'edit') _edit(context, ref);
                      if (value == 'delete') _delete(context, ref);
                      if (value == 'convert') _convert(context, ref);
                    },
                    itemBuilder: (context) => [
                      if (lead.status != 'converted')
                        PopupMenuItem(
                            value: 'convert', child: Text(l10n.convertActionLabel)),
                      PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                      PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                    ],
                  ),
                ],
              ),
              if (lead.companyName != null || lead.source != null) ...[
                const SizedBox(height: 4),
                Text(
                  [
                    lead.companyName,
                    if (lead.source != null) l10n.viaSourceLabel(lead.source!),
                  ].whereType<String>().join(' · '),
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (lead.estimatedValue > 0) ...[
                const SizedBox(height: 6),
                Text(_currency.format(lead.estimatedValue),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700)),
              ],
            ],
          ),
        ),
      ),
    );

    return Draggable<Lead>(
      data: lead,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 256, child: card),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: HoverLift(child: card),
    );
  }
}
