import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'hover_lift.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.deltaPercent,
    this.deltaLabel,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  /// Percentage change vs. the previous period (e.g. last month). Positive
  /// renders as an upward green badge, negative as a downward red one — the
  /// arrow direction and sign carry the meaning, not color alone.
  final double? deltaPercent;

  /// Caption shown under the badge, e.g. "vs last month". Ignored if
  /// [deltaPercent] is null.
  final String? deltaLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HoverLift(
      clickable: false,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const Spacer(),
                  if (deltaPercent != null) _DeltaBadge(deltaPercent!),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(label,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
              if (deltaPercent != null && deltaLabel != null) ...[
                const SizedBox(height: 2),
                Text(deltaLabel!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge(this.deltaPercent);

  final double deltaPercent;

  @override
  Widget build(BuildContext context) {
    final positive = deltaPercent >= 0;
    final color = positive ? AppTheme.success : AppTheme.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(positive ? Icons.arrow_upward : Icons.arrow_downward,
              size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            '${deltaPercent.abs().toStringAsFixed(0)}%',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
