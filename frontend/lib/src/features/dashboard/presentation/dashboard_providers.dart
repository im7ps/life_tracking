import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../action/data/action_repository.dart';
import '../../action/domain/action.dart' as domain_action;
import '../../../core/storage/local_storage_service.dart';
import 'dashboard_models.dart';

export 'dashboard_models.dart';

part 'dashboard_providers.g.dart';

enum TimeBlockType { colazione, pranzo, cena, notte }

@riverpod
class TimeBlock extends _$TimeBlock {
  @override
  TimeBlockType build() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 11) return TimeBlockType.colazione;
    if (hour >= 11 && hour < 17) return TimeBlockType.pranzo;
    if (hour >= 17 && hour < 23) return TimeBlockType.cena;
    return TimeBlockType.notte;
  }

  String getLabel() {
    switch (state) {
      case TimeBlockType.colazione: return "COLAZIONE";
      case TimeBlockType.pranzo: return "PRANZO";
      case TimeBlockType.cena: return "CENA";
      case TimeBlockType.notte: return "FINE GIORNATA";
    }
  }

  String getNextLabel() {
    switch (state) {
      case TimeBlockType.colazione: return "PRANZO";
      case TimeBlockType.pranzo: return "CENA";
      case TimeBlockType.cena: return "FINE GIORNATA";
      case TimeBlockType.notte: return "DOMANI";
    }
  }

  double getProgress() {
    final now = DateTime.now();
    final minuteOfDay = now.hour * 60 + now.minute;

    int start, end;
    switch (state) {
      case TimeBlockType.colazione: start = 6 * 60; end = 11 * 60; break;
      case TimeBlockType.pranzo: start = 11 * 60; end = 17 * 60; break;
      case TimeBlockType.cena: start = 17 * 60; end = 23 * 60; break;
      case TimeBlockType.notte: return 1.0;
    }

    final total = end - start;
    final current = (minuteOfDay - start).clamp(0, total);
    return current / total;
  }
}

@riverpod
class TaskSort extends _$TaskSort {
  @override
  TaskSortOrder build() => TaskSortOrder.recommended;

  void setSortOrder(TaskSortOrder order) => state = order;
}

@riverpod
class CurrentCategory extends _$CurrentCategory {
  @override
  int build() => 0; // Index 0 is 'Generali'

  void setIndex(int index) => state = index;
}

@riverpod
class CategoryOrder extends _$CategoryOrder {
  @override
  Future<List<String>> build() async {
    final storage = ref.watch(localStorageServiceProvider);
    return await storage.loadCategoryOrder();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final currentOrder = state.valueOrNull ?? [];
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final List<String> newList = List.from(currentOrder);
    final String item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    
    state = AsyncValue.data(newList);
    final storage = ref.read(localStorageServiceProvider);
    await storage.saveCategoryOrder(newList);
  }

  Future<void> updateOrder(List<String> newOrder) async {
    state = AsyncValue.data(newOrder);
    final storage = ref.read(localStorageServiceProvider);
    await storage.saveCategoryOrder(newOrder);
  }
}

@riverpod
List<CategoryInfo> availableCategories(Ref ref) {
  final tasksAsync = ref.watch(taskListProvider);
  final tasks = tasksAsync.valueOrNull ?? [];
  final customOrderAsync = ref.watch(categoryOrderProvider);
  final customOrder = customOrderAsync.valueOrNull ?? [];

  // Map to store unique categories found in tasks
  final Map<String, CategoryInfo> foundCategories = {
    'general': const CategoryInfo(
      id: 'general',
      label: 'GENERALI',
      icon: Icons.dashboard_rounded,
      color: Colors.white,
    ),
  };

  for (final task in tasks) {
    final catId = task.category.toLowerCase();
    if (!foundCategories.containsKey(catId)) {
      foundCategories[catId] = CategoryInfo(
        id: catId,
        label: task.category.toUpperCase(),
        icon: task.icon,
        color: task.color,
      );
    }
  }

  final List<CategoryInfo> orderedCategories = [];
  
  // 1. Always start with General
  if (foundCategories.containsKey('general')) {
    orderedCategories.add(foundCategories['general']!);
  }

  // 2. Add categories from custom order if they exist in current tasks
  for (final catId in customOrder) {
    if (catId != 'general' && foundCategories.containsKey(catId)) {
      orderedCategories.add(foundCategories[catId]!);
    }
  }

  // 3. Add any remaining categories not in custom order
  final remainingCats = foundCategories.keys.where(
    (id) => id != 'general' && !customOrder.contains(id),
  ).toList()..sort();

  for (final catId in remainingCats) {
    orderedCategories.add(foundCategories[catId]!);
  }

  return orderedCategories;
}

