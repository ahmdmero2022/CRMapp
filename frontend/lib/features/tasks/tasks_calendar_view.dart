import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/task.dart';
import '../../core/providers/tasks_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/enum_labels.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/confirm_dialog.dart';

const _maxChipsPerDay = 3;
final _monthFormat = DateFormat.yMMMM();
final _weekdayFormat = DateFormat.E();
final _dayFormat = DateFormat.MMMd();

String _isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime? _dueDateOnly(CrmTask task) {
  if (task.dueDate == null) return null;
  final parsed = DateTime.tryParse(task.dueDate!);
  if (parsed == null) return null;
  return DateTime(parsed.year, parsed.month, parsed.day);
}

/// Month-grid calendar for tasks, grouped by due date. Tasks without a due
/// date simply don't appear (there's no "unscheduled" side list — keeps the
/// view focused on what's actually plannable).
class TasksCalendarView extends StatefulWidget {
  const TasksCalendarView({super.key, required this.tasks});

  final List<CrmTask> tasks;

  @override
  State<TasksCalendarView> createState() => _TasksCalendarViewState();
}

class _TasksCalendarViewState extends State<TasksCalendarView> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  void _shiftMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  Map<DateTime, List<CrmTask>> _groupByDay() {
    final map = <DateTime, List<CrmTask>>{};
    for (final task in widget.tasks) {
      final day = _dueDateOnly(task);
      if (day == null) continue;
      map.putIfAbsent(day, () => []).add(task);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final byDay = _groupByDay();
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final gridStart = firstOfMonth.subtract(Duration(days: firstOfMonth.weekday % 7));
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(_monthFormat.format(_visibleMonth),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton(
              onPressed: () => setState(
                  () => _visibleMonth = DateTime(today.year, today.month)),
              child: Text(l10n.todayLabel),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _shiftMonth(-1),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _shiftMonth(1),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    _weekdayFormat.format(gridStart.add(Duration(days: i))),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.1,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final date = gridStart.add(Duration(days: index));
              final inMonth = date.month == _visibleMonth.month;
              final isToday = date == todayOnly;
              final dayTasks = byDay[date] ?? const <CrmTask>[];
              return _DayCell(
                date: date,
                inMonth: inMonth,
                isToday: isToday,
                tasks: dayTasks,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DayCell extends ConsumerWidget {
  const _DayCell({
    required this.date,
    required this.inMonth,
    required this.isToday,
    required this.tasks,
  });

  final DateTime date;
  final bool inMonth;
  final bool isToday;
  final List<CrmTask> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final iso = _isoDate(date);

    return DragTarget<CrmTask>(
      onWillAcceptWithDetails: (details) => _isoDate(_dueDateOnly(details.data) ?? date) != iso,
      onAcceptWithDetails: (details) async {
        try {
          await ref.read(tasksControllerProvider.notifier).updateDueDate(details.data.id, iso);
        } catch (e) {
          if (context.mounted) showErrorSnackBar(context, e.toString());
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Container(
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isHovering
                ? theme.colorScheme.primary.withOpacity(0.08)
                : (inMonth
                    ? theme.colorScheme.surface
                    : theme.colorScheme.surfaceContainerHighest.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isHovering
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant.withOpacity(0.4),
              width: isHovering ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: isToday
                    ? BoxDecoration(
                        color: theme.colorScheme.primary, shape: BoxShape.circle)
                    : null,
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                    color: isToday
                        ? theme.colorScheme.onPrimary
                        : (inMonth
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.outline),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              for (final task in tasks.take(_maxChipsPerDay))
                _TaskChip(task: task),
              if (tasks.length > _maxChipsPerDay)
                GestureDetector(
                  onTap: () => _showDayTasks(context, ref, date, tasks),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      l10n.moreTasksLabel(tasks.length - _maxChipsPerDay),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TaskChip extends ConsumerWidget {
  const _TaskChip({required this.task});
  final CrmTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = AppTheme.priorityColor(task.priority);
    final chip = Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: BorderDirectional(start: BorderSide(color: color, width: 3)),
      ),
      child: GestureDetector(
        onTap: () => _showDayTasks(
            context, ref, _dueDateOnly(task) ?? DateTime.now(), [task]),
        child: Text(
          task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? Theme.of(context).colorScheme.outline
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );

    return Draggable<CrmTask>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 140, child: chip),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: chip),
      child: chip,
    );
  }
}

void _showDayTasks(
    BuildContext context, WidgetRef ref, DateTime date, List<CrmTask> tasks) {
  final l10n = AppLocalizations.of(context);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_dayFormat.format(date),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: tasks.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) => ref
                          .read(tasksControllerProvider.notifier)
                          .setComplete(task.id, value ?? false),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration:
                            task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: task.relatedLabel == null
                        ? null
                        : Text(task.relatedLabel!),
                    trailing: Text(
                      taskPriorityLabel(l10n, task.priority),
                      style: TextStyle(color: AppTheme.priorityColor(task.priority)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
