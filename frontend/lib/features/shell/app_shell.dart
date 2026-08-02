import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/providers/companies_provider.dart';
import '../../core/providers/contacts_provider.dart';
import '../../core/providers/deals_provider.dart';
import '../../core/providers/leads_provider.dart';
import '../../core/providers/tasks_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/grouped_nav_rail.dart';
import '../../widgets/initials_avatar.dart';
import '../companies/company_form_dialog.dart';
import '../contacts/contact_form_dialog.dart';
import '../deals/deal_form_dialog.dart';
import '../leads/lead_form_dialog.dart';
import '../tasks/task_form_dialog.dart';

List<NavRailGroup> _navGroups(AppLocalizations l10n) => [
      NavRailGroup(label: l10n.navGroupOverview, items: [
        NavRailItem(
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          label: l10n.navDashboard,
          path: '/dashboard',
        ),
      ]),
      NavRailGroup(label: l10n.navGroupSales, items: [
        NavRailItem(
          icon: Icons.filter_alt_outlined,
          selectedIcon: Icons.filter_alt,
          label: l10n.navLeads,
          path: '/leads',
        ),
        NavRailItem(
          icon: Icons.trending_up_outlined,
          selectedIcon: Icons.trending_up,
          label: l10n.navDeals,
          path: '/deals',
        ),
      ]),
      NavRailGroup(label: l10n.navGroupPeople, items: [
        NavRailItem(
          icon: Icons.apartment_outlined,
          selectedIcon: Icons.apartment,
          label: l10n.navCompanies,
          path: '/companies',
        ),
        NavRailItem(
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
          label: l10n.navContacts,
          path: '/contacts',
        ),
      ]),
      NavRailGroup(label: l10n.navGroupWork, items: [
        NavRailItem(
          icon: Icons.task_alt_outlined,
          selectedIcon: Icons.task_alt,
          label: l10n.navTasks,
          path: '/tasks',
        ),
      ]),
    ];

List<NavRailItem> _flatItems(List<NavRailGroup> groups) => [
      for (final group in groups) ...group.items,
    ];

class _Crumb {
  const _Crumb(this.label, this.path);
  final String label;
  final String? path;
}