@riverpod
class TaskList extends _$TaskList {
  @override
  Future<List<TaskUIModel>> build() async {
    final storage = ref.watch(localStorageServiceProvider);
    final localTasks = await storage.loadTasks();
    
    // Al caricamento, proviamo a sincronizzare con il backend per recuperare task create via chat
    // Usiamo microtask per non bloccare il build
    Future.microtask(() => syncWithBackend());
    
    return localTasks;
  }

  Future<void> syncWithBackend() async {
    final repo = ref.read(actionRepositoryProvider);
    final currentTasks = state.valueOrNull ?? [];
    
    debugPrint("DEBUG: TaskList.syncWithBackend - START");
    debugPrint("DEBUG: TaskList.syncWithBackend - Local tasks count: ${currentTasks.length}");

    try {
      final remoteActions = await repo.getUserActions(limit: 20);
      debugPrint("DEBUG: TaskList.syncWithBackend - Received ${remoteActions.length} actions from backend");
      
      final List<TaskUIModel> updatedList = List.from(currentTasks);
      bool changed = false;

      for (final action in remoteActions) {
        debugPrint("DEBUG: TaskList.syncWithBackend - Inspecting Remote Action: '${action.description}' [Status: ${action.status}, ID: ${action.id}]");
        
        if (action.status == "IN_PROGRESS") {
          final alreadyExists = updatedList.any((t) {
            final idMatch = t.id == action.id;
            final descMatch = t.title.toLowerCase() == (action.description ?? "").toLowerCase() && t.status == "IN_PROGRESS";
            return idMatch || descMatch;
          });
          
          if (!alreadyExists) {
            debugPrint("DEBUG: TaskList.syncWithBackend - !! ADDING NEW TASK TO DASHBOARD: ${action.description}");
            updatedList.add(TaskUIModel.fromActionJson({
              'id': action.id,
              'description': action.description,
              'category': action.category,
              'difficulty': action.difficulty,
              'fulfillment_score': action.fulfillmentScore,
              'status': action.status,
              'duration_minutes': action.durationMinutes,
              'sub_tasks': action.subTasks,
              'is_recurring': action.isRecurring,
            }));
            changed = true;
          } else {
            debugPrint("DEBUG: TaskList.syncWithBackend - Task already exists in local list, skipping.");
          }
        }
      }

      if (changed) {
        debugPrint("DEBUG: TaskList.syncWithBackend - UPDATING STATE AND STORAGE. New count: ${updatedList.length}");
        await _save(updatedList);
      } else {
        debugPrint("DEBUG: TaskList.syncWithBackend - NO CHANGES APPLIED.");
      }
    } catch (e) {
      debugPrint("DEBUG: TaskList.syncWithBackend - CRITICAL ERROR: $e");
    }
  }

  Future<void> removeTask(String id) async {
    final currentTasks = state.valueOrNull ?? [];
    final newState = currentTasks.where((t) => t.id != id).toList();
    await _save(newState);
  }

  Future<void> removeTaskByTitle(String title) async {
    final currentTasks = state.valueOrNull ?? [];
    final newState = currentTasks.where((t) => t.title.toLowerCase() != title.toLowerCase()).toList();
    await _save(newState);
  }

