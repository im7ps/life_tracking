import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../dashboard_models.dart';

class DutyMountain extends StatelessWidget {
  final List<TaskUIModel> tasks;
  const DutyMountain({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final completed = tasks.where((t) => t.isCompleted).length;
    final ratio = completed / max(1, tasks.length);

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dovere.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.dovere.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: CustomPaint(
        painter: _MountainPainter(ratio: ratio, completed: completed),
      ),
    );
  }
}

class _MountainPainter extends CustomPainter {
  final double ratio;
  final int completed;
  _MountainPainter({required this.ratio, required this.completed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final path = Path();
    final centerX = size.width / 2;
    final bottom = size.height - 30;
    
    // Dynamic height based on completion
    final height = 40 + (160 * ratio);
    final width = 100 + (60 * ratio);
    
    // Main Mountain Shadow/Back
    path.moveTo(centerX - width - 20, bottom);
    path.lineTo(centerX, bottom - height - 10);
    path.lineTo(centerX + width + 20, bottom);
    path.close();
    paint.color = AppColors.dovere.withValues(alpha: 0.3);
    canvas.drawPath(path, paint);

    // Main Mountain Front
    final frontPath = Path();
    frontPath.moveTo(centerX - width, bottom);
    frontPath.lineTo(centerX, bottom - height);
    frontPath.lineTo(centerX + width, bottom);
    frontPath.close();
    paint.color = AppColors.dovere.withValues(alpha: 0.8);
    canvas.drawPath(frontPath, paint);

    // Snow peak if progress is high
    if (ratio > 0.3) {
      final snowPath = Path();
      final snowHeight = height * 0.3;
      snowPath.moveTo(centerX, bottom - height);
      snowPath.lineTo(centerX - 25, bottom - height + snowHeight);
      snowPath.lineTo(centerX - 10, bottom - height + snowHeight - 5);
      snowPath.lineTo(centerX, bottom - height + snowHeight + 5);
      snowPath.lineTo(centerX + 15, bottom - height + snowHeight - 2);
      snowPath.lineTo(centerX + 25, bottom - height + snowHeight);
      snowPath.close();
      paint.color = Colors.white.withValues(alpha: 0.9);
      canvas.drawPath(snowPath, paint);
    }

    // Base ground line
    final groundPaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(20, bottom), Offset(size.width - 20, bottom), groundPaint);
  }

  @override
  bool shouldRepaint(covariant _MountainPainter oldDelegate) => oldDelegate.ratio != ratio;
}
