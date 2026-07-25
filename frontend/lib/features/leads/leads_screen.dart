import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/lead.dart';
import '../../core/providers/leads_provider.dart';
import '../../core/utils/enum_labels.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/pagination_footer.dart';
import '../../widgets/section_header.dart';
import '../../widgets/sort_control.dart';
import 'lead_form_dialog.dart';
import 'leads_kanban_board.dart';

enum _ViewMode { list, board }

const _listPageSize = 25;
const _boardPageSize = 500;

class LeadsScreen extends ConsumerStatefulWidget {
  const LeadsScreen({super.key});

  @override
  ConsumerState<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends ConsumerState<LeadsScreen> {
  String? _statusFilter;
  _ViewMode _viewMode = _ViewMode.list;
  final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _appliedInitialQuery = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_appliedInitialQuery) {
      _appliedInitialQuery = true;
      final q = GoRouterState.of(context).uri.queryParameters['q'];
      if (q != null && q.isNotEmpty) {
        _searchController.text = q;
        ref.read(leadsControllerProvider.notifier).setSearch(q);
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(leadsControllerProvider.notifier).setSearch(value);
    });
  }

  void _setViewMode(_ViewMode mode) {
    if (mode == _viewMode) return;
    setState(() => _viewMode = mode);
    ref
        .read(leadsControllerProvider.notifier)
        .setPageSize(mode == _ViewMode.board ? _boardPageSize : _listPageSize);
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    final result = await showLeadFormDialog(context);
    if (result == null) return;
    try {
      await ref.read(leadsControllerProvider.notifier).create(result.body);
      if (mounted) showSuccessSnackBar(context, l10n.leadCreatedMessage);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _edit(Lead lead) async {
    final l10n = AppLocalizations.of(context);
    final result = await showLeadFormDialog(context, existing: lead);
    if (result == null) return;
    try {
      await ref.read(leadsControllerProvider.notifier).update(lead.id, result.body);
      if (mounted) showSuccessSnackBar(context, l10n.leadUpdatedMessage);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _delete(Lead lead) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDialog(context,
        title: l10n.deleteLeadTitle, message: l10n.deleteLeadMessage(lead.name));
    if (!confirmed) return;
    await ref.read(leadsControllerProvider.notifier).delete(lead.id);
  }

  Future<void> _convert(Lead lead) async {
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
      if (mounted) {
        showSuccessSnackBar(context, l10n.leadConvertedMessage);
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final leadsAsync = ref.watch(leadsControllerProvider);
    final controller = ref.read(leadsControllerProvider.notifier);
    final isBoard = _viewMode == _ViewMode.board;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: l10n.leadsTitle,
            subtitle: l10n.leadsSubtitle,
            actions: [
              SegmentedButton<_ViewMode>(
                segments: [
                  ButtonSegment(
                      value: _ViewMode.list,
                      icon: const Icon(Icons.view_list_outlined),
                      label: Text(l10n.listViewLabel)),
                  ButtonSegment(
                      value: _ViewMode.board,
                      icon: const Icon(Icons.view_kanban_outlined),
                      label: Text(l10n.boardViewLabel)),
                ],
                selected: {_viewMode},
                onSelectionChanged: (selection) => _setViewMode(selection.first),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _create,
                icon: const Icon(Icons.add),
                label: Text(l10n.addLead),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchLeadsHint,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              if (!isBoard) ...[
                const SizedBox(width: 12),
                SortControl(
                  options: [
                    ('name', l10n.nameLabel),
                    ('estimatedValue', l10n.estimatedValueLabel),
                    ('createdAt', l10n.createdAtLabel),
                  ],
                  value: controller.sortBy,
                  descending: controller.sortOrder == 'desc',
                  onChanged: (field, descending) => ref
                      .read(leadsControllerProvider.notifier)
                      .setSort(field, order: descending ? 'desc' : 'asc'),
                ),
              ],
            ],
          ),
          if (!isBoard) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.allFilterLabel),
                  selected: _statusFilter == null,
                  onSelected: (_) {
                    setState(() => _statusFilter = null);
                    ref.read(leadsControllerProvider.notifier).setStatusFilter(null);
                  },
                ),
                for (final status in Lead.statuses)
                  ChoiceChip(
                    label: Text(leadStatusLabel(l10n, status)),
                    selected: _statusFilter == status,
                    onSelected: (_) {
                      setState(() => _statusFilter = status);
                      ref
                          .read(leadsControllerProvider.notifier)
                          .setStatusFilter(status);
                    },
                  ),
              ],
            ),
          ],
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
                  return EmptyState(
                      icon: Icons.filter_alt_outlined, title: l10n.noLeadsFoundTitle);
                }
                if (isBoard) {
                  return LeadsKanbanBoard(leads: leads);
                }
                return ListView.separated(
                  itemCount: leads.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final lead = leads[index];
                    final color = leadStatusColors[lead.status] ?? Colors.grey;
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
                          if (lead.source != null) l10n.viaSourceLabel(lead.source!),
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
                              child: Text(leadStatusLabel(l10n, lead.status),
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
                                  PopupMenuItem(
                                      value: 'convert', child: Text(l10n.convertActionLabel)),
                                PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                                PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
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
          if (!isBoard)
            PaginationFooter(
              page: controller.page,
              totalPages: controller.totalPages,
              onPageChanged: (page) => controller.setPage(page),
            ),
        ],
      ),
    );
  }
}