List<_Crumb> _breadcrumbs(
    String location, List<NavRailItem> navItems, AppLocalizations l10n) {
  if (location.startsWith('/settings')) {
    return [_Crumb(l10n.navSettings, null)];
  }
  if (location.startsWith('/search')) {
    return [_Crumb(l10n.searchTooltip, null)];
  }
  final idx = navItems.indexWhere((item) => location.startsWith(item.path));
  if (idx == -1) return [];
  final item = navItems[idx];
  final remainder = location.substring(item.path.length);
  final hasDetail = remainder.length > 1;
  if (!hasDetail) return [_Crumb(item.label, null)];
  return [_Crumb(item.label, item.path), _Crumb(l10n.breadcrumbDetails, null)];
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _railCollapsed = false;

  Future<void> _quickCreate(
      BuildContext context, WidgetRef ref, String kind) async {
    final l10n = AppLocalizations.of(context);
    switch (kind) {
      case 'lead':
        final result = await showLeadFormDialog(context);
        if (result == null || !context.mounted) return;
        try {
          await ref.read(leadsControllerProvider.notifier).create(result.body);
          if (context.mounted) {
            showSuccessSnackBar(context, l10n.leadCreatedMessage);
          }
        } catch (e) {
          if (context.mounted) showErrorSnackBar(context, e.toString());
        }
        break;
      case 'company':
        final result = await showCompanyFormDialog(context);
        if (result == null || !context.mounted) return;
        try {
          await ref
              .read(companiesControllerProvider.notifier)
              .create(result.body);
          if (context.mounted) {
            showSuccessSnackBar(context, l10n.companyCreatedMessage);
          }
        } catch (e) {
          if (context.mounted) showErrorSnackBar(context, e.toString());
        }
        break;
      case 'contact':
        final result = await showContactFormDialog(context);
        if (result == null || !context.mounted) return;
        try {
          await ref
              .read(contactsControllerProvider.notifier)
              .create(result.body);
          if (context.mounted) {
            showSuccessSnackBar(context, l10n.contactCreatedMessage);
          }
        } catch (e) {
          if (context.mounted) showErrorSnackBar(context, e.toString());
        }
        break;
      case 'deal':
        final result = await showDealFormDialog(context);
        if (result == null || !context.mounted) return;
        try {
          await ref.read(dealsControllerProvider.notifier).create(result.body);
          if (context.mounted) {
            showSuccessSnackBar(context, l10n.dealCreatedMessage);
          }
        } catch (e) {
          if (context.mounted) showErrorSnackBar(context, e.toString());
        }
        break;
      case 'task':
        final result = await showTaskFormDialog(context);
        if (result == null || !context.mounted) return;
        try {
          await ref.read(tasksControllerProvider.notifier).create(result.body);
          if (context.mounted) {
            showSuccessSnackBar(context, l10n.taskCreatedMessage);
          }
        } catch (e) {
          if (context.mounted) showErrorSnackBar(context, e.toString());
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final groups = _navGroups(l10n);
    final navItems = _flatItems(groups);
    final location = GoRouterState.of(context).matchedLocation;
    final matchedIndex =
        navItems.indexWhere((item) => location.startsWith(item.path));
    final bottomItems = [
      ...navItems,
      NavRailItem(
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: l10n.navSettings,
        path: '/settings',
      ),
    ];
    final barIndex =
        bottomItems.indexWhere((item) => location.startsWith(item.path));
    final user = ref.watch(authProvider).user;
    final isWide = MediaQuery.of(context).size.width >= 900;

    void onSelect(String path) => context.go(path);

    final title = location.startsWith('/settings')
        ? l10n.navSettings
        : (matchedIndex == -1 ? '' : navItems[matchedIndex].label);
    final crumbs = _breadcrumbs(location, navItems, l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          PopupMenuButton<String>(
            tooltip: l10n.quickCreateTooltip,
            icon: const Icon(Icons.add),
            onSelected: (value) => _quickCreate(context, ref, value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'lead',
                child: Row(children: [
                  const Icon(Icons.filter_alt_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(l10n.quickCreateLead),
                ]),
              ),
              PopupMenuItem(
                value: 'company',
                child: Row(children: [
                  const Icon(Icons.apartment_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(l10n.quickCreateCompany),
                ]),
              ),
              PopupMenuItem(
                value: 'contact',
                child: Row(children: [
                  const Icon(Icons.people_outline, size: 18),
                  const SizedBox(width: 8),
                  Text(l10n.quickCreateContact),
                ]),
              ),
              PopupMenuItem(
                value: 'deal',
                child: Row(children: [
                  const Icon(Icons.trending_up_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(l10n.quickCreateDeal),
                ]),
              ),
              PopupMenuItem(
                value: 'task',
                child: Row(children: [
                  const Icon(Icons.task_alt_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(l10n.quickCreateTask),
                ]),
              ),
            ],
          ),
          IconButton(
            tooltip: l10n.searchTooltip,
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/search'),
          ),
          PopupMenuButton<void>(
            tooltip: l10n.notificationsTooltip,
            icon: const Icon(Icons.notifications_outlined),
            itemBuilder: (context) => [
              PopupMenuItem<void>(
                enabled: false,
                child: SizedBox(
                  width: 260,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.notificationsEmptyTitle,
                          style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(
                        l10n.notificationsEmptySubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
                GroupedNavRail(
                  groups: groups,
                  selectedPath: matchedIndex == -1 ? null : location,
                  onSelect: onSelect,
                  collapsed: _railCollapsed,
                  onToggleCollapsed: () =>
                      setState(() => _railCollapsed = !_railCollapsed),
                  collapseTooltip: l10n.sidebarCollapse,
                  expandTooltip: l10n.sidebarExpand,
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (crumbs.isNotEmpty) _BreadcrumbBar(crumbs: crumbs),
                      Expanded(child: widget.child),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (crumbs.isNotEmpty) _BreadcrumbBar(crumbs: crumbs),
                Expanded(child: widget.child),
              ],
            ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: barIndex == -1 ? 0 : barIndex,
              onDestinationSelected: (i) => onSelect(bottomItems[i].path),
              destinations: [
                for (final item in bottomItems)
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

class _BreadcrumbBar extends StatelessWidget {
  const _BreadcrumbBar({required this.crumbs});

  final List<_Crumb> crumbs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      alignment: AlignmentDirectional.centerStart,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
              color: theme.dividerTheme.color ?? theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < crumbs.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.chevron_right,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
              ),
            crumbs[i].path == null
                ? Text(
                    crumbs[i].label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  )
                : InkWell(
                    onTap: () => context.go(crumbs[i].path!),
                    child: Text(
                      crumbs[i].label,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
          ],
        ],
      ),
    );
  }
}
