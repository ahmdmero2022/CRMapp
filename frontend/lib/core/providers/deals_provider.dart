import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/deal.dart';
import '../models/pipeline_stage.dart';
import 'list_notifier.dart';
import 'repositories.dart';

class DealsController extends ListNotifier<Deal> {
  DealsController(this._ref) {
    // The kanban board renders every open deal across stage columns at
    // once rather than paging, so request a large single page.
    pageSize = 200;
  }
  final Ref _ref;

  @override
  Future<ListPage<Deal>> fetch() =>
      _ref.read(dealsRepositoryProvider).list(pageSize: pageSize);

  Future<void> create(Map<String, dynamic> body) async {
    await _ref.read(dealsRepositoryProvider).create(body);
    await refresh();
  }

  Future<void> update(String id, Map<String, dynamic> body) async {
    await _ref.read(dealsRepositoryProvider).update(id, body);
    await refresh();
  }

  /// Optimistically moves a deal to [stageId] so the kanban board feels
  /// instant, then reconciles with the server response.
  Future<void> moveToStage(String id, String stageId) async {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data([
        for (final deal in current)
          if (deal.id == id) deal.copyWith(stageId: stageId) else deal,
      ]);
    }
    try {
      await _ref.read(dealsRepositoryProvider).updateStage(id, stageId);
      await refresh(silent: true);
    } catch (_) {
      await refresh();
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    await _ref.read(dealsRepositoryProvider).delete(id);
    await refresh();
  }
}

final dealsControllerProvider =
    StateNotifierProvider.autoDispose<DealsController, AsyncValue<List<Deal>>>(
        (ref) => DealsController(ref));

final pipelineStagesProvider = FutureProvider.autoDispose<List<PipelineStage>>(
    (ref) => ref.read(pipelineStagesRepositoryProvider).list());
