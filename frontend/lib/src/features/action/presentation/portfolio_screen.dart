import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import 'action_providers.dart';
import 'widgets/portfolio_card.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  String _selectedFilter = 'Tutti';
  final List<String> _filters = [
    'Tutti',
    'Dovere',
    'Passione',
    'Energia',
    'Anima',
    'Relazioni',
  ];

  final List<IconData> _availableIcons = const [
    FontAwesomeIcons.guitar,
    FontAwesomeIcons.dumbbell,
    FontAwesomeIcons.book,
    FontAwesomeIcons.phone,
    FontAwesomeIcons.laptopCode,
    FontAwesomeIcons.heart,
    FontAwesomeIcons.featherPointed,
    FontAwesomeIcons.lightbulb,
    FontAwesomeIcons.seedling,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final portfolioAsync = ref.watch(portfolioProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: Drawer(
        backgroundColor: theme.cardTheme.color,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Center(
                child: Text(
                  "MENU",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text("Impostazioni"),
              onTap: () => context.push('/settings'),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text("BIBLIOTECA DEL SÉ", style: theme.textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(portfolioProvider.notifier).refresh(),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
      body: portfolioAsync.when(
        data: (allTasks) {
          final filteredTasks = _selectedFilter == 'Tutti'
              ? allTasks
              : allTasks
                    .where(
                      (t) =>
                          t.category.toLowerCase() ==
                          _selectedFilter.toLowerCase(),
                    )
                    .toList();

          return Column(
            children: [
              // Category Filters
              SizedBox(
                height: 60,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = filter == _selectedFilter;
                    final filterColor = _getCategoryColor(filter);

                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? filterColor.withValues(alpha: 0.2)
                              : theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? filterColor
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            filter.toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? filterColor : AppColors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Task List
              Expanded(
                child: filteredTasks.isEmpty
                    ? Center(
                        child: Text(
                          "Nessuna attività trovata.",
                          style: TextStyle(color: AppColors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final t = filteredTasks[index];
                          return PortfolioCard(
                            title: t.title,
                            category: t.category,
                            completionCount: t.completionCount,
                            avgSatisfaction: t.satisfaction.toDouble(),
                            icon: t.icon,
                            onTap: () => _showTaskDetail(t, ref),
                            onScegli: () {
                              ref.read(taskListProvider.notifier).addTasks([t]);
                              context.go('/');
                            },
                          );
                        },
                      ),
              ),

              // Add Task Button at the Bottom
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _showCreateTaskModal(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      "CREA NUOVA MISSIONE",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text("Errore nel caricamento: $err")),
      ),
    );
  }

  void _showTaskDetail(TaskUIModel task, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(task.icon, size: 64, color: _getCategoryColor(task.category)),
            const SizedBox(height: 16),
            Text(
              task.title.toUpperCase(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatChip(
                  "Fatica",
                  task.difficulty.toString(),
                  Icons.fitness_center,
                ),
                const SizedBox(width: 12),
                _buildStatChip(
                  "Soddisfazione",
                  task.satisfaction.toString(),
                  Icons.star,
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(taskListProvider.notifier).addTasks([task]);
                  context.go('/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dovere,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "AGGIUNGI ALLA GIORNATA",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                ref.read(portfolioProvider.notifier).removeTask(task.id);
                Navigator.pop(context);
              },
              child: const Text(
                "Elimina dal Portfolio",
                style: TextStyle(color: AppColors.passione),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.grey),
          const SizedBox(width: 8),
          Text(
            "$label: $value",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showCreateTaskModal() {
    String title = "";
    String category = "Dovere";
    double fatigue = 3;
    double satisfaction = 3;
    IconData selectedIcon = FontAwesomeIcons.circle;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) => Container(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "NUOVA MISSIONE",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: "TITOLO",
                    labelStyle: const TextStyle(color: AppColors.grey),
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => title = val,
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("ICONA", style: theme.textTheme.labelLarge),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 64,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _availableIcons.length,
                    itemBuilder: (context, index) {
                      final icon = _availableIcons[index];
                      final isSelected = selectedIcon == icon;
                      return GestureDetector(
                        onTap: () => setStateModal(() => selectedIcon = icon),
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.dovere
                                : theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              icon,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("CATEGORIA", style: theme.textTheme.labelLarge),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      [
                        "Dovere",
                        "Passione",
                        "Energia",
                        "Anima",
                        "Relazioni",
                      ].map((cat) {
                        final isSelected = category == cat;
                        final catColor = _getCategoryColor(cat);
                        return GestureDetector(
                          onTap: () => setStateModal(() => category = cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? catColor
                                  : theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              cat.toUpperCase(),
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 32),
                _buildSlider(
                  "FATICA",
                  fatigue,
                  (val) => setStateModal(() => fatigue = val),
                ),
                _buildSlider(
                  "SODDISFAZIONE",
                  satisfaction,
                  (val) => setStateModal(() => satisfaction = val),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        if (title.isNotEmpty) {
                          // Note: In a real app, you would use ActionCreateController here to persist to backend.
                          // For now, let's just use the local provider logic or refactor to backend.
                          final dimensionMapping = {
                            'Dovere': 'dovere',
                            'Passione': 'passione',
                            'Energia': 'energia',
                            'Anima': 'anima',
                            'Relazioni': 'relazioni',
                          };

                          await ref
                              .read(actionCreateControllerProvider.notifier)
                              .createAction(
                                description: title,
                                dimensionId:
                                    dimensionMapping[category] ?? 'dovere',
                                fulfillmentScore: satisfaction.round(),
                              );

                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        "CREA E AGGIUNGI",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, Function(double) onChanged) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value.round().toString(),
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 1,
          max: 5,
          divisions: 4,
          activeColor: AppColors.dovere,
          inactiveColor: theme.scaffoldBackgroundColor,
          onChanged: onChanged,
        ),
      ],
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
