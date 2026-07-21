import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/activity.dart';
import '../../core/models/contact.dart';
import '../../core/models/deal.dart';
import '../../core/models/task.dart';
import '../../core/providers/contacts_provider.dart';
import '../../core/providers/detail_providers.dart';
import '../../core/providers/repositories.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/initials_avatar.dart';
import '../tasks/task_form_dialog.dart';
import 'contact_form_dialog.dart';

class ContactDetailScreen extends ConsumerWidget {
  const ContactDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(contactDetailProvider(id));

    return Scaffold(
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(contactDetailProvider(id)),
        ),
        data: (data) => _ContactDetailBody(id: id, data: data),
      ),
    );
  }
}

class _ContactDetailBody extends ConsumerWidget {
  const _ContactDetailBody({required this.id, required this.data});

  final String id;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contact = Contact.fromJson(data);
    final deals = (data['deals'] as List).map((e) => Deal.fromJson(e)).toList();
    final tasks = (data['tasks'] as List).map((e) => CrmTask.fromJson(e)).toList();
    final activities =
        (data['activities'] as List).map((e) => Activity.fromJson(e)).toList();

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
                  onPressed: () => context.go('/contacts'),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 4),
                InitialsAvatar(text: contact.initials, colorHex: contact.avatarColor, radius: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contact.fullName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      if (contact.jobTitle != null || contact.companyName != null)
                        Text(
                          [contact.jobTitle, contact.companyName]
                              .whereType<String>()
                              .join(' at '),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    final result =
                        await showContactFormDialog(context, existing: contact);
                    if (result == null) return;
                    await ref
                        .read(contactsControllerProvider.notifier)
                        .update(id, result.body);
                    ref.invalidate(contactDetailProvider(id));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final confirmed = await confirmDialog(context,
                        title: 'Delete contact',
                        message: 'Delete ${contact.fullName}?');
                    if (!confirmed) return;
                    await ref.read(contactsControllerProvider.notifier).delete(id);
                    if (context.mounted) context.go('/contacts');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              final infoCard = _InfoCard(contact: contact);
              final dealsCard = _DealsCard(deals: deals);
              if (isWide) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: infoCard),
                      const SizedBox(width: 16),
                      Expanded(child: dealsCard),
                    ],
                  ),
                );
              }
              return Column(children: [infoCard, const SizedBox(height: 16), dealsCard]);
            }),
            const SizedBox(height: 16),
            _TasksCard(contactId: id, tasks: tasks),
            const SizedBox(height: 16),
            _ActivityCard(contactId: id, activities: activities),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.contact});
  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Info',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _InfoRow(icon: Icons.mail_outline, label: 'Email', value: contact.email),
            _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: contact.phone),
            _InfoRow(
                icon: Icons.apartment_outlined,
                label: 'Company',
                value: contact.companyName),
            if (contact.notes != null && contact.notes!.isNotEmpty) ...[
              const Divider(height: 24),
              Text('Notes', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(contact.notes!),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, this.value});
  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Text(value!),
        ],
      ),
    );
  }
}

class _DealsCard extends StatelessWidget {
  const _DealsCard({required this.deals});
  final List<Deal> deals;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deals',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (deals.isEmpty)
              const Text('No deals linked to this contact yet.')
            else
              for (final deal in deals)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(child: Text(deal.title)),
                      Text(currency.format(deal.value),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _TasksCard extends ConsumerWidget {
  const _TasksCard({required this.contactId, required this.tasks});
  final String contactId;
  final List<CrmTask> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        initialRelatedType: 'contact', initialRelatedId: contactId);
                    if (result == null) return;
                    await ref.read(tasksRepositoryProvider).create(result.body);
                    ref.invalidate(contactDetailProvider(contactId));
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add task'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (tasks.isEmpty)
              const Text('No tasks yet.')
            else
              for (final task in tasks)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: task.isCompleted
                        ? AppTheme.success
                        : Theme.of(context).colorScheme.outline,
                  ),
                  title: Text(task.title),
                  subtitle: task.dueDate != null
                      ? Text(DateFormat.yMMMd().format(DateTime.parse(task.dueDate!)))
                      : null,
                ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends ConsumerStatefulWidget {
  const _ActivityCard({required this.contactId, required this.activities});
  final String contactId;
  final List<Activity> activities;

  @override
  ConsumerState<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends ConsumerState<_ActivityCard> {
  final _noteController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _addNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    setState(() => _submitting = true);
    try {
      await ref.read(activitiesRepositoryProvider).create({
        'type': 'note',
        'content': text,
        'relatedType': 'contact',
        'relatedId': widget.contactId,
      });
      _noteController.clear();
      ref.invalidate(contactDetailProvider(widget.contactId));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity Timeline',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(hintText: 'Add a note...'),
                    onSubmitted: (_) => _addNote(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _submitting ? null : _addNote,
                  child: const Text('Post'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.activities.isEmpty)
              const Text('No activity yet.')
            else
              for (final activity in widget.activities)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(Icons.circle, size: 8),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(activity.content),
                            Text(
                              '${activity.ownerName ?? ''} · ${DateFormat.yMMMd().add_jm().format(DateTime.parse(activity.createdAt))}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
