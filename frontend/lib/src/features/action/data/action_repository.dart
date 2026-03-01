import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/networking/dio_provider.dart';
import '../domain/action.dart';

part 'action_repository.g.dart';

@riverpod
ActionRepository actionRepository(Ref ref) {
  return ActionRepository(dio: ref.watch(dioProvider));
}

class ActionRepository {
  final Dio _dio;

  ActionRepository({required Dio dio}) : _dio = dio;

  Future<List<Action>> getUserActions({int skip = 0, int limit = 50}) async {
    try {
      final response = await _dio.get(
        '/api/v1/actions/',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Action.fromJson(json)).toList();
    } catch (e, stack) {
      print("ERROR in getUserActions: $e");
      print(stack);
      rethrow;
    }
  }

  Future<List<Action>> getPortfolio() async {
    try {
      final response = await _dio.get('/api/v1/actions/portfolio');
      final List<dynamic> data = response.data;
      return data.map((json) => Action.fromJson(json)).toList();
    } catch (e, stack) {
      print("ERROR in getPortfolio: $e");
      print(stack);
      rethrow;
    }
  }

  Future<Action> createAction(ActionCreate action) async {
    try {
      final response = await _dio.post('/api/v1/actions/', data: action.toJson());
      return Action.fromJson(response.data);
    } catch (e, stack) {
      print("ERROR in createAction: $e");
      print(stack);
      rethrow;
    }
  }

  Future<Action> updateAction(String actionId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/api/v1/actions/$actionId', data: data);
      return Action.fromJson(response.data);
    } catch (e, stack) {
      print("ERROR in updateAction: $e");
      print(stack);
      rethrow;
    }
  }

  Future<void> deleteAction(String actionId) async {
    try {
      await _dio.delete('/api/v1/actions/$actionId');
    } catch (e, stack) {
      print("ERROR in deleteAction: $e");
      print(stack);
      rethrow;
    }
  }
}
