import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/search_result.dart';
import 'repositories.dart';

class SearchController extends StateNotifier<AsyncValue<SearchResults>> {
  SearchController(this._ref) : super(AsyncValue.data(SearchResults.empty()));
  final Ref _ref;

  String query = '';

  Future<void> search(String value) async {
    query = value;
    if (value.trim().isEmpty) {
      state = AsyncValue.data(SearchResults.empty());
      return;
    }
    state = const AsyncValue.loading();
    try {
      final results = await _ref.read(searchRepositoryProvider).search(value.trim());
      // Ignore stale responses from a query that's since been superseded.
      if (query == value) state = AsyncValue.data(results);
    } catch (e, st) {
      if (query == value) state = AsyncValue.error(e, st);
    }
  }
}

final searchControllerProvider =
    StateNotifierProvider.autoDispose<SearchController, AsyncValue<SearchResults>>(
        (ref) => SearchController(ref));
