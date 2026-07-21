import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/lead.dart';
import 'list_notifier.dart';
import 'repositories.dart';

class LeadsController extends ListNotifier<Lead> {
  LeadsController(this._ref);
  final Ref _ref;

  String? status;

  @override
  Future<List<Lead>> fetch() =>
      _ref.read(leadsRepositoryProvider).list(status: status);

  Future<void> setStatusFilter(String? value) async {
    status = value;
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
}

final leadsControllerProvider =
    StateNotifierProvider.autoDispose<LeadsController, AsyncValue<List<Lead>>>(
        (ref) => LeadsController(ref));
