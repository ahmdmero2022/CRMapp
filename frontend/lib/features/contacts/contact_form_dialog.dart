import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/company.dart';
import '../../core/models/contact.dart';
import '../../core/providers/companies_provider.dart';
import '../../l10n/generated/app_localizations.dart';

class ContactFormResult {
  ContactFormResult(this.body);
  final Map<String, dynamic> body;
}

Future<ContactFormResult?> showContactFormDialog(
  BuildContext context, {
  Contact? existing,
  String? initialCompanyId,
}) {
  return showDialog<ContactFormResult>(
    context: context,
    builder: (context) => ContactFormDialog(
      existing: existing,
      initialCompanyId: initialCompanyId,
    ),
  );
}

class ContactFormDialog extends ConsumerStatefulWidget {
  const ContactFormDialog({super.key, this.existing, this.initialCompanyId});

  final Contact? existing;
  final String? initialCompanyId;

  @override
  ConsumerState<ContactFormDialog> createState() => _ContactFormDialogState();
}

class _ContactFormDialogState extends ConsumerState<ContactFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _firstName = TextEditingController(text: widget.existing?.firstName);
  late final _lastName = TextEditingController(text: widget.existing?.lastName);
  late final _email = TextEditingController(text: widget.existing?.email);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _jobTitle = TextEditingController(text: widget.existing?.jobTitle);
  late final _notes = TextEditingController(text: widget.existing?.notes);
  String? _companyId;

  @override
  void initState() {
    super.initState();
    _companyId = widget.existing?.companyId ?? widget.initialCompanyId;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _jobTitle.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final companiesAsync = ref.watch(companiesControllerProvider);
    return AlertDialog(
      title: Text(widget.existing == null ? l10n.addContact : l10n.editContact),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstName,
                        decoration: InputDecoration(labelText: l10n.firstNameLabel),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastName,
                        decoration: InputDecoration(labelText: l10n.lastNameLabel),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  decoration: InputDecoration(labelText: l10n.emailLabel),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  decoration: InputDecoration(labelText: l10n.phoneLabel),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _jobTitle,
                  decoration: InputDecoration(labelText: l10n.jobTitleLabel),
                ),
                const SizedBox(height: 12),
                companiesAsync.when(
                  data: (companies) => DropdownButtonFormField<String?>(
                    value: companies.any((c) => c.id == _companyId) ? _companyId : null,
                    decoration: InputDecoration(labelText: l10n.companyLabel),
                    items: [
                      DropdownMenuItem<String?>(value: null, child: Text(l10n.none)),
                      for (final Company c in companies)
                        DropdownMenuItem<String?>(value: c.id, child: Text(c.name)),
                    ],
                    onChanged: (value) => setState(() => _companyId = value),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notes,
                  decoration: InputDecoration(labelText: l10n.notesLabel),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(ContactFormResult({
              'firstName': _firstName.text.trim(),
              'lastName': _lastName.text.trim(),
              'email': _email.text.trim().isEmpty ? null : _email.text.trim(),
              'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
              'jobTitle': _jobTitle.text.trim().isEmpty ? null : _jobTitle.text.trim(),
              'companyId': _companyId,
              'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
            }));
          },
          child: Text(widget.existing == null ? l10n.create : l10n.save),
        ),
      ],
    );
  }
}
