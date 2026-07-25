import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/task.dart';
import '../../core/providers/tasks_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/enum_labels.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/pagination_footer.dart';
import '../../widgets/section_header.dart';
import '../../widgets/sort_control.dart';
import 'task_form_dialog.dart';
import 'tasks_calendar_view.dart';

enum _ViewMode { list, calendar }

const _listPageSize = 25;
const _calendarPageSize = 500;

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  String? _filter;
  _ViewMode _viewMode = _ViewMode.list;
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _appliedInitialQuery = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_appliedInitialQuery) {
      _appliedInitialQuery = true;
      final q = GoRouterState.of(context).uri.queryParameters['q'];
      if (q != null && q.isNotEmpty) {
        _searchController.text = q;
        ref.read(tasksControllerProvider.notifier).setSearch(q);
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(tasksControllerProvider.notifier).setSearch(value);
    });
  }

  void _setViewMode(_ViewMode mode) {
    if (mode == _viewMode) return;
    setState(() => _viewMode = mode);
    ref
        .read(tasksControllerProvider.notifier)
        .setPageSize(mode == _ViewMode.calendar ? _calendarPageSize : _listPageSize);
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    final result = await showTaskFormDialog(context);
    if (result == null) return;
    try {
      await ref.read(tasksControllerProvider.notifier).create(result.body);
      if (mounted) showSuccessSnackBar(context, l10n.taskCreatedMessage);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _delete(CrmTask task) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDialog(context,
        title: l10n.deleteTaskTitle, message: l10n.deleteTaskMessage(task.title));
    if (!confirmed) return;
    await ref.read(tasksControllerProvider.notifier).delete(task.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tasksAsync = ref.watch(tasksControllerProvider);
    final controller = ref.read(tasksControllerProvider.notifier);
    final isCalendar = _viewMode == _ViewMode.calendar;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: l10n.tasksTitle,
            subtitle: l10n.tasksSubtitle,
            actions: [
              SegmentedButton<_ViewMode>(
                segments: [
                  ButtonSegment(
                      value: _ViewMode.list,
                      icon: const Icon(Icons.view_list_outlined),
                      label: Text(l10n.listViewLabel)),
                  ButtonSegment(
                      value: _ViewMode.calendar,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(l10n.calendarViewLabel)),
                ],
                selected: {_viewMode},
                onSelectionChanged: (selection) => _setViewMode(selection.first),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _create,
                icon: const Icon(Icons.add),
                label: Text(l10n.addTask),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchTasksHint,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              if (!isCalendar) ...[
                const SizedBox(width: 12),
                SortControl(
                  options: [
                    ('title', l10n.titleLabel),
                    ('dueDate', l10n.setDueDate),
                    ('priority', l10n.priorityLabel),
                  ],
                  value: controller.sortBy,
                  descending: controller.sortOrder == 'desc',
                  onChanged: (field, descending) => ref
                      .read(tasksControllerProvider.notifier)
                      .setSort(field, order: descending ? 'desc' : 'asc'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(l10n.allFilterLabel),
                selected: _filter == null,
                onSelected: (_) {
                  setState(() => _filter = null);
                  ref.read(tasksControllerProvider.notifier).setStatusFilter(null);
                },
              ),
              ChoiceChip(
                label: Text(l10n.pendingFilterLabel),
                selected: _filter == 'pending',
                onSelected: (_) {
                  setState(() => _filter = 'pending');
                  ref.read(tasksControllerProvider.notifier).setStatusFilter('pending');
                },
              ),
              ChoiceChip(
                label: Text(l10n.completedFilterLabel),
                selected: _filter == 'completed',
                onSelected: (_) {
                  setState(() => _filter = 'completed');
                  ref
                      .read(tasksControllerProvider.notifier)
                      .setStatusFilter('completed');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: tasksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => ErrorState(
                message: err.toString(),
                onRetry: () => ref.read(tasksControllerProvider.notifier).refresh(),
              ),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return EmptyState(
                      icon: Icons.task_alt, title: l10n.noTasksFoundTitle);
                }
                if (isCalendar) {
                  return TasksCalendarView(tasks: tasks);
                }
                return ListView.separated(
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) => ref
                              .read(tasksControllerProvider.notifier)
                              .setComplete(task.id, value ?? false),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration:
                                task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text([
                          if (task.relatedLabel != null) task.relatedLabel,
                          if (task.description != null) task.description,
                        ].whereType<String>().join(' · ')),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.priorityColor(task.priority)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                taskPriorityLabel(l10n, task.priority),
                                style: TextStyle(
                                  color: AppTheme.priorityColor(task.priority),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (task.dueDate != null)
                              Text(
                                DateFormat.MMMd().format(DateTime.parse(task.dueDate!)),
                                style: TextStyle(
                                  color: task.isOverdue
                                      ? AppTheme.danger
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _delete(task),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (!isCalendar)
            PaginationFooter(
              page: controller.page,
              totalPages: controller.totalPages,
              onPageChanged: (page) => controller.setPage(page),
            ),
        ],
      ),
    );
  }
}
