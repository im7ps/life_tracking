import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'dashboard_providers.dart';

class CheckpointReviewScreen extends ConsumerStatefulWidget {
  const CheckpointReviewScreen({super.key});

  @override
  ConsumerState<CheckpointReviewScreen> createState() =>
      _CheckpointReviewScreenState();
}

class _CheckpointReviewScreenState
    extends ConsumerState<CheckpointReviewScreen> {
  final Map<String, bool> _decisions = {}; // true = Rilancia, false = Abbandona

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = ref.watch(taskListProvider).valueOrNull ?? [];
    final uncompletedTasks = tasks.where((t) => !t.isCompleted).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "CHECKPOINT",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cosa è successo dall'ultimo checkpoint?",
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: uncompletedTasks.isEmpty
                  ? Center(
                      child: Text(
                        "Ottimo lavoro! Hai completato tutto.",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.energia,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: uncompletedTasks.length,
                      itemBuilder: (context, index) {
                        final t = uncompletedTasks[index];
                        final decision = _decisions[t.id];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                t.icon,
                                color: _getCategoryColor(t.category),
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  t.title,
                                  style: theme.textTheme.titleLarge,
                                ),
                              ),
                              _buildActionButton(
                                "Rilancia",
                                decision == true,
                                AppColors.energia,
                                () => setState(() => _decisions[t.id] = true),
                              ),
                              const SizedBox(width: 8),
                              _buildActionButton(
                                "Abbandona",
                                decision == false,
                                AppColors.passione,
                                () => setState(() => _decisions[t.id] = false),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dovere,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  // Passiamo le decisioni di rilancio/abbandono al provider
                  await ref
                      .read(taskListProvider.notifier)
                      .concludeCheckpoint(_decisions);
                  if (context.mounted) context.go('/');
                },
                child: const Text(
                  "AGGIORNA RANK",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    bool isSelected,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : AppColors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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
