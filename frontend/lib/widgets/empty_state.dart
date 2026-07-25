import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../l10n/generated/app_localizations.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _EmptyStateArt(icon: icon),
            const SizedBox(height: 20),
            Text(title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyState(
      icon: Icons.error_outline,
      title: l10n.somethingWentWrong,
      subtitle: message,
      action: onRetry == null
          ? null
          : FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
    );
  }
}

/// A small decorative badge — a soft gradient circle with scattered dots
/// behind the resource icon — standing in for a bespoke illustration on
/// every empty/error screen without shipping an image asset.
class _EmptyStateArt extends StatelessWidget {
  const _EmptyStateArt({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final backdrop = isLight ? AppTheme.blue50 : AppTheme.blue900.withOpacity(0.4);
    final dotA = isLight ? AppTheme.blue200 : AppTheme.blue700.withOpacity(0.6);
    final dotB = isLight ? AppTheme.blue100 : AppTheme.blue800.withOpacity(0.5);
    final dotC = isLight
        ? AppTheme.blue300.withOpacity(0.6)
        : AppTheme.blue600.withOpacity(0.35);

    return SizedBox(
      width: 128,
      height: 128,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(shape: BoxShape.circle, color: backdrop),
          ),
          PositionedDirectional(top: 10, start: 6, child: _dot(16, dotA)),
          PositionedDirectional(bottom: 14, end: 4, child: _dot(22, dotB)),
          PositionedDirectional(top: 18, end: 20, child: _dot(10, dotC)),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.blue500, AppTheme.blue700],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.blue600.withOpacity(0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, size: 32, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _dot(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}
