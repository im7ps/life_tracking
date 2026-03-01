// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskUIModelImpl _$$TaskUIModelImplFromJson(Map<String, dynamic> json) =>
    _$TaskUIModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: const IconDataConverter().fromJson(
        json['icon'] as Map<String, dynamic>,
      ),
      color: const ColorConverter().fromJson((json['color'] as num).toInt()),
      isCompleted: json['is_completed'] as bool? ?? false,
      status: json['status'] as String? ?? "COMPLETED",
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      difficulty: (json['difficulty'] as num).toInt(),
      satisfaction: (json['satisfaction'] as num).toInt(),
      completionCount: (json['completion_count'] as num?)?.toInt() ?? 0,
      category: json['category'] as String,
      isRunning: json['is_running'] as bool? ?? false,
      totalSeconds: (json['total_seconds'] as num?)?.toInt() ?? 0,
      subTasks:
          (json['sub_tasks'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      isRecurring: json['is_recurring'] as bool? ?? false,
      lastStartedAt: json['last_started_at'] == null
          ? null
          : DateTime.parse(json['last_started_at'] as String),
      scheduledDate: json['scheduled_date'] == null
          ? null
          : DateTime.parse(json['scheduled_date'] as String),
    );

Map<String, dynamic> _$$TaskUIModelImplToJson(_$TaskUIModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'icon': const IconDataConverter().toJson(instance.icon),
      'color': const ColorConverter().toJson(instance.color),
      'is_completed': instance.isCompleted,
      'status': instance.status,
      'duration_minutes': instance.durationMinutes,
      'difficulty': instance.difficulty,
      'satisfaction': instance.satisfaction,
      'completion_count': instance.completionCount,
      'category': instance.category,
      'is_running': instance.isRunning,
      'total_seconds': instance.totalSeconds,
      'sub_tasks': instance.subTasks,
      'is_recurring': instance.isRecurring,
      'last_started_at': instance.lastStartedAt?.toIso8601String(),
      'scheduled_date': instance.scheduledDate?.toIso8601String(),
    };
