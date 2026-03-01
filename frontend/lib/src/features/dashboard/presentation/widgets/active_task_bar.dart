import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../dashboard_providers.dart';

class ActiveTaskBar extends ConsumerWidget {
  const ActiveTaskBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListProvider);
    final categories = ref.watch(availableCategoriesProvider);
    final currentCatIndex = ref.watch(currentCategoryProvider);

    if (categories.isEmpty) return const SizedBox.shrink();
    final currentCat = categories[currentCatIndex];

    return tasksAsync.maybeWhen(
      data: (tasks) {
        final activeTasks = tasks.where((t) => t.status == 'IN_PROGRESS').where(
          (t) {
            if (currentCat.id == 'general') return true;
            return t.category.toLowerCase() == currentCat.id.toLowerCase();
          },
        ).toList();

        if (activeTasks.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "IN CORSO",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey.withValues(alpha: 0.7),
                ),
              ),
            ),
            ...activeTasks.map((task) => _ActiveTaskItem(task: task)),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ActiveTaskItem extends ConsumerWidget {
  final TaskUIModel task;
  const _ActiveTaskItem({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: task.color.withValues(alpha: 0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                color: task.color,
              ),
              const SizedBox(width: 12),
              Icon(task.icon, color: task.color.withValues(alpha: 0.8), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      _ActiveTimerText(task: task),
                    ],
                  ),
                ),
              ),
              // Controls
              _CompactActionButton(
                icon: task.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: task.color,
                onTap: () => ref.read(taskListProvider.notifier).toggleTimer(task.id),
              ),
              _CompactActionButton(
                icon: Icons.check_rounded,
                color: AppColors.energia,
                onTap: () => ref.read(taskListProvider.notifier).cycleStatus(task.id),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CompactActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color, size: 22),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ActiveTimerText extends StatefulWidget {
  final TaskUIModel task;
  const _ActiveTimerText({required this.task});

  @override
  State<_ActiveTimerText> createState() => _ActiveTimerTextState();
}

class _ActiveTimerTextState extends State<_ActiveTimerText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.task.isRunning) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(_ActiveTimerText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task.isRunning != oldWidget.task.isRunning) {
      if (widget.task.isRunning) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final elapsed = (widget.task.isRunning && widget.task.lastStartedAt != null)
        ? now.difference(widget.task.lastStartedAt!).inSeconds
        : 0;
    final total = widget.task.totalSeconds + elapsed;

    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;

    String timeStr = "";
    if (h > 0) timeStr += "$h:";
    timeStr +=
        "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";

    return Text(
      timeStr,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.8),
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'monospace',
      ),
    );
  }
}
