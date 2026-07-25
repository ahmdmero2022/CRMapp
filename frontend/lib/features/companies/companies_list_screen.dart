import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/company.dart';
import '../../core/providers/companies_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/pagination_footer.dart';
import '../../widgets/section_header.dart';
import '../../widgets/sort_control.dart';
import 'company_form_dialog.dart';

class CompaniesListScreen extends ConsumerStatefulWidget {
  const CompaniesListScreen({super.key});

  @override
  ConsumerState<CompaniesListScreen> createState() => _CompaniesListScreenState();
}

class _CompaniesListScreenState extends ConsumerState<CompaniesListScreen> {
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
        ref.read(companiesControllerProvider.notifier).setSearch(q);
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
      ref.read(companiesControllerProvider.notifier).setSearch(value);
    });
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    final result = await showCompanyFormDialog(context);
    if (result == null) return;
    try {
      await ref.read(companiesControllerProvider.notifier).create(result.body);
      if (mounted) showSuccessSnackBar(context, l10n.companyCreatedMessage);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _edit(Company company) async {
    final l10n = AppLocalizations.of(context);
    final result = await showCompanyFormDialog(context, existing: company);
    if (result == null) return;
    try {
      await ref
          .read(companiesControllerProvider.notifier)
          .update(company.id, result.body);
      if (mounted) showSuccessSnackBar(context, l10n.companyUpdatedMessage);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _delete(Company company) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDialog(context,
        title: l10n.deleteCompanyTitle,
        message: l10n.deleteCompanyMessage(company.name));
    if (!confirmed) return;
    try {
      await ref.read(companiesControllerProvider.notifier).delete(company.id);
      if (mounted) showSuccessSnackBar(context, l10n.companyDeletedMessage);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final companiesAsync = ref.watch(companiesControllerProvider);
    final controller = ref.read(companiesControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: l10n.companiesTitle,
            subtitle: l10n.companiesSubtitle,
            actions: [
              FilledButton.icon(
                onPressed: _create,
                icon: const Icon(Icons.add),
                label: Text(l10n.addCompany),
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
                    hintText: l10n.searchCompaniesHint,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              const SizedBox(width: 12),
              SortControl(
                options: [
                  ('name', l10n.companyNameLabel),
                  ('industry', l10n.industryLabel),
                  ('createdAt', l10n.createdAtLabel),
                ],
                value: controller.sortBy,
                descending: controller.sortOrder == 'desc',
                onChanged: (field, descending) => ref
                    .read(companiesControllerProvider.notifier)
                    .setSort(field, order: descending ? 'desc' : 'asc'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: companiesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => ErrorState(
                message: err.toString(),
                onRetry: () => ref.read(companiesControllerProvider.notifier).refresh(),
              ),
              data: (companies) {
                if (companies.isEmpty) {
                  return EmptyState(
                    icon: Icons.apartment_outlined,
                    title: l10n.noCompaniesFound,
                  );
                }
                return ListView.separated(
                  itemCount: companies.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final company = companies[index];
                    return Card(
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(Icons.apartment,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        title: Text(company.name,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text([
                          if (company.industry != null) company.industry,
                          l10n.contactsCountShort(company.contactCount),
                          l10n.dealsCountShort(company.dealCount),
                        ].whereType<String>().join(' · ')),
                        onTap: () => context.go('/companies/${company.id}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') _edit(company);
                            if (value == 'delete') _delete(company);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                            PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
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
