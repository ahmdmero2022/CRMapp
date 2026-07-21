import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/contact.dart';
import '../../core/providers/contacts_provider.dart';
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
    final result = await showContactFormDialog(context);
    if (result == null) return;
    try {
      await ref.read(contactsControllerProvider.notifier).create(result.body);
      if (mounted) showSuccessSnackBar(context, 'Contact created');
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _edit(Contact contact) async {
    final result = await showContactFormDialog(context, existing: contact);
    if (result == null) return;
    try {
      await ref
          .read(contactsControllerProvider.notifier)
          .update(contact.id, result.body);
      if (mounted) showSuccessSnackBar(context, 'Contact updated');
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _delete(Contact contact) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Delete contact',
      message: 'Delete ${contact.fullName}? This cannot be undone.',
    );
    if (!confirmed) return;
    try {
      await ref.read(contactsControllerProvider.notifier).delete(contact.id);
      if (mounted) showSuccessSnackBar(context, 'Contact deleted');
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Contacts',
            subtitle: 'Everyone you do business with.',
            actions: [
              FilledButton.icon(
                onPressed: _create,
                icon: const Icon(Icons.add),
                label: const Text('Add Contact'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search contacts by name or email...',
              prefixIcon: Icon(Icons.search),
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
                  return const EmptyState(
                    icon: Icons.people_outline,
                    title: 'No contacts found',
                    subtitle: 'Try adjusting your search or add a new contact.',
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
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(value: 'delete', child: Text('Delete')),
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
