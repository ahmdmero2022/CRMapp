import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/auth_provider.dart';
import '../../widgets/initials_avatar.dart';

class _NavItem {
  const _NavItem(this.label, this.icon, this.selectedIcon, this.path);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;
}

const _navItems = [
  _NavItem('Dashboard', Icons.dashboard_outlined, Icons.dashboard, '/dashboard'),
  _NavItem('Contacts', Icons.people_outline, Icons.people, '/contacts'),
  _NavItem('Companies', Icons.apartment_outlined, Icons.apartment, '/companies'),
  _NavItem('Leads', Icons.filter_alt_outlined, Icons.filter_alt, '/leads'),
  _NavItem('Deals', Icons.trending_up_outlined, Icons.trending_up, '/deals'),
  _NavItem('Tasks', Icons.task_alt_outlined, Icons.task_alt, '/tasks'),
];

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _currentIndex(String location) {
    final index = _navItems.indexWhere((item) => location.startsWith(item.path));
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _currentIndex(location);
    final user = ref.watch(authProvider).user;
    final isWide = MediaQuery.of(context).size.width >= 900;

    void onSelect(int i) => context.go(_navItems[i].path);

    final title = _navItems[index].label;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              tooltip: 'Account',
              onSelected: (value) {
                if (value == 'logout') {
                  ref.read(authProvider.notifier).logout();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Text(user?.email ?? '',
                      style: Theme.of(context).textTheme.bodySmall),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 18),
                      SizedBox(width: 8),
                      Text('Sign out'),
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
                colorHex: user?.avatarColor ?? '#6366F1',
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
                  selectedIndex: index,
                  onDestinationSelected: onSelect,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final item in _navItems)
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
              selectedIndex: index,
              onDestinationSelected: onSelect,
              destinations: [
                for (final item in _navItems)
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
