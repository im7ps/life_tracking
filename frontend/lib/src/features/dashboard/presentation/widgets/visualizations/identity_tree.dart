import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../dashboard_models.dart';

class IdentityTree extends StatefulWidget {
  final List<TaskUIModel> tasks;

  const IdentityTree({super.key, required this.tasks});

  @override
  State<IdentityTree> createState() => _IdentityTreeState();
}

class _IdentityTreeState extends State<IdentityTree> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _growAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _growAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void didUpdateWidget(IdentityTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tasks.where((t) => t.isCompleted).length != widget.tasks.where((t) => t.isCompleted).length) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completedTasks = widget.tasks.where((t) => t.isCompleted).length;
    final totalTasks = max(1, widget.tasks.length);
    final completionRatio = completedTasks / totalTasks;

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.passione.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.passione.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: AnimatedBuilder(
        animation: _growAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _TreePainter(
              progress: _growAnimation.value,
              completionRatio: completionRatio,
              completedCount: completedTasks,
            ),
          );
        },
      ),
    );
  }
}

class _TreePainter extends CustomPainter {
  final double progress;
  final double completionRatio;
  final int completedCount;

  _TreePainter({
    required this.progress,
    required this.completionRatio,
    required this.completedCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.passione.withValues(alpha: 0.8)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final startPoint = Offset(size.width / 2, size.height - 20);
    final trunkHeight = 60.0 * (0.5 + (completionRatio * 0.5)) * progress;
    
    // Draw trunk
    _drawBranch(canvas, startPoint, -pi / 2, trunkHeight, 4.0, paint, 0, min(4, completedCount + 1));

    // Draw glowing aura at the base
    final glowPaint = Paint()
      ..color = AppColors.passione.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(startPoint, 30 * progress, glowPaint);
  }

  void _drawBranch(Canvas canvas, Offset start, double angle, double length, double width, Paint paint, int depth, int maxDepth) {
    if (depth >= maxDepth) {
      // Draw a leaf/flower at the end if there are completed tasks
      if (depth > 1) {
        final leafPaint = Paint()
          ..color = AppColors.passione
          ..style = PaintingStyle.fill;
        canvas.drawCircle(start, 4.0 * progress, leafPaint);
        
        final glow = Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(start, 6.0 * progress, glow);
      }
      return;
    }

    final end = Offset(
      start.dx + cos(angle) * length,
      start.dy + sin(angle) * length,
    );

    paint.strokeWidth = width;
    canvas.drawLine(start, end, paint);

    final random = Random(depth * 100); // stable randomness
    final branchAngle = pi / 4 + (random.nextDouble() * 0.2); // ~45 degrees spread
    final nextLength = length * 0.7;
    final nextWidth = width * 0.7;

    // Draw left and right branches
    _drawBranch(canvas, end, angle - branchAngle, nextLength, nextWidth, paint, depth + 1, maxDepth);
    _drawBranch(canvas, end, angle + branchAngle, nextLength, nextWidth, paint, depth + 1, maxDepth);
  }

  @override
  bool shouldRepaint(covariant _TreePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.completedCount != completedCount;
  }
}
