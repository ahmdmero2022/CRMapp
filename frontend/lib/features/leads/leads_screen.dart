import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/lead.dart';
import '../../core/providers/leads_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_header.dart';
import 'lead_form_dialog.dart';

const _statusColors = {
  'new': Color(0xFF3B82F6),
  'contacted': Color(0xFF6366F1),
  'qualified': Color(0xFF22C55E),
  'unqualified': Color(0xFFEF4444),
  'converted': Color(0xFFF59E0B),
};

class LeadsScreen extends ConsumerStatefulWidget {
  const LeadsScreen({super.key});

  @override
  ConsumerState<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends ConsumerState<LeadsScreen> {
  String? _statusFilter;
  final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

  Future<void> _create() async {
    final result = await showLeadFormDialog(context);
    if (result == null) return;
    try {
      await ref.read(leadsControllerProvider.notifier).create(result.body);
      if (mounted) showSuccessSnackBar(context, 'Lead created');
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _edit(Lead lead) async {
    final result = await showLeadFormDialog(context, existing: lead);
    if (result == null) return;
    try {
      await ref.read(leadsControllerProvider.notifier).update(lead.id, result.body);
      if (mounted) showSuccessSnackBar(context, 'Lead updated');
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _delete(Lead lead) async {
    final confirmed =
        await confirmDialog(context, title: 'Delete lead', message: 'Delete ${lead.name}?');
    if (!confirmed) return;
    await ref.read(leadsControllerProvider.notifier).delete(lead.id);
  }

  Future<void> _convert(Lead lead) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Convert lead',
      message:
          'Convert "${lead.name}" into a contact and a new deal in the pipeline?',
      confirmLabel: 'Convert',
      destructive: false,
    );
    if (!confirmed) return;
    try {
      await ref.read(leadsControllerProvider.notifier).convert(lead.id);
      if (mounted) {
        showSuccessSnackBar(context, 'Lead converted to contact + deal');
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(leadsControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Leads',
            subtitle: 'Prospects waiting to be qualified.',
            actions: [
              FilledButton.icon(
                onPressed: _create,
                icon: const Icon(Icons.add),
                label: const Text('Add Lead'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _statusFilter == null,
                onSelected: (_) {
                  setState(() => _statusFilter = null);
                  ref.read(leadsControllerProvider.notifier).setStatusFilter(null);
                },
              ),
              for (final status in Lead.statuses)
                ChoiceChip(
                  label: Text(status),
                  selected: _statusFilter == status,
                  onSelected: (_) {
                    setState(() => _statusFilter = status);
                    ref.read(leadsControllerProvider.notifier).setStatusFilter(status);
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: leadsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => ErrorState(
                message: err.toString(),
                onRetry: () => ref.read(leadsControllerProvider.notifier).refresh(),
              ),
              data: (leads) {
                if (leads.isEmpty) {
                  return const EmptyState(
                      icon: Icons.filter_alt_outlined, title: 'No leads found');
                }
                return ListView.separated(
                  itemCount: leads.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final lead = leads[index];
                    final color = _statusColors[lead.status] ?? Colors.grey;
                    return Card(
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.15),
                          child: Icon(Icons.person_outline, color: color),
                        ),
                        title: Text(lead.name,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text([
                          if (lead.companyName != null) lead.companyName,
                          if (lead.source != null) 'via ${lead.source}',
                          if (lead.estimatedValue > 0)
                            _currency.format(lead.estimatedValue),
                        ].whereType<String>().join(' · ')),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(lead.status,
                                  style: TextStyle(
                                      color: color, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') _edit(lead);
                                if (value == 'delete') _delete(lead);
                                if (value == 'convert') _convert(lead);
                              },
                              itemBuilder: (context) => [
                                if (lead.status != 'converted')
                                  const PopupMenuItem(
                                      value: 'convert', child: Text('Convert')),
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(
                                    value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
