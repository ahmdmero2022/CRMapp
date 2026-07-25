import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/auth_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/initials_avatar.dart';

class _NavItem {
  const _NavItem(this.label, this.icon, this.selectedIcon, this.path);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;
}

List<_NavItem> _navItems(AppLocalizations l10n) => [
      _NavItem(l10n.navDashboard, Icons.dashboard_outlined, Icons.dashboard, '/dashboard'),
      _NavItem(l10n.navContacts, Icons.people_outline, Icons.people, '/contacts'),
      _NavItem(
          l10n.navCompanies, Icons.apartment_outlined, Icons.apartment, '/companies'),
      _NavItem(l10n.navLeads, Icons.filter_alt_outlined, Icons.filter_alt, '/leads'),
      _NavItem(l10n.navDeals, Icons.trending_up_outlined, Icons.trending_up, '/deals'),
      _NavItem(l10n.navTasks, Icons.task_alt_outlined, Icons.task_alt, '/tasks'),
    ];

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _matchedIndex(List<_NavItem> navItems, String location) =>
      navItems.indexWhere((item) => location.startsWith(item.path));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final navItems = _navItems(l10n);
    final location = GoRouterState.of(context).matchedLocation;
    final matchedIndex = _matchedIndex(navItems, location);
    // NavigationRail supports "nothing selected" (null); NavigationBar
    // doesn't, so the bottom nav falls back to the first tab on routes with
    // no matching destination (e.g. /settings) — an unavoidable narrow-width
    // trade-off since there's no dedicated settings tab there.
    final railIndex = matchedIndex == -1 ? null : matchedIndex;
    final barIndex = matchedIndex == -1 ? 0 : matchedIndex;
    final user = ref.watch(authProvider).user;
    final isWide = MediaQuery.of(context).size.width >= 900;

    void onSelect(int i) => context.go(navItems[i].path);

    final title = location.startsWith('/settings')
        ? l10n.navSettings
        : (matchedIndex == -1 ? '' : navItems[matchedIndex].label);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: l10n.searchTooltip,
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/search'),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: PopupMenuButton<String>(
              tooltip: l10n.navSettings,
              onSelected: (value) {
                if (value == 'logout') {
                  ref.read(authProvider.notifier).logout();
                } else if (value == 'settings') {
                  context.go('/settings');
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Text(user?.email ?? '',
                      style: Theme.of(context).textTheme.bodySmall),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      const Icon(Icons.settings_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.navSettings),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.signOut),
                    ],
                  ),
                ),
              ],
              child: InitialsAvatar(
                text: (user?.name ?? '?')
                    .split(' ')
                    .map((e) => e.isNotEmpty ? e[0] : '')
                    .take(2)
                    .join()
                    .toUpperCase(),
                colorHex: user?.avatarColor ?? '#2563EB',
                radius: 18,
              ),
            ),
          ),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: railIndex,
                  onDestinationSelected: onSelect,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final item in navItems)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            )
          : child,
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: barIndex,
              onDestinationSelected: onSelect,
              destinations: [
                for (final item in navItems)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ),
              ],
            ),
    );
  }
}
