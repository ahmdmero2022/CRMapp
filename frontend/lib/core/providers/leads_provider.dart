import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/lead.dart';
import 'list_notifier.dart';
import 'repositories.dart';

class LeadsController extends ListNotifier<Lead> {
  LeadsController(this._ref);
  final Ref _ref;

  String? status;
  String search = '';

  @override
  Future<ListPage<Lead>> fetch() => _ref.read(leadsRepositoryProvider).list(
        status: status,
        search: search,
        page: page,
        pageSize: pageSize,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

  Future<void> setStatusFilter(String? value) async {
    status = value;
    page = 1;
    await refresh();
  }

  Future<void> setSearch(String value) async {
    search = value;
    page = 1;
    await refresh();
  }

  Future<void> create(Map<String, dynamic> body) async {
    await _ref.read(leadsRepositoryProvider).create(body);
    await refresh();
  }

  Future<void> update(String id, Map<String, dynamic> body) async {
    await _ref.read(leadsRepositoryProvider).update(id, body);
    await refresh();
  }

  Future<void> delete(String id) async {
    await _ref.read(leadsRepositoryProvider).delete(id);
    await refresh();
  }

  Future<Map<String, dynamic>> convert(String id) async {
    final result = await _ref.read(leadsRepositoryProvider).convert(id);
    await refresh();
    return result;
  }

  /// Optimistically moves a lead to [status] so the kanban board feels
  /// instant, then reconciles with the server response.
  Future<void> updateStatus(String id, String status) async {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data([
        for (final lead in current)
          if (lead.id == id) lead.copyWith(status: status) else lead,
      ]);
    }
    try {
      await _ref.read(leadsRepositoryProvider).update(id, {'status': status});
      await refresh(silent: true);
    } catch (_) {
      await refresh();
      rethrow;
    }
  }
}

final leadsControllerProvider =
    StateNotifierProvider.autoDispose<LeadsController, AsyncValue<List<Lead>>>(
        (ref) => LeadsController(ref));
