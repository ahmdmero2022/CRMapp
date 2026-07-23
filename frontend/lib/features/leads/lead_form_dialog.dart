import 'package:flutter/material.dart';

import '../../core/models/lead.dart';
import '../../core/utils/enum_labels.dart';
import '../../l10n/generated/app_localizations.dart';

class LeadFormResult {
  LeadFormResult(this.body);
  final Map<String, dynamic> body;
}

Future<LeadFormResult?> showLeadFormDialog(
  BuildContext context, {
  Lead? existing,
}) {
  return showDialog<LeadFormResult>(
    context: context,
    builder: (context) => LeadFormDialog(existing: existing),
  );
}

class LeadFormDialog extends StatefulWidget {
  const LeadFormDialog({super.key, this.existing});
  final Lead? existing;

  @override
  State<LeadFormDialog> createState() => _LeadFormDialogState();
}

class _LeadFormDialogState extends State<LeadFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _email = TextEditingController(text: widget.existing?.email);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _source = TextEditingController(text: widget.existing?.source);
  late final _companyName = TextEditingController(text: widget.existing?.companyName);
  late final _estimatedValue =
      TextEditingController(text: widget.existing?.estimatedValue.toStringAsFixed(0));
  late final _notes = TextEditingController(text: widget.existing?.notes);
  late String _status = widget.existing?.status ?? 'new';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _source.dispose();
    _companyName.dispose();
    _estimatedValue.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.existing == null ? l10n.addLead : l10n.editLead),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(labelText: l10n.nameLabel),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  decoration: InputDecoration(labelText: l10n.emailLabel),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  decoration: InputDecoration(labelText: l10n.phoneLabel),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _companyName,
                  decoration: InputDecoration(labelText: l10n.companyNameLabel),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _source,
                  decoration:
                      InputDecoration(labelText: l10n.sourceLabel, hintText: l10n.sourceHint),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _estimatedValue,
                  decoration: InputDecoration(labelText: l10n.estimatedValueLabel),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: InputDecoration(labelText: l10n.statusLabel),
                  items: Lead.statuses
                      .where((s) => s != 'converted' || _status == 'converted')
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(leadStatusLabel(l10n, s))))
                      .toList(),
                  onChanged: (value) => setState(() => _status = value ?? 'new'),
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
            Navigator.of(context).pop(LeadFormResult({
              'name': _name.text.trim(),
              'email': _email.text.trim().isEmpty ? null : _email.text.trim(),
              'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
              'companyName':
                  _companyName.text.trim().isEmpty ? null : _companyName.text.trim(),
              'source': _source.text.trim().isEmpty ? null : _source.text.trim(),
              'estimatedValue': double.tryParse(_estimatedValue.text.trim()) ?? 0,
              'status': _status,
              'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
            }));
          },
          child: Text(widget.existing == null ? l10n.create : l10n.save),
        ),
      ],
    );
  }
}
