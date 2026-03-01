import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../dashboard_models.dart';

class RelationThreads extends StatelessWidget {
  final List<TaskUIModel> tasks;
  const RelationThreads({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final completed = tasks.where((t) => t.isCompleted).length;
    final total = max(1, tasks.length);
    final completionRatio = completed / total;

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.relazioni.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.relazioni.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: CustomPaint(
        painter: _ThreadPainter(ratio: completionRatio, count: completed),
      ),
    );
  }
}

class _ThreadPainter extends CustomPainter {
  final double ratio;
  final int count;
  _ThreadPainter({required this.ratio, required this.count});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final paint = Paint()
      ..color = AppColors.relazioni.withValues(alpha: 0.4 + (0.4 * ratio))
      ..strokeWidth = 1.5 + (ratio * 2.0)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Fixed points on the edges representing "People/Connections"
    final List<Offset> points = List.generate(8 + count, (index) {
      final r = Random(index * 123);
      return Offset(
        10 + r.nextDouble() * (size.width - 20),
        10 + r.nextDouble() * (size.height - 20),
      );
    });

    // Draw connecting threads
    final numConnections = 10 + (count * 5);
    for (int i = 0; i < numConnections; i++) {
      final p1 = points[random.nextInt(points.length)];
      final p2 = points[random.nextInt(points.length)];
      
      final controlPoint = Offset(
        (p1.dx + p2.dx) / 2 + (random.nextDouble() - 0.5) * 50,
        (p1.dy + p2.dy) / 2 + (random.nextDouble() - 0.5) * 50,
      );

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, p2.dx, p2.dy);
      
      canvas.drawPath(path, paint);
    }

    // Draw nodes
    final nodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    for (var p in points) {
      canvas.drawCircle(p, 3, nodePaint);
      canvas.drawCircle(p, 6, Paint()..color = AppColors.relazioni.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }
  }

  @override
  bool shouldRepaint(covariant _ThreadPainter oldDelegate) => oldDelegate.count != count;
}
