import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

/// A `sortBy` dropdown paired with an ascending/descending toggle, driven by
/// a [ListNotifier]-style controller's `setSort` method.
class SortControl extends StatelessWidget {
  const SortControl({
    super.key,
    required this.options,
    required this.value,
    required this.descending,
    required this.onChanged,
  });

  /// (field key, label) pairs offered in the dropdown.
  final List<(String, String)> options;
  final String? value;
  final bool descending;
  final void Function(String? field, bool descending) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${l10n.sortByLabel}:',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: value,
          underline: const SizedBox.shrink(),
          isDense: true,
          items: [
            for (final option in options)
              DropdownMenuItem(value: option.$1, child: Text(option.$2)),
          ],
          onChanged: (field) => onChanged(field, descending),
        ),
        IconButton(
          tooltip: l10n.sortDirectionTooltip,
          icon: Icon(descending ? Icons.arrow_downward : Icons.arrow_upward),
          onPressed: () => onChanged(value, !descending),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
