import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/deal.dart';
import '../../core/providers/companies_provider.dart';
import '../../core/providers/contacts_provider.dart';
import '../../l10n/generated/app_localizations.dart';

class DealFormResult {
  DealFormResult(this.body);
  final Map<String, dynamic> body;
}

Future<DealFormResult?> showDealFormDialog(
  BuildContext context, {
  Deal? existing,
  String? initialStageId,
}) {
  return showDialog<DealFormResult>(
    context: context,
    builder: (context) =>
        DealFormDialog(existing: existing, initialStageId: initialStageId),
  );
}

class DealFormDialog extends ConsumerStatefulWidget {
  const DealFormDialog({super.key, this.existing, this.initialStageId});

  final Deal? existing;
  final String? initialStageId;

  @override
  ConsumerState<DealFormDialog> createState() => _DealFormDialogState();
}

class _DealFormDialogState extends ConsumerState<DealFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _value =
      TextEditingController(text: widget.existing?.value.toStringAsFixed(0) ?? '0');
  late final _notes = TextEditingController(text: widget.existing?.notes);
  String? _contactId;
  String? _companyId;
  double _probability = 50;
  DateTime? _expectedCloseDate;

  @override
  void initState() {
    super.initState();
    _contactId = widget.existing?.contactId;
    _companyId = widget.existing?.companyId;
    _probability = (widget.existing?.probability ?? 50).toDouble();
    if (widget.existing?.expectedCloseDate != null) {
      _expectedCloseDate = DateTime.tryParse(widget.existing!.expectedCloseDate!);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _value.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final contactsAsync = ref.watch(contactsControllerProvider);
    final companiesAsync = ref.watch(companiesControllerProvider);

    return AlertDialog(
      title: Text(widget.existing == null ? l10n.addDeal : l10n.editDeal),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _title,
                  decoration: InputDecoration(labelText: l10n.dealTitleLabel),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _value,
                  decoration: InputDecoration(labelText: l10n.valueDollarLabel),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                companiesAsync.when(
                  data: (companies) => DropdownButtonFormField<String?>(
                    value: companies.any((c) => c.id == _companyId) ? _companyId : null,
                    decoration: InputDecoration(labelText: l10n.companyLabel),
                    items: [
                      DropdownMenuItem<String?>(value: null, child: Text(l10n.none)),
                      for (final c in companies)
                        DropdownMenuItem<String?>(value: c.id, child: Text(c.name)),
                    ],
                    onChanged: (value) => setState(() => _companyId = value),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                contactsAsync.when(
                  data: (contacts) => DropdownButtonFormField<String?>(
                    value: contacts.any((c) => c.id == _contactId) ? _contactId : null,
                    decoration: InputDecoration(labelText: l10n.primaryContactLabel),
                    items: [
                      DropdownMenuItem<String?>(value: null, child: Text(l10n.none)),
                      for (final c in contacts)
                        DropdownMenuItem<String?>(value: c.id, child: Text(c.fullName)),
                    ],
                    onChanged: (value) => setState(() => _contactId = value),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _expectedCloseDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (picked != null) setState(() => _expectedCloseDate = picked);
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(_expectedCloseDate == null
                      ? l10n.setExpectedCloseDate
                      : l10n.closesOnLabel(
                          _expectedCloseDate!.toLocal().toString().split(' ').first)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(l10n.probabilityWithPercent(_probability.round())),
                  ],
                ),
                Slider(
                  value: _probability,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${_probability.round()}%',
                  onChanged: (value) => setState(() => _probability = value),
                ),
                const SizedBox(height: 8),
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
            Navigator.of(context).pop(DealFormResult({
              'title': _title.text.trim(),
              'value': double.tryParse(_value.text.trim()) ?? 0,
              'companyId': _companyId,
              'contactId': _contactId,
              'expectedCloseDate': _expectedCloseDate?.toIso8601String(),
              'probability': _probability.round(),
              'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
              if (widget.existing == null) 'stageId': widget.initialStageId,
            }));
          },
          child: Text(widget.existing == null ? l10n.create : l10n.save),
        ),
      ],
    );
  }
}
