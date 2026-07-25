import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A page of results plus the total row count across all pages, as returned
/// by every paginated list endpoint.
class ListPage<T> {
  const ListPage(this.items, this.total);
  final List<T> items;
  final int total;
}

/// Base for feature list controllers: loads a page of results into an
/// [AsyncValue] and exposes [refresh], plus shared pagination/sort state.
/// Subclasses add resource-specific filter fields and CRUD methods that
/// mutate through the repository and then call [refresh] to resync.
abstract class ListNotifier<T> extends StateNotifier<AsyncValue<List<T>>> {
  ListNotifier() : super(const AsyncValue.loading()) {
    refresh();
  }

  int page = 1;
  int pageSize = 25;
  int total = 0;
  String? sortBy;
  String sortOrder = 'asc';

  int get totalPages => total == 0 ? 1 : ((total - 1) ~/ pageSize) + 1;

  Future<ListPage<T>> fetch();

  Future<void> refresh({bool silent = false}) async {
    if (!silent) state = const AsyncValue.loading();
    try {
      final result = await fetch();
      total = result.total;
      if (mounted) state = AsyncValue.data(result.items);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<void> setPage(int value) async {
    if (value == page) return;
    page = value;
    await refresh();
  }

  Future<void> setSort(String? field, {String order = 'asc'}) async {
    sortBy = field;
    sortOrder = order;
    page = 1;
    await refresh();
  }
}
