import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import 'list_notifier.dart';
import 'repositories.dart';

class TasksController extends ListNotifier<CrmTask> {
  TasksController(this._ref);
  final Ref _ref;

  String? status;

  @override
  Future<List<CrmTask>> fetch() =>
      _ref.read(tasksRepositoryProvider).list(status: status);

  Future<void> setStatusFilter(String? value) async {
    status = value;
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
}

final tasksControllerProvider =
    StateNotifierProvider.autoDispose<TasksController, AsyncValue<List<CrmTask>>>(
        (ref) => TasksController(ref));
