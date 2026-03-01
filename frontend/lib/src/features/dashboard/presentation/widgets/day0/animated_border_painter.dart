import 'package:flutter/material.dart';

class AnimatedBorderPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  final double strokeWidth;

  AnimatedBorderPainter({
    required this.animation,
    required this.color,
    this.strokeWidth = 3.0,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    ));

    final pathMetrics = path.computeMetrics().first;
    final length = pathMetrics.length;
    
    // Create a moving segment effect
    final double dashLength = length * 0.3;
    final double distance = animation.value * length;
    
    final Path extractPath = Path();
    
    double start = distance;
    double end = distance + dashLength;
    
    if (end <= length) {
      extractPath.addPath(pathMetrics.extractPath(start, end), Offset.zero);
    } else {
      extractPath.addPath(pathMetrics.extractPath(start, length), Offset.zero);
      extractPath.addPath(pathMetrics.extractPath(0, end - length), Offset.zero);
    }

    canvas.drawPath(extractPath, paint);
    
    // Optional: draw a very faint full border
    final faintPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    ), faintPaint);
  }

  @override
  bool shouldRepaint(covariant AnimatedBorderPainter oldDelegate) => true;
}
