import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'dashboard_providers.dart';
import 'widgets/day0/rank_widget.dart';
import 'widgets/day0/checkpoint_bar.dart';
import 'widgets/day0/identity_grid.dart';
import 'widgets/visualizations/category_visualizer.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late PageController _pageController;
  static const int _infinitePages = 10000;

  @override
  void initState() {
    super.initState();
    // Start at a high number to allow circular swiping, offset to land on current index
    final initialPage = (_infinitePages ~/ 2); 
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ref.watch(availableCategoriesProvider);
    final currentCatIndex = ref.watch(currentCategoryProvider);

    if (categories.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentCat = categories[currentCatIndex];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: Drawer(
        backgroundColor: theme.cardTheme.color,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              child: Center(
                child: Text(
                  "DAY 0",
                  style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text("Impostazioni"),
              onTap: () => context.push('/settings'),
            ),
            ListTile(
              leading: const Icon(Icons.swap_vert_rounded),
              title: const Text("Ordina Categorie"),
              onTap: () => context.push('/categories'),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline_rounded),
              title: const Text("Rivedi Onboarding"),
              onTap: () => context.push('/onboarding'),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("Account"),
              onTap: () => context.push('/account'),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Builder(
                    builder: (context) => Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.menu_rounded, color: AppColors.grey),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                  ),
                  Text(
                    currentCat.label,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            
            // Dashboard Indicators (Icons)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(categories.length, (index) {
                  final cat = categories[index];
                  final isSelected = index == currentCatIndex;
                  return GestureDetector(
                    onTap: () {
                      final currentPage = _pageController.page?.round() ?? 0;
                      final targetPage = currentPage + (index - currentCatIndex);
                      _pageController.animateToPage(
                        targetPage,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? cat.color.withValues(alpha: 0.2) : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        cat.icon,
                        size: 20,
                        color: isSelected ? cat.color : AppColors.grey.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  final actualIndex = index % categories.length;
                  ref.read(currentCategoryProvider.notifier).setIndex(actualIndex);
                },
                itemBuilder: (context, index) {
                  final actualIndex = index % categories.length;
                  final cat = categories[actualIndex];
                  final tasks = ref.watch(tasksByCategoryProvider(cat.id));
                  final rankScore = ref.watch(rankByCategoryProvider(cat.id));
                  final rankLabel = ref.watch(rankLabelByCategoryProvider(cat.id));

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        RankWidget(
                          score: rankScore,
                          rankLabel: rankLabel,
                          onTap: () {
                            // TODO: Show history
                          },
                        ),
                        const SizedBox(height: 48),
                        const CheckpointBar(
                          progress: 0.6,
                          currentBlock: "Pranzo",
                          nextBlock: "Cena",
                        ),
                        const SizedBox(height: 32),
                        
                        // Action Button (Lightning Bolt)
                        GestureDetector(
                          onTap: () => context.push('/consultant'),
                          child: Container(
                            height: 64,
                            width: 64,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.bolt_rounded, size: 36, color: Colors.white),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Section Header with Sort
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "IDENTITÀ IN AZIONE",
                              style: theme.textTheme.labelLarge?.copyWith(
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.sort_rounded, size: 20, color: AppColors.grey),
                              onPressed: () => _showSortOptions(context, ref),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CategoryVisualizer(category: cat, tasks: tasks),
                        const SizedBox(height: 16),
                        IdentityGrid(
                          tasks: tasks,
                          onTaskTap: (task) => ref.read(taskListProvider.notifier).toggleCompletion(task.id),
                          onTaskLongPress: (task) => _showTaskDetail(context, ref, task),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.anima,
        unselectedItemColor: AppColors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_mosaic_rounded),
            label: 'Specchio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_rounded),
            label: 'Portfolio',
          ),
        ],
        onTap: (index) {
          if (index == 1) context.push('/portfolio');
        },
      ),
    );
  }

  void _showSortOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ORDINA PER",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _sortTile(context, ref, "Consigliato", TaskSortOrder.recommended),
            _sortTile(context, ref, "Fatica", TaskSortOrder.effort),
            _sortTile(context, ref, "Soddisfazione", TaskSortOrder.satisfaction),
          ],
        ),
      ),
    );
  }

  Widget _sortTile(BuildContext context, WidgetRef ref, String label, TaskSortOrder order) {
    final currentOrder = ref.watch(taskSortProvider);
    final isSelected = currentOrder == order;

    return ListTile(
      title: Text(label, style: TextStyle(color: isSelected ? AppColors.white : AppColors.grey)),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.energia) : null,
      onTap: () {
        ref.read(taskSortProvider.notifier).setSortOrder(order);
        Navigator.pop(context);
      },
    );
  }

  void _showTaskDetail(BuildContext context, WidgetRef ref, TaskUIModel task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(task.icon, size: 48, color: _getCategoryColor(task.category)),
            const SizedBox(height: 16),
            Text(
              task.title.toUpperCase(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "CATEGORIA: ${task.category.toUpperCase()}",
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatChip(
                  context,
                  "Fatica",
                  task.difficulty.toString(),
                  Icons.fitness_center,
                ),
                const SizedBox(width: 12),
                _buildStatChip(
                  context,
                  "Soddisfazione",
                  task.satisfaction.toString(),
                  Icons.star,
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.grey),
          const SizedBox(width: 8),
          Text(
            "$label: $value",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
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