  Future<void> _save(List<TaskUIModel> newState) async {
    state = AsyncValue.data(newState);
    final storage = ref.read(localStorageServiceProvider);
    await storage.saveTasks(newState);
  }

  Future<void> cycleStatus(String id) async {
    final currentTasks = state.valueOrNull ?? [];
    final task = currentTasks.firstWhere((t) => t.id == id);
    final repo = ref.read(actionRepositoryProvider);

    String newStatus;
    bool isCompleted = false;
    bool isRunning = false;
    final now = DateTime.now();
    int newTotalSeconds = task.totalSeconds;

    if (task.status == 'PENDING') {
      newStatus = 'IN_PROGRESS';
      isRunning = true;
    } else if (task.status == 'IN_PROGRESS') {
      newStatus = 'COMPLETED';
      isCompleted = true;
      isRunning = false;
      if (task.lastStartedAt != null) {
        newTotalSeconds += now.difference(task.lastStartedAt!).inSeconds;
      }
    } else {
      newStatus = 'PENDING';
      isCompleted = false;
      isRunning = false;
    }

    final updatedTask = task.copyWith(
      status: newStatus,
      isCompleted: isCompleted,
      isRunning: isRunning,
      lastStartedAt: isRunning ? now : null,
      totalSeconds: newTotalSeconds,
    );

    final newState = [
      for (final t in currentTasks)
        if (t.id == id) updatedTask else t,
    ];
    await _save(newState);

    // Update Backend
    await repo.updateAction(id, {
      'status': newStatus,
      'is_running': isRunning,
      'last_started_at': isRunning ? now.toIso8601String() : null,
      'total_seconds': newTotalSeconds,
    });
  }

  Future<void> toggleTimer(String id) async {
    final currentTasks = state.valueOrNull ?? [];
    final task = currentTasks.firstWhere((t) => t.id == id);
    final repo = ref.read(actionRepositoryProvider);

    final now = DateTime.now();
    bool newIsRunning = !task.isRunning;
    int newTotalSeconds = task.totalSeconds;

    if (!newIsRunning && task.lastStartedAt != null) {
      // Stopping: calculate elapsed time
      newTotalSeconds += now.difference(task.lastStartedAt!).inSeconds;
    }

    final updatedTask = task.copyWith(
      isRunning: newIsRunning,
      lastStartedAt: newIsRunning ? now : null,
      totalSeconds: newTotalSeconds,
    );

    // Update Local
    final newState = [
      for (final t in currentTasks)
        if (t.id == id) updatedTask else t,
    ];
    await _save(newState);

    // Update Backend
    await repo.updateAction(id, {
      'is_running': newIsRunning,
      'last_started_at': newIsRunning ? now.toIso8601String() : null,
      'total_seconds': newTotalSeconds,
    });
  }

  Future<void> scheduleTask(String id, DateTime date) async {
    final currentTasks = state.valueOrNull ?? [];
    final repo = ref.read(actionRepositoryProvider);

    final updatedTask = currentTasks.firstWhere((t) => t.id == id).copyWith(
      scheduledDate: date,
    );

    final newState = [
      for (final t in currentTasks)
        if (t.id == id) updatedTask else t,
    ];
    await _save(newState);

    await repo.updateAction(id, {
      'scheduled_date': date.toIso8601String(),
    });
  }

  Future<void> updateSubTasks(String id, List<Map<String, dynamic>> subTasks) async {
    final currentTasks = state.valueOrNull ?? [];
    final repo = ref.read(actionRepositoryProvider);

    final updatedTask = currentTasks.firstWhere((t) => t.id == id).copyWith(
      subTasks: subTasks,
    );

    final newState = [
      for (final t in currentTasks)
        if (t.id == id) updatedTask else t,
    ];
    await _save(newState);

    await repo.updateAction(id, {
      'sub_tasks': subTasks,
    });
  }

