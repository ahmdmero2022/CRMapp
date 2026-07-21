import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskFormResult {
  TaskFormResult(this.body);
  final Map<String, dynamic> body;
}

Future<TaskFormResult?> showTaskFormDialog(
  BuildContext context, {
  String? initialRelatedType,
  String? initialRelatedId,
}) {
  return showDialog<TaskFormResult>(
    context: context,
    builder: (context) => TaskFormDialog(
      initialRelatedType: initialRelatedType,
      initialRelatedId: initialRelatedId,
    ),
  );
}

class TaskFormDialog extends StatefulWidget {
  const TaskFormDialog({super.key, this.initialRelatedType, this.initialRelatedId});

  final String? initialRelatedType;
  final String? initialRelatedId;

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  DateTime? _dueDate;
  String _priority = 'medium';

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dueDate ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                          );
                          if (picked != null) setState(() => _dueDate = picked);
                        },
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(_dueDate == null
                            ? 'Set due date'
                            : DateFormat.yMMMd().format(_dueDate!)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                  ],
                  onChanged: (value) => setState(() => _priority = value ?? 'medium'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(TaskFormResult({
              'title': _title.text.trim(),
              'description':
                  _description.text.trim().isEmpty ? null : _description.text.trim(),
              'dueDate': _dueDate?.toIso8601String(),
              'priority': _priority,
              'relatedType': widget.initialRelatedType,
              'relatedId': widget.initialRelatedId,
            }));
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
