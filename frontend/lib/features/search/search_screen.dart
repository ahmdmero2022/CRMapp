import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/search_result.dart';
import '../../core/providers/search_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/empty_state.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(searchControllerProvider.notifier).search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final resultsAsync = ref.watch(searchControllerProvider);
    final hasQuery = ref.read(searchControllerProvider.notifier).query.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            onChanged: _onChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.searchHint,
              filled: true,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: resultsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => ErrorState(message: err.toString()),
              data: (results) {
                if (!hasQuery) {
                  return EmptyState(
                    icon: Icons.search,
                    title: l10n.searchEmptyTitle,
                    subtitle: l10n.searchEmptySubtitle,
                  );
                }
                if (results.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: l10n.searchNoResultsTitle,
                    subtitle: l10n.searchNoResultsSubtitle,
                  );
                }
                return ListView(
                  children: [
                    _SearchSection(
                      title: l10n.navContacts,
                      icon: Icons.people_outline,
                      items: results.contacts,
                      onTap: (item) => context.go('/contacts/${item.id}'),
                    ),
                    _SearchSection(
                      title: l10n.navCompanies,
                      icon: Icons.apartment_outlined,
                      items: results.companies,
                      onTap: (item) => context.go('/companies/${item.id}'),
                    ),
                    _SearchSection(
                      title: l10n.navLeads,
                      icon: Icons.filter_alt_outlined,
                      items: results.leads,
                      onTap: (item) =>
                          context.go('/leads?q=${Uri.encodeComponent(item.label)}'),
                    ),
                    _SearchSection(
                      title: l10n.navDeals,
                      icon: Icons.trending_up_outlined,
                      items: results.deals,
                      onTap: (_) => context.go('/deals'),
                    ),
                    _SearchSection(
                      title: l10n.navTasks,
                      icon: Icons.task_alt_outlined,
                      items: results.tasks,
                      onTap: (item) =>
                          context.go('/tasks?q=${Uri.encodeComponent(item.label)}'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection({
    required this.title,
    required this.icon,
    required this.items,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final List<SearchResultItem> items;
  final ValueChanged<SearchResultItem> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(title,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        ),
        for (final item in items)
          Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              leading: Icon(icon),
              title: Text(item.label),
              subtitle: item.subtitle == null || item.subtitle!.isEmpty
                  ? null
                  : Text(item.subtitle!),
              onTap: () => onTap(item),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
