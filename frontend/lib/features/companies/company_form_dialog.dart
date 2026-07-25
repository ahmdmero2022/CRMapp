import 'package:flutter/material.dart';

import '../../core/models/company.dart';
import '../../l10n/generated/app_localizations.dart';

class CompanyFormResult {
  CompanyFormResult(this.body);
  final Map<String, dynamic> body;
}

Future<CompanyFormResult?> showCompanyFormDialog(
  BuildContext context, {
  Company? existing,
}) {
  return showDialog<CompanyFormResult>(
    context: context,
    builder: (context) => CompanyFormDialog(existing: existing),
  );
}

class CompanyFormDialog extends StatefulWidget {
  const CompanyFormDialog({super.key, this.existing});
  final Company? existing;

  @override
  State<CompanyFormDialog> createState() => _CompanyFormDialogState();
}

class _CompanyFormDialogState extends State<CompanyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _industry = TextEditingController(text: widget.existing?.industry);
  late final _website = TextEditingController(text: widget.existing?.website);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _address = TextEditingController(text: widget.existing?.address);
  late final _notes = TextEditingController(text: widget.existing?.notes);

  @override
  void dispose() {
    _name.dispose();
    _industry.dispose();
    _website.dispose();
    _phone.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.existing == null ? l10n.addCompany : l10n.editCompany),
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
                  decoration: InputDecoration(labelText: l10n.companyNameLabel),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _industry,
                  decoration: InputDecoration(labelText: l10n.industryLabel),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _website,
                  decoration: InputDecoration(labelText: l10n.websiteLabel),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  decoration: InputDecoration(labelText: l10n.phoneLabel),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _address,
                  decoration: InputDecoration(labelText: l10n.addressLabel),
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
            Navigator.of(context).pop(CompanyFormResult({
              'name': _name.text.trim(),
              'industry': _industry.text.trim().isEmpty ? null : _industry.text.trim(),
              'website': _website.text.trim().isEmpty ? null : _website.text.trim(),
              'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
              'address': _address.text.trim().isEmpty ? null : _address.text.trim(),
              'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
            }));
          },
          child: Text(widget.existing == null ? l10n.create : l10n.save),
        ),
      ],
    );
  }
}
