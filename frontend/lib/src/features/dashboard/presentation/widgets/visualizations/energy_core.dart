import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../dashboard_models.dart';

class EnergyCore extends StatefulWidget {
  final List<TaskUIModel> tasks;
  const EnergyCore({super.key, required this.tasks});

  @override
  State<EnergyCore> createState() => _EnergyCoreState();
}

class _EnergyCoreState extends State<EnergyCore> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.tasks.where((t) => t.isCompleted).length;
    final total = max(1, widget.tasks.length);
    final intensity = completed / total;

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.energia.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.energia.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: intensity * 10,
          )
        ],
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _CorePainter(
            progress: _controller.value,
            intensity: intensity,
            completedCount: completed,
          ),
        ),
      ),
    );
  }
}

class _CorePainter extends CustomPainter {
  final double progress;
  final double intensity;
  final int completedCount;

  _CorePainter({
    required this.progress,
    required this.intensity,
    required this.completedCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = 40.0 + (intensity * 40.0);
    
    // Core glow
    final glowPaint = Paint()
      ..color = AppColors.energia.withValues(alpha: 0.3 + (0.3 * intensity))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20 + (intensity * 30));
    canvas.drawCircle(center, baseRadius, glowPaint);

    // Inner Core
    final corePaint = Paint()
      ..color = AppColors.energia.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, baseRadius * 0.4, corePaint);

    // Rotating Orbits
    final orbitPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2 + (0.4 * intensity))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final numOrbits = 2 + (completedCount ~/ 2);
    for (int i = 0; i < numOrbits; i++) {
      final orbitRadius = baseRadius + (i * 15.0);
      final orbitAngle = (progress * 2 * pi) + (i * pi / 3);
      
      canvas.drawCircle(center, orbitRadius, orbitPaint);
      
      // Electron/Spark on orbit
      final electronPos = Offset(
        center.dx + cos(orbitAngle) * orbitRadius,
        center.dy + sin(orbitAngle) * orbitRadius,
      );
      canvas.drawCircle(electronPos, 4, Paint()..color = Colors.white);
      canvas.drawCircle(electronPos, 8, Paint()..color = AppColors.energia.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    }
  }

  @override
  bool shouldRepaint(covariant _CorePainter oldDelegate) => true;
}
