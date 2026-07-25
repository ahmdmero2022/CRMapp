import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers/companies_provider.dart';
import '../../core/providers/detail_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/initials_avatar.dart';
import 'company_form_dialog.dart';

class CompanyDetailScreen extends ConsumerWidget {
  const CompanyDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detailAsync = ref.watch(companyDetailProvider(id));

    return Scaffold(
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(companyDetailProvider(id)),
        ),
        data: (detail) {
          final company = detail.company;
          final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/companies'),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 4),
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(Icons.apartment,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(company.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            if (company.industry != null)
                              Text(company.industry!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () async {
                          final result =
                              await showCompanyFormDialog(context, existing: company);
                          if (result == null) return;
                          await ref
                              .read(companiesControllerProvider.notifier)
                              .update(id, result.body);
                          ref.invalidate(companyDetailProvider(id));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final confirmed = await confirmDialog(context,
                              title: l10n.deleteCompanyTitle,
                              message: l10n.deleteCompanyMessage(company.name));
                          if (!confirmed) return;
                          await ref
                              .read(companiesControllerProvider.notifier)
                              .delete(id);
                          if (context.mounted) context.go('/companies');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.companyInfoTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 16),
                          if (company.website != null)
                            _InfoRow(icon: Icons.link, value: company.website!),
                          if (company.phone != null)
                            _InfoRow(icon: Icons.phone_outlined, value: company.phone!),
                          if (company.address != null)
                            _InfoRow(
                                icon: Icons.location_on_outlined, value: company.address!),
                          if (company.notes != null && company.notes!.isNotEmpty) ...[
                            const Divider(height: 24),
                            Text(l10n.notesLabel, style: Theme.of(context).textTheme.labelLarge),
                            const SizedBox(height: 4),
                            Text(company.notes!),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.contactsWithCount(detail.contacts.length),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          if (detail.contacts.isEmpty)
                            Text(l10n.noContactsYet)
                          else
                            for (final contact in detail.contacts)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: InitialsAvatar(
                                    text: contact.initials, colorHex: contact.avatarColor),
                                title: Text(contact.fullName),
                                subtitle: Text(contact.jobTitle ?? contact.email ?? ''),
                                onTap: () => context.go('/contacts/${contact.id}'),
                              ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.dealsWithCount(detail.deals.length),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          if (detail.deals.isEmpty)
                            Text(l10n.noDealsYetPlain)
                          else
                            for (final deal in detail.deals)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(deal.title)),
                                    Text(currency.format(deal.value),
                                        style:
                                            const TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.value});
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Text(value),
        ],
      ),
    );
  }
}
