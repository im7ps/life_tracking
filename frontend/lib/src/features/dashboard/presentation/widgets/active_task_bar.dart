import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        // Filter: IN_PROGRESS status tasks
        // Logic: if in 'general' show all, else show only tasks of that category
        final activeTasks = tasks.where((t) => t.status == 'IN_PROGRESS').where(
          (t) {
            if (currentCat.id == 'general') return true;
            return t.category.toLowerCase() == currentCat.id.toLowerCase();
          },
        ).toList();

        if (activeTasks.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.only(bottom: 8),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: activeTasks.length,
            itemBuilder: (context, index) =>
                _ActiveTaskItem(task: activeTasks[index]),
          ),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: task.color.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: task.color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(task.icon, color: Colors.white, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  _ActiveTimerText(task: task),
                ],
              ),
            ),

            // Action Buttons with Spacing
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pause/Play Button
                _ActionButton(
                  icon: task.isRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  onTap: () =>
                      ref.read(taskListProvider.notifier).toggleTimer(task.id),
                ),
                const SizedBox(width: 16),
                // Complete Button
                _ActionButton(
                  icon: Icons.check_rounded,
                  onTap: () =>
                      ref.read(taskListProvider.notifier).cycleStatus(task.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
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
