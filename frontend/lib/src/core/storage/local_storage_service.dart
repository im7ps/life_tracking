import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/dashboard/presentation/dashboard_models.dart';

part 'local_storage_service.g.dart';

@riverpod
LocalStorageService localStorageService(Ref ref) {
  return LocalStorageService();
}

class LocalStorageService {
  static const String _tasksKey = 'day0_tasks_v1';
  static const String _categoryOrderKey = 'day0_category_order_v1';

  Future<List<TaskUIModel>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_tasksKey);

    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => TaskUIModel.fromJson(json)).toList();
    } catch (e) {
      print("Error loading local tasks: $e");
      return [];
    }
  }

  Future<void> saveTasks(List<TaskUIModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_tasksKey, jsonString);
  }

  Future<List<String>> loadCategoryOrder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_categoryOrderKey) ?? [];
  }

  Future<void> saveCategoryOrder(List<String> order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_categoryOrderKey, order);
  }

  Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
  }

  Future<String?> loadServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('server_url');
  }

  Future<void> saveServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', url);
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}
