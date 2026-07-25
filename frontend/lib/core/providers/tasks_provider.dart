import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import 'list_notifier.dart';
import 'repositories.dart';

class TasksController extends ListNotifier<CrmTask> {
  TasksController(this._ref);
  final Ref _ref;

  String? status;
  String search = '';

  @override
  Future<ListPage<CrmTask>> fetch() => _ref.read(tasksRepositoryProvider).list(
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
    await _ref.read(tasksRepositoryProvider).create(body);
    await refresh();
  }

  Future<void> update(String id, Map<String, dynamic> body) async {
    await _ref.read(tasksRepositoryProvider).update(id, body);
    await refresh();
  }

  Future<void> setComplete(String id, bool done) async {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data([
        for (final task in current)
          if (task.id == id)
            CrmTask(
              id: task.id,
              title: task.title,
              description: task.description,
              dueDate: task.dueDate,
              priority: task.priority,
              status: done ? 'completed' : 'pending',
              relatedType: task.relatedType,
              relatedId: task.relatedId,
              relatedLabel: task.relatedLabel,
              ownerId: task.ownerId,
              createdAt: task.createdAt,
              updatedAt: task.updatedAt,
            )
          else
            task,
      ]);
    }
    await _ref.read(tasksRepositoryProvider).setComplete(id, done);
    await refresh(silent: true);
  }

  Future<void> delete(String id) async {
    await _ref.read(tasksRepositoryProvider).delete(id);
    await refresh();
  }

  /// Optimistically reschedules a task to [dueDate] so dragging it to a new
  /// day on the calendar feels instant, then reconciles with the server.
  Future<void> updateDueDate(String id, String dueDate) async {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data([
        for (final task in current)
          if (task.id == id) task.copyWith(dueDate: dueDate) else task,
      ]);
    }
    try {
      await _ref.read(tasksRepositoryProvider).update(id, {'dueDate': dueDate});
      await refresh(silent: true);
    } catch (_) {
      await refresh();
      rethrow;
    }
  }
}

final tasksControllerProvider =
    StateNotifierProvider.autoDispose<TasksController, AsyncValue<List<CrmTask>>>(
        (ref) => TasksController(ref));
