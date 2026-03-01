import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../data/action_repository.dart';
import '../domain/action.dart' as domain_action;

part 'action_providers.g.dart';

@riverpod
Future<List<domain_action.Action>> actionList(Ref ref) async {
  final repo = ref.watch(actionRepositoryProvider);
  return await repo.getUserActions();
}

@riverpod
class Portfolio extends _$Portfolio {
  @override
  Future<List<TaskUIModel>> build() async {
    final repo = ref.watch(actionRepositoryProvider);
    final domainActions = await repo.getPortfolio();

    debugPrint(
      "DEBUG: PortfolioProvider - Fetched ${domainActions.length} actions from backend",
    );

    return domainActions.map((action) {
      return TaskUIModel.fromActionJson({
        'id': action.id,
        'description': action.description,
        'category': action.category,
        'difficulty': action.difficulty,
        'fulfillment_score': action.fulfillmentScore,
        'status': action.status,
        'duration_minutes': action.durationMinutes,
      });
    }).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> removeTask(String actionId) async {
    final repo = ref.read(actionRepositoryProvider);
    final currentPortfolio = state.valueOrNull ?? [];
    final taskToDelete = currentPortfolio.firstWhere((t) => t.id == actionId);

    // 1. Delete from Backend
    await repo.deleteAction(actionId);

    // 2. Delete from local TaskList (Dashboard) if present
    await ref
        .read(taskListProvider.notifier)
        .removeTaskByTitle(taskToDelete.title);

    ref.invalidateSelf();
  }
}

@riverpod
class ActionCreateController extends _$ActionCreateController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<domain_action.Action?> createAction({
    required String dimensionId,
    required int fulfillmentScore,
    String? description,
    DateTime? startTime,
  }) async {
    final repo = ref.read(actionRepositoryProvider);
    state = const AsyncValue.loading();

    final actionIn = domain_action.ActionCreate(
      dimensionId: dimensionId,
      fulfillmentScore: fulfillmentScore,
      description: description,
      startTime: startTime,
    );

    final result = await AsyncValue.guard(() => repo.createAction(actionIn));
    state = result;

    if (!state.hasError && result.value != null) {
      ref.invalidate(actionListProvider);
      ref.invalidate(portfolioProvider);
      return result.value;
    }
    return null;
  }
}

// Keep legacy provider for compatibility if needed, but mark as deprecated or empty
final allTasksProvider = StateProvider<List<TaskUIModel>>((ref) => []);