  Future<void> toggleRecurring(String id) async {
    final currentTasks = state.valueOrNull ?? [];
    final task = currentTasks.firstWhere((t) => t.id == id);
    final repo = ref.read(actionRepositoryProvider);

    final updatedTask = task.copyWith(isRecurring: !task.isRecurring);

    final newState = [
      for (final t in currentTasks)
        if (t.id == id) updatedTask else t,
    ];
    await _save(newState);

    await repo.updateAction(id, {'is_recurring': updatedTask.isRecurring});
  }

  Future<void> toggleCompletion(String id) async {
    final currentTasks = state.valueOrNull ?? [];
    final newState = [
      for (final task in currentTasks)
        if (task.id == id)
          task.copyWith(isCompleted: !task.isCompleted)
        else
          task,
    ];
    await _save(newState);
  }

  Future<void> addTasks(List<TaskUIModel> newTasks) async {
    final currentTasks = state.valueOrNull ?? [];
    final List<TaskUIModel> updatedList = List.from(currentTasks);
    bool changed = false;

    for (var nt in newTasks) {
      // Prevent duplicates by title (case insensitive)
      final alreadyExists = updatedList.any(
        (t) => t.title.toLowerCase() == nt.title.toLowerCase(),
      );

      if (alreadyExists) {
        debugPrint(
          "DEBUG: TaskList.addTasks - Task '${nt.title}' already exists in Dashboard. Skipping.",
        );
        continue;
      }

      updatedList.add(
        nt.copyWith(
          id: nt.id.isEmpty
              ? DateTime.now().microsecondsSinceEpoch.toString()
              : nt.id,
          status: 'PENDING',
          // Deep copy subtasks list
          subTasks: List<Map<String, dynamic>>.from(nt.subTasks),
          isRecurring: nt.isRecurring,
        ),
      );
      changed = true;
    }

    if (changed) {
      await _save(updatedList);
    }
  }

  Future<void> updateTask(TaskUIModel updatedTask) async {
    final currentTasks = state.valueOrNull ?? [];
    final newState = [
      for (final task in currentTasks)
        if (task.id == updatedTask.id) updatedTask else task,
    ];
    await _save(newState);
  }

  Future<void> concludeCheckpoint(Map<String, bool> decisions) async {
    final repo = ref.read(actionRepositoryProvider);
    final currentTasks = state.valueOrNull ?? [];

    try {
      final List<TaskUIModel> rolloverTasks = [];

      for (final task in currentTasks) {
        if (task.isCompleted) {
          // 1. Task Completata: aggiorniamo stato sul backend
          await repo.updateAction(task.id, {'status': 'COMPLETED'});
          debugPrint("CHECKPOINT: Task '${task.title}' marked COMPLETED.");
          
          if (task.isRecurring) {
            // Se è ricorrente, creiamo una nuova istanza per il futuro (o la resettiamo)
            // Per ora la ri-aggiungiamo alla lista locale come IN_PROGRESS per il prossimo blocco
            final recurringTask = task.copyWith(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              isCompleted: false,
              status: 'IN_PROGRESS',
              totalSeconds: 0,
              lastStartedAt: null,
            );
            
            // Creiamo anche sul backend
            await repo.createAction(domain_action.ActionCreate(
              description: recurringTask.title,
              category: recurringTask.category,
              difficulty: recurringTask.difficulty,
              fulfillmentScore: recurringTask.satisfaction,
              dimensionId: _mapCategoryToDimensionId(recurringTask.category),
              status: 'IN_PROGRESS',
            ));
            
            rolloverTasks.add(recurringTask);
            debugPrint("CHECKPOINT: Recurring Task '${task.title}' RE-CREATED.");
          }
        } else {
          final shouldRollover = decisions[task.id] ?? false;
          if (shouldRollover) {
            // 2. Rilancio (Rollover): rimane IN_PROGRESS, aggiorniamo solo il timestamp per il nuovo blocco
            await repo.updateAction(task.id, {
              'start_time': DateTime.now().toIso8601String(),
            });
            rolloverTasks.add(task);
            debugPrint("CHECKPOINT: Task '${task.title}' ROLLED OVER.");
          } else {
            // 3. Abbandono: segnata come FALLITA sul backend
            await repo.updateAction(task.id, {'status': 'FAILED'});
            debugPrint("CHECKPOINT: Task '${task.title}' marked FAILED.");
          }
        }
      }

      // Aggiorniamo lo stato locale: restano solo quelle rilanciate
      await _save(rolloverTasks);
      debugPrint("CHECKPOINT: Concluded. Local dashboard cleared except for ${rolloverTasks.length} rolled over tasks.");
    } catch (e) {
      debugPrint("ERRORE durante concludeCheckpoint: $e");
      rethrow;
    }
  }

