import 'package:flutter/material.dart';

/// A single destination in a [GroupedNavRail].
class NavRailItem {
  const NavRailItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.path,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String path;
}

/// A labeled group of [NavRailItem]s. [label] is omitted (no header row) when
/// null — used for the first group so the rail doesn't start with a heading.
class NavRailGroup {
  const NavRailGroup({this.label, required this.items});

  final String? label;
  final List<NavRailItem> items;
}

/// A collapsible, grouped alternative to Material's [NavigationRail] — the
/// stock widget has no concept of section headers, which the CRM's sidebar
/// needs (Overview / Sales / People / Work). Mirrors [NavigationRail]'s
/// visual language (stadium selection indicator, themed icon/label colors)
/// by reading the same [NavigationRailThemeData] so it drops in seamlessly.
class GroupedNavRail extends StatelessWidget {
  const GroupedNavRail({
    super.key,
    required this.groups,
    required this.selectedPath,
    required this.onSelect,
    required this.collapsed,
    required this.onToggleCollapsed,
    this.collapseTooltip = 'Collapse sidebar',
    this.expandTooltip = 'Expand sidebar',
  });

  final List<NavRailGroup> groups;
  final String? selectedPath;
  final ValueChanged<String> onSelect;
  final bool collapsed;
  final VoidCallback onToggleCollapsed;
  final String collapseTooltip;
  final String expandTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final railTheme = theme.navigationRailTheme;
    final width = collapsed ? 72.0 : 232.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: width,
      color: railTheme.backgroundColor ?? theme.colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Align(
            alignment:
                collapsed ? Alignment.center : AlignmentDirectional.centerEnd,
            child: IconButton(
              tooltip: collapsed ? expandTooltip : collapseTooltip,
              icon: Icon(collapsed ? Icons.chevron_right : Icons.chevron_left),
              onPressed: onToggleCollapsed,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: [
                for (final group in groups) ...[
                  if (group.label != null && !collapsed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 12, 6),
                      child: Text(
                        group.label!.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    )
                  else if (group.label != null)
                    const SizedBox(height: 12),
                  for (final item in group.items)
                    _RailTile(
                      item: item,
                      collapsed: collapsed,
                      selected: selectedPath != null &&
                          selectedPath!.startsWith(item.path),
                      onTap: () => onSelect(item.path),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RailTile extends StatelessWidget {
  const _RailTile({
    required this.item,
    required this.collapsed,
    required this.selected,
    required this.onTap,
  });

  final NavRailItem item;
  final bool collapsed;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final railTheme = theme.navigationRailTheme;
    final iconColor = selected
        ? railTheme.selectedIconTheme?.color ?? theme.colorScheme.primary
        : railTheme.unselectedIconTheme?.color ??
            theme.colorScheme.onSurfaceVariant;
    final labelStyle = selected
        ? railTheme.selectedLabelTextStyle
        : railTheme.unselectedLabelTextStyle;

    final tile = Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Material(
          color: selected
              ? (railTheme.indicatorColor ??
                  theme.colorScheme.primaryContainer)
              : Colors.transparent,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: collapsed ? 12 : 16,
                vertical: 10,
              ),
              child: collapsed
                  ? Icon(selected ? item.selectedIcon : item.icon,
                      color: iconColor, size: 22)
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(selected ? item.selectedIcon : item.icon,
                            color: iconColor, size: 22),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            item.label,
                            overflow: TextOverflow.ellipsis,
                            style: labelStyle?.copyWith(color: iconColor),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );

    return collapsed ? Tooltip(message: item.label, child: tile) : tile;
  }
}
