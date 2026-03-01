import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../dashboard_models.dart';

class SoulConstellation extends StatefulWidget {
  final List<TaskUIModel> tasks;

  const SoulConstellation({super.key, required this.tasks});

  @override
  State<SoulConstellation> createState() => _SoulConstellationState();
}

class _SoulConstellationState extends State<SoulConstellation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Offset> _starPositions;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _generateStars();
  }

  void _generateStars() {
    final random = Random(42);
    _starPositions = List.generate(15, (index) {
      return Offset(random.nextDouble(), random.nextDouble());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completedTasks = widget.tasks.where((t) => t.isCompleted).length;
    // Map completed tasks to connected stars
    final connections = min(completedTasks * 2, _starPositions.length - 1);

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.anima.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.anima.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ConstellationPainter(
              stars: _starPositions,
              connections: connections,
              pulseProgress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _ConstellationPainter extends CustomPainter {
  final List<Offset> stars;
  final int connections;
  final double pulseProgress;

  _ConstellationPainter({
    required this.stars,
    required this.connections,
    required this.pulseProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final List<Offset> actualPositions = stars.map((s) {
      return Offset(s.dx * size.width, s.dy * size.height);
    }).toList();

    // Draw lines (connections)
    final linePaint = Paint()
      ..color = AppColors.anima.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    for (int i = 0; i < connections; i++) {
      if (i + 1 < actualPositions.length) {
        canvas.drawLine(actualPositions[i], actualPositions[i + 1], linePaint);
      }
    }

    // Draw stars
    for (int i = 0; i < actualPositions.length; i++) {
      final pos = actualPositions[i];
      final isConnected = i <= connections;
      
      final starSize = isConnected ? 3.0 + (1.0 * pulseProgress) : 2.0;
      final starPaint = Paint()
        ..color = isConnected ? AppColors.white : AppColors.anima.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;
        
      canvas.drawCircle(pos, starSize, starPaint);

      if (isConnected) {
        final glow = Paint()
          ..color = AppColors.anima.withValues(alpha: 0.4)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(pos, starSize * 2, glow);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) {
    return oldDelegate.pulseProgress != pulseProgress || oldDelegate.connections != connections;
  }
}