  String _mapCategoryToDimensionId(String category) {
    switch (category.toLowerCase()) {
      case 'passione':
        return 'passione';
      case 'dovere':
        return 'dovere';
      case 'energia':
        return 'energia';
      case 'anima':
        return 'anima';
      case 'relazioni':
        return 'relazioni';
      default:
        return 'dovere';
    }
  }
}

@riverpod
List<TaskUIModel> tasksByCategory(Ref ref, String categoryId) {
  final tasksAsync = ref.watch(taskListProvider);
  final sort = ref.watch(taskSortProvider);

  return tasksAsync.when(
    data: (tasks) {
      Iterable<TaskUIModel> filtered = tasks;
      if (categoryId != 'general') {
        filtered = tasks.where(
          (t) => t.category.toLowerCase() == categoryId,
        );
      }

      List<TaskUIModel> sortedList = List.from(filtered);
      switch (sort) {
        case TaskSortOrder.effort:
          sortedList.sort((a, b) => b.difficulty.compareTo(a.difficulty));
          break;
        case TaskSortOrder.satisfaction:
          sortedList.sort((a, b) => b.satisfaction.compareTo(a.satisfaction));
          break;
        case TaskSortOrder.recommended:
          break;
      }
      return sortedList;
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

@riverpod
double rankByCategory(Ref ref, String categoryId) {
  final tasksAsync = ref.watch(taskListProvider);

  return tasksAsync.maybeWhen(
    data: (tasks) {
      Iterable<TaskUIModel> relevantTasks = tasks;
      if (categoryId != 'general') {
        relevantTasks = tasks.where(
          (t) => t.category.toLowerCase() == categoryId,
        );
      }

      if (relevantTasks.isEmpty) return 0.0;
      final completed = relevantTasks.where((t) => t.isCompleted).length;

      return (completed * 0.25).clamp(0.0, 1.0);
    },
    orElse: () => 0.0,
  );
}

@riverpod
String rankLabelByCategory(Ref ref, String categoryId) {
  final score = ref.watch(rankByCategoryProvider(categoryId));
  if (score >= 1.0) return "GOD";
  if (score >= 0.75) return "S";
  if (score >= 0.50) return "A";
  if (score >= 0.25) return "B";
  return "C";
}

@riverpod
List<TaskUIModel> filteredTasks(Ref ref) {
  final categories = ref.watch(availableCategoriesProvider);
  final currentCatIndex = ref.watch(currentCategoryProvider);

  if (currentCatIndex >= categories.length) return [];
  final currentCat = categories[currentCatIndex];

  return ref.watch(tasksByCategoryProvider(currentCat.id));
}

@riverpod
double rank(Ref ref) {
  final categories = ref.watch(availableCategoriesProvider);
  final currentCatIndex = ref.watch(currentCategoryProvider);

  if (currentCatIndex >= categories.length) return 0.0;
  final currentCat = categories[currentCatIndex];

  return ref.watch(rankByCategoryProvider(currentCat.id));
}

@riverpod
String rankLabel(Ref ref) {
  final categories = ref.watch(availableCategoriesProvider);
  final currentCatIndex = ref.watch(currentCategoryProvider);

  if (currentCatIndex >= categories.length) return "C";
  final currentCat = categories[currentCatIndex];

  return ref.watch(rankLabelByCategoryProvider(currentCat.id));
}

