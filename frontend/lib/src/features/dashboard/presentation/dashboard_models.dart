import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

part 'dashboard_models.freezed.dart';
part 'dashboard_models.g.dart';

enum TaskSortOrder { recommended, effort, satisfaction }

class CategoryInfo {
  final String id; // The category name in lowercase or 'general'
  final String label;
  final IconData icon;
  final Color color;

  const CategoryInfo({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

@freezed
class TaskUIModel with _$TaskUIModel {
  const factory TaskUIModel({
    required String id,
    required String title,
    @IconDataConverter() required IconData icon,
    @ColorConverter() required Color color,
    @Default(false) bool isCompleted,
    @Default("COMPLETED") String status,
    int? durationMinutes,
    required int difficulty,
    required int satisfaction,
    @Default(0) int completionCount,
    required String category,
    @Default(false) bool isRunning,
    @Default(0) int totalSeconds,
    @Default([]) List<Map<String, dynamic>> subTasks,
    @Default(false) bool isRecurring,
    DateTime? lastStartedAt,
    DateTime? scheduledDate,
  }) = _TaskUIModel;

  factory TaskUIModel.fromJson(Map<String, dynamic> json) =>
      _$TaskUIModelFromJson(json);

  /// Creates a TaskUIModel from backend Action JSON, mapping category to icon/color
  factory TaskUIModel.fromActionJson(Map<String, dynamic> json) {
    final category = json['category'] as String? ?? 'Dovere';
    final status = json['status'] as String? ?? 'COMPLETED';

    IconData icon;
    Color color;

    switch (category.toLowerCase()) {
      case 'passione':
        icon = FontAwesomeIcons.guitar;
        color = Colors.green;
        break;
      case 'energia':
        icon = FontAwesomeIcons.bolt;
        color = Colors.orange;
        break;
      case 'relazioni':
        icon = FontAwesomeIcons.peopleGroup;
        color = Colors.blue;
        break;
      case 'anima':
        icon = FontAwesomeIcons.heart;
        color = Colors.pink;
        break;
      case 'dovere':
      default:
        icon = FontAwesomeIcons.briefcase;
        color = Colors.red;
    }

    return TaskUIModel(
      id: json['id'] as String,
      title: json['description'] as String? ?? 'Senza Titolo',
      icon: icon,
      color: color.withValues(alpha: 1.0), // Force opaque to fix corrupted data
      difficulty: json['difficulty'] as int? ?? 3,
      satisfaction: json['fulfillment_score'] as int? ?? 3,
      category: category,
      status: status,
      isCompleted: status == 'COMPLETED',
      completionCount: json['completion_count'] as int? ?? 0,
      durationMinutes: json['duration_minutes'] as int?,
      isRunning: json['is_running'] as bool? ?? false,
      totalSeconds: json['total_seconds'] as int? ?? 0,
      subTasks: (json['sub_tasks'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      isRecurring: json['is_recurring'] as bool? ?? false,
      lastStartedAt: json['last_started_at'] != null 
          ? DateTime.parse(json['last_started_at'] as String) 
          : null,
      scheduledDate: json['scheduled_date'] != null 
          ? DateTime.parse(json['scheduled_date'] as String) 
          : null,
    );
  }
}

class IconDataConverter
    implements JsonConverter<IconData, Map<String, dynamic>> {
  const IconDataConverter();

  @override
  IconData fromJson(Map<String, dynamic> json) {
    return IconData(
      json['iconCode'] as int,
      fontFamily: json['iconFamily'] as String?,
      fontPackage: json['iconPackage'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson(IconData icon) {
    return {
      'iconCode': icon.codePoint,
      'iconFamily': icon.fontFamily,
      'iconPackage': icon.fontPackage,
    };
  }
}

class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color color) => color.toARGB32();
}
