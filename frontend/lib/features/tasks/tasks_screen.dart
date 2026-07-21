import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/task.dart';
import '../../core/providers/tasks_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_header.dart';
import 'task_form_dialog.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  String? _filter;

  Future<void> _create() async {
    final result = await showTaskFormDialog(context);
    if (result == null) return;
    try {
      await ref.read(tasksControllerProvider.notifier).create(result.body);
      if (mounted) showSuccessSnackBar(context, 'Task created');
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _delete(CrmTask task) async {
    final confirmed = await confirmDialog(context,
        title: 'Delete task', message: 'Delete "${task.title}"?');
    if (!confirmed) return;
    await ref.read(tasksControllerProvider.notifier).delete(task.id);
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Tasks',
            subtitle: 'Stay on top of your follow-ups.',
            actions: [
              FilledButton.icon(
                onPressed: _create,
                icon: const Icon(Icons.add),
                label: const Text('Add Task'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _filter == null,
                onSelected: (_) {
                  setState(() => _filter = null);
                  ref.read(tasksControllerProvider.notifier).setStatusFilter(null);
                },
              ),
              ChoiceChip(
                label: const Text('Pending'),
                selected: _filter == 'pending',
                onSelected: (_) {
                  setState(() => _filter = 'pending');
                  ref.read(tasksControllerProvider.notifier).setStatusFilter('pending');
                },
              ),
              ChoiceChip(
                label: const Text('Completed'),
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
                  return const EmptyState(
                      icon: Icons.task_alt, title: 'No tasks found');
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
                                task.priority,
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
        ],
      ),
    );
  }
}
