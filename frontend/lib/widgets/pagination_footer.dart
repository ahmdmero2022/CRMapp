import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

/// "Page X of Y" + prev/next controls, driven by a [ListNotifier]-style
/// controller's `page`/`totalPages`/`setPage`.
class PaginationFooter extends StatelessWidget {
  const PaginationFooter({
    super.key,
    required this.page,
    required this.totalPages,
    required this.onPageChanged,
  });

  final int page;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: l10n.previousPageTooltip,
          icon: const Icon(Icons.chevron_left),
          onPressed: page > 1 ? () => onPageChanged(page - 1) : null,
        ),
        Text(l10n.pageIndicatorLabel(page, totalPages)),
        IconButton(
          tooltip: l10n.nextPageTooltip,
          icon: const Icon(Icons.chevron_right),
          onPressed: page < totalPages ? () => onPageChanged(page + 1) : null,
        ),
      ],
    );
  }
}
