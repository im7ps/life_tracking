import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../dashboard_providers.dart';
import 'animated_border_painter.dart';

class IdentityGrid extends ConsumerStatefulWidget {
  final List<TaskUIModel> tasks;
  final Function(TaskUIModel) onTaskTap;
  final Function(TaskUIModel) onTaskLongPress;

  const IdentityGrid({
    super.key,
    required this.tasks,
    required this.onTaskTap,
    required this.onTaskLongPress,
  });

  @override
  ConsumerState<IdentityGrid> createState() => _IdentityGridState();
}

class _IdentityGridState extends ConsumerState<IdentityGrid> with SingleTickerProviderStateMixin {
  late AnimationController _borderController;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.tasks.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          "NESSUNA TASK",
          style: theme.textTheme.labelLarge?.copyWith(color: AppColors.grey),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: widget.tasks.length,
      itemBuilder: (context, index) {
        final task = widget.tasks[index];
        final categoryColor = _getCategoryColor(task.category);
        
        // Status determination
        final isCompleted = task.status == 'COMPLETED';
        final isInProgress = task.status == 'IN_PROGRESS';
        final isPending = task.status == 'PENDING';

        return GestureDetector(
          onTap: () => ref.read(taskListProvider.notifier).cycleStatus(task.id),
          onLongPress: () => widget.onTaskLongPress(task),
          child: Stack(
            children: [
              // In Progress border animation
              if (isInProgress)
                Positioned.fill(
                  child: CustomPaint(
                    painter: AnimatedBorderPainter(
                      animation: _borderController,
                      color: categoryColor,
                    ),
                  ),
                ),
              
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? categoryColor 
                      : isInProgress
                          ? categoryColor.withValues(alpha: 0.1)
                          : theme.cardTheme.color?.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: isPending ? Border.all(color: categoryColor.withValues(alpha: 0.4), width: 1.5) : null,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        task.icon,
                        color: (isInProgress || isCompleted)
                            ? Colors.white 
                            : categoryColor.withValues(alpha: 0.4),
                        size: 24,
                      ),
                      if (task.totalSeconds > 0 && !isCompleted)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _formatDuration(task.totalSeconds),
                            style: TextStyle(
                              fontSize: 8,
                              color: isInProgress ? Colors.white70 : AppColors.grey,
                              fontWeight: isInProgress ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'dovere':
        return AppColors.dovere;
      case 'passione':
        return AppColors.passione;
      case 'energia':
        return AppColors.energia;
      case 'anima':
        return AppColors.anima;
      case 'relazioni':
        return AppColors.relazioni;
      default:
        return AppColors.neutral;
    }
  }
}
