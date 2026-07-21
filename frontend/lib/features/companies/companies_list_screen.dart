import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/company.dart';
import '../../core/providers/companies_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_header.dart';
import 'company_form_dialog.dart';

class CompaniesListScreen extends ConsumerStatefulWidget {
  const CompaniesListScreen({super.key});

  @override
  ConsumerState<CompaniesListScreen> createState() => _CompaniesListScreenState();
}

class _CompaniesListScreenState extends ConsumerState<CompaniesListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final result = await showCompanyFormDialog(context);
    if (result == null) return;
    try {
      await ref.read(companiesControllerProvider.notifier).create(result.body);
      if (mounted) showSuccessSnackBar(context, 'Company created');
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _edit(Company company) async {
    final result = await showCompanyFormDialog(context, existing: company);
    if (result == null) return;
    try {
      await ref
          .read(companiesControllerProvider.notifier)
          .update(company.id, result.body);
      if (mounted) showSuccessSnackBar(context, 'Company updated');
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _delete(Company company) async {
    final confirmed = await confirmDialog(context,
        title: 'Delete company', message: 'Delete ${company.name}?');
    if (!confirmed) return;
    try {
      await ref.read(companiesControllerProvider.notifier).delete(company.id);
      if (mounted) showSuccessSnackBar(context, 'Company deleted');
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final companiesAsync = ref.watch(companiesControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Companies',
            subtitle: 'Organizations you work with.',
            actions: [
              FilledButton.icon(
                onPressed: _create,
                icon: const Icon(Icons.add),
                label: const Text('Add Company'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search companies...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) =>
                ref.read(companiesControllerProvider.notifier).setSearch(value),
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
                  return const EmptyState(
                    icon: Icons.apartment_outlined,
                    title: 'No companies found',
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
                          '${company.contactCount} contacts',
                          '${company.dealCount} deals',
                        ].whereType<String>().join(' · ')),
                        onTap: () => context.go('/companies/${company.id}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') _edit(company);
                            if (value == 'delete') _delete(company);
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
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
