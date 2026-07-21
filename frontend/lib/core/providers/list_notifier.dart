import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base for feature list controllers: loads a list into an [AsyncValue] and
/// exposes [refresh]. Subclasses add resource-specific CRUD methods that
/// mutate through the repository and then call [refresh] to resync.
abstract class ListNotifier<T> extends StateNotifier<AsyncValue<List<T>>> {
  ListNotifier() : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<List<T>> fetch();

  Future<void> refresh({bool silent = false}) async {
    if (!silent) state = const AsyncValue.loading();
    try {
      final items = await fetch();
      if (mounted) state = AsyncValue.data(items);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }
}
