import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class RankWidget extends StatelessWidget {
  final double score; // 0.0 to 1.0
  final String rankLabel;
  final VoidCallback? onTap;

  const RankWidget({
    super.key,
    required this.score,
    required this.rankLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Gauge Ring
          SizedBox(
            width: 220,
            height: 220,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: score),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 8,
                  backgroundColor: theme.cardTheme.color?.withValues(alpha: 0.5) ?? AppColors.surface,
                  color: AppColors.dovere,
                  strokeCap: StrokeCap.round,
                );
              },
            ),
          ),
          // Inner Gradient Circle
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.dovere.withValues(alpha: 0.3),
                  AppColors.anima.withValues(alpha: 0.3),
                ],
                center: Alignment.center,
                radius: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  rankLabel,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 48,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  "Top 10% di sempre",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
