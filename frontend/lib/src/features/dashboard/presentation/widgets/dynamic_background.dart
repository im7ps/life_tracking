import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DynamicBackground extends StatefulWidget {
  final Widget child;
  const DynamicBackground({super.key, required this.child});

  @override
  State<DynamicBackground> createState() => _DynamicBackgroundState();
}

class _DynamicBackgroundState extends State<DynamicBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark layer
        Positioned.fill(
          child: Container(color: AppColors.background),
        ),
        
        // Blobs layer
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final size = MediaQuery.of(context).size;
            return Stack(
              children: [
                _buildBlob(
                  color: AppColors.dovere.withValues(alpha: 0.8),
                  diameter: 600,
                  offset: Offset(
                    size.width * 0.1 + 100 * cos(_controller.value * 2 * pi),
                    size.height * 0.1 + 150 * sin(_controller.value * 2 * pi),
                  ),
                ),
                _buildBlob(
                  color: AppColors.anima.withValues(alpha: 0.8),
                  diameter: 550,
                  offset: Offset(
                    size.width * 0.7 + 80 * sin(_controller.value * 2 * pi),
                    size.height * 0.3 + 120 * cos(_controller.value * 2 * pi),
                  ),
                ),
                _buildBlob(
                  color: AppColors.passione.withValues(alpha: 0.7),
                  diameter: 750,
                  offset: Offset(
                    size.width * 0.05 + 60 * sin(_controller.value * pi),
                    size.height * 0.7 + 100 * cos(_controller.value * pi),
                  ),
                ),
                _buildBlob(
                  color: AppColors.energia.withValues(alpha: 0.65),
                  diameter: 600,
                  offset: Offset(
                    size.width * 0.5 + 120 * cos(_controller.value * 1.5 * pi),
                    size.height * 0.8 + 100 * sin(_controller.value * 1.5 * pi),
                  ),
                ),
              ],
            );
          },
        ),
        
        // Glassmorphism Blur Layer
        Positioned.fill(
          child: BackdropFilter(
            filter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.1),
              BlendMode.darken,
            ),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        
        // Adding image filter blur separately for better control
        Positioned.fill(
          child: BackdropFilter(
            filter: const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                backgroundBlendMode: BlendMode.overlay,
              ),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ),
        
        widget.child,
      ],
    );
  }

  Widget _buildBlob({required Color color, required double diameter, required Offset offset}) {
    return Positioned(
      left: offset.dx - (diameter / 2),
      top: offset.dy - (diameter / 2),
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0.0),
            ],
            stops: const [0.4, 1.0], // Increased solid center for visibility
          ),
        ),
      ),
    );
  }
}
