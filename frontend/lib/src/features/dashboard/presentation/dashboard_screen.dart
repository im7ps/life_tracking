import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'dashboard_providers.dart';
import 'widgets/day0/rank_widget.dart';
import 'widgets/day0/checkpoint_bar.dart';
import 'widgets/day0/identity_grid.dart';
import 'widgets/visualizations/category_visualizer.dart';
import 'widgets/dynamic_background.dart';
import 'widgets/active_task_bar.dart';

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

  void _syncPageController() {
    if (!_pageController.hasClients) return;
    
    final categories = ref.read(availableCategoriesProvider);
    if (categories.isEmpty) return;
    
    final currentCatIndex = ref.read(currentCategoryProvider);
    final currentPage = _pageController.page?.round() ?? 0;
    final actualIndexOnPage = currentPage % categories.length;
    
    if (actualIndexOnPage != currentCatIndex) {
      // We are out of sync due to categories list change.
      // We need to find the closest page that matches currentCatIndex
      final targetPage = currentPage + (currentCatIndex - actualIndexOnPage);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(targetPage);
        }
      });
    }
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

    // Sync if needed after build
    if (categories.isNotEmpty) {
      _syncPageController();
    }

    if (categories.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentCat = categories[currentCatIndex];

    return Scaffold(
      backgroundColor: Colors.transparent,
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
      body: DynamicBackground(
        child: SafeArea(
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.help_outline_rounded, color: AppColors.grey),
                        onPressed: () => _showTutorial(context),
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
                    final timeBlock = ref.watch(timeBlockProvider.notifier);

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
                          CheckpointBar(
                            progress: timeBlock.getProgress(),
                            currentBlock: timeBlock.getLabel(),
                            nextBlock: timeBlock.getNextLabel(),
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
                                "RIEPILOGO TASK",
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
                          const ActiveTaskBar(),
                          const SizedBox(height: 80),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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

  void _showTutorial(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("GUIDA DAY 0", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tutorialItem(Icons.bolt_rounded, "Il Consulente", "Tocca il fulmine per ricevere 5 proposte basate sul tuo stato attuale."),
            _tutorialItem(Icons.touch_app_rounded, "Azioni Rapide", "Tocca una task per completarla, tieni premuto per i dettagli."),
            _tutorialItem(Icons.play_arrow_rounded, "Timer", "Usa il tasto play sulle card per tracciare il tempo reale."),
            _tutorialItem(Icons.auto_awesome_mosaic_rounded, "Categorie", "Scorri a destra e sinistra per cambiare sfera d'azione."),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CAPITO")),
        ],
      ),
    );
  }

  Widget _tutorialItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.anima, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
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
    final TextEditingController subTaskController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 0.5),
          ),
          child: SingleChildScrollView(
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
                  textAlign: TextAlign.center,
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
                
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatChip(context, "Fatica", task.difficulty.toString(), Icons.fitness_center),
                    const SizedBox(width: 12),
                    _buildStatChip(context, "Soddisfazione", task.satisfaction.toString(), Icons.star),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Recurring Toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("TASK RICORRENTE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54)),
                  subtitle: const Text("Si resetta automaticamente ogni giorno", style: TextStyle(fontSize: 10, color: Colors.white24)),
                  value: task.isRecurring,
                  activeColor: AppColors.energia,
                  onChanged: (val) {
                    ref.read(taskListProvider.notifier).toggleRecurring(task.id);
                    setModalState(() {
                      task = task.copyWith(isRecurring: val);
                    });
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Sub-tasks Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "SUB-TASK / CHECKLIST",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white54,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Sub-tasks list
                ...task.subTasks.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final sub = entry.value;
                  final isDone = sub['done'] as bool? ?? false;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: isDone,
                            activeColor: _getCategoryColor(task.category),
                            onChanged: (val) {
                              final newList = List<Map<String, dynamic>>.from(task.subTasks);
                              newList[idx] = {...newList[idx], 'done': val};
                              ref.read(taskListProvider.notifier).updateSubTasks(task.id, newList);
                              setModalState(() {
                                task = task.copyWith(subTasks: newList);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            sub['title'] as String? ?? "",
                            style: TextStyle(
                              fontSize: 14,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                              color: isDone ? Colors.white38 : Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Colors.white24),
                          onPressed: () {
                            final newList = List<Map<String, dynamic>>.from(task.subTasks);
                            newList.removeAt(idx);
                            ref.read(taskListProvider.notifier).updateSubTasks(task.id, newList);
                            setModalState(() {
                              task = task.copyWith(subTasks: newList);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }),
                
                // Add Sub-task field
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: subTaskController,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: "Aggiungi elemento...",
                            hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              final newList = [...task.subTasks, {'title': val.trim(), 'done': false}];
                              ref.read(taskListProvider.notifier).updateSubTasks(task.id, newList);
                              setModalState(() {
                                task = task.copyWith(subTasks: newList);
                                subTaskController.clear();
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.energia),
                        onPressed: () {
                          if (subTaskController.text.trim().isNotEmpty) {
                            final newList = [...task.subTasks, {'title': subTaskController.text.trim(), 'done': false}];
                            ref.read(taskListProvider.notifier).updateSubTasks(task.id, newList);
                            setModalState(() {
                              task = task.copyWith(subTasks: newList);
                              subTaskController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Delete Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () async {
                      await ref.read(taskListProvider.notifier).removeTask(task.id);
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline, color: AppColors.passione),
                    label: const Text("ELIMINA TASK", style: TextStyle(color: AppColors.passione, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
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
