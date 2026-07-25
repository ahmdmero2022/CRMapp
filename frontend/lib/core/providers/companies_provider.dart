import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/company.dart';
import 'list_notifier.dart';
import 'repositories.dart';

class CompaniesController extends ListNotifier<Company> {
  CompaniesController(this._ref);
  final Ref _ref;

  String search = '';

  @override
  Future<ListPage<Company>> fetch() => _ref.read(companiesRepositoryProvider).list(
        search: search,
        page: page,
        pageSize: pageSize,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

  Future<void> setSearch(String value) async {
    search = value;
    page = 1;
    await refresh();
  }

  Future<void> create(Map<String, dynamic> body) async {
    await _ref.read(companiesRepositoryProvider).create(body);
    await refresh();
  }

  Future<void> update(String id, Map<String, dynamic> body) async {
    await _ref.read(companiesRepositoryProvider).update(id, body);
    await refresh();
  }

  Future<void> delete(String id) async {
    await _ref.read(companiesRepositoryProvider).delete(id);
    await refresh();
  }
}

final companiesControllerProvider = StateNotifierProvider.autoDispose<
    CompaniesController, AsyncValue<List<Company>>>((ref) => CompaniesController(ref));
