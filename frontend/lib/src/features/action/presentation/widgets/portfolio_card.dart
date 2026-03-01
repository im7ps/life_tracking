import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PortfolioCard extends StatelessWidget {
  final String title;
  final String category;
  final int completionCount;
  final double avgSatisfaction;
  final IconData icon;
  final List<dynamic> subTasks;
  final VoidCallback onTap;
  final VoidCallback onScegli;

  const PortfolioCard({
    super.key,
    required this.title,
    required this.category,
    required this.completionCount,
    required this.avgSatisfaction,
    required this.icon,
    this.subTasks = const [],
    required this.onTap,
    required this.onScegli,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getCategoryColor(category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: color, width: 2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "Soddisfazione: ${avgSatisfaction.toStringAsFixed(1)}",
                          style: theme.textTheme.labelSmall?.copyWith(color: AppColors.grey),
                        ),
                        if (subTasks.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.checklist_rounded, size: 12, color: AppColors.grey.withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Text(
                            "${subTasks.length}",
                            style: theme.textTheme.labelSmall?.copyWith(color: AppColors.grey.withValues(alpha: 0.6)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: onScegli,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color.withValues(alpha: 0.5)),
                  foregroundColor: color,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("SCEGLI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'dovere': return AppColors.dovere;
      case 'passione': return AppColors.passione;
      case 'energia': return AppColors.energia;
      case 'anima': return AppColors.anima;
      case 'relazioni': return AppColors.relazioni;
      default: return AppColors.neutral;
    }
  }
}
