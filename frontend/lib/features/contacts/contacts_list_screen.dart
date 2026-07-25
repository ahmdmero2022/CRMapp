import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/contact.dart';
import '../../core/providers/contacts_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/initials_avatar.dart';
import '../../widgets/section_header.dart';
import 'contact_form_dialog.dart';

class ContactsListScreen extends ConsumerStatefulWidget {
  const ContactsListScreen({super.key});

  @override
  ConsumerState<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends ConsumerState<ContactsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    final result = await showContactFormDialog(context);
    if (result == null) return;
    try {
      await ref.read(contactsControllerProvider.notifier).create(result.body);
      if (mounted) showSuccessSnackBar(context, l10n.contactCreatedMessage);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _edit(Contact contact) async {
    final l10n = AppLocalizations.of(context);
    final result = await showContactFormDialog(context, existing: contact);
    if (result == null) return;
    try {
      await ref
          .read(contactsControllerProvider.notifier)
          .update(contact.id, result.body);
      if (mounted) showSuccessSnackBar(context, l10n.contactUpdatedMessage);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _delete(Contact contact) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDialog(
      context,
      title: l10n.deleteContactTitle,
      message: l10n.deleteContactMessage(contact.fullName),
    );
    if (!confirmed) return;
    try {
      await ref.read(contactsControllerProvider.notifier).delete(contact.id);
      if (mounted) showSuccessSnackBar(context, l10n.contactDeletedMessage);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final contactsAsync = ref.watch(contactsControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: l10n.contactsTitle,
            subtitle: l10n.contactsSubtitle,
            actions: [
              FilledButton.icon(
                onPressed: _create,
                icon: const Icon(Icons.add),
                label: Text(l10n.addContact),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.searchContactsHint,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) =>
                ref.read(contactsControllerProvider.notifier).setSearch(value),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: contactsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => ErrorState(
                message: err.toString(),
                onRetry: () => ref.read(contactsControllerProvider.notifier).refresh(),
              ),
              data: (contacts) {
                if (contacts.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_outline,
                    title: l10n.noContactsFoundTitle,
                    subtitle: l10n.noContactsFoundSubtitle,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(contactsControllerProvider.notifier).refresh(),
                  child: ListView.separated(
                    itemCount: contacts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return Card(
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: InitialsAvatar(
                            text: contact.initials,
                            colorHex: contact.avatarColor,
                          ),
                          title: Text(contact.fullName,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text([
                            if (contact.jobTitle != null) contact.jobTitle,
                            if (contact.companyName != null) contact.companyName,
                            if (contact.email != null) contact.email,
                          ].whereType<String>().join(' · ')),
                          onTap: () => context.go('/contacts/${contact.id}'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') _edit(contact);
                              if (value == 'delete') _delete(contact);
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                              PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
