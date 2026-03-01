// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActionImpl _$$ActionImplFromJson(Map<String, dynamic> json) => _$ActionImpl(
  id: json['id'] as String,
  startTime: DateTime.parse(json['start_time'] as String),
  endTime: json['end_time'] == null
      ? null
      : DateTime.parse(json['end_time'] as String),
  description: json['description'] as String?,
  category: json['category'] as String? ?? "Dovere",
  difficulty: (json['difficulty'] as num?)?.toInt() ?? 3,
  status: json['status'] as String? ?? "COMPLETED",
  icon: json['icon'] as String? ?? "briefcase",
  fulfillmentScore: (json['fulfillment_score'] as num).toInt(),
  durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
  userId: json['user_id'] as String,
  dimensionId: json['dimension_id'] as String,
  completionCount: (json['completion_count'] as num?)?.toInt() ?? 0,
  subTasks:
      (json['sub_tasks'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  isRecurring: json['is_recurring'] as bool? ?? false,
  dimension: json['dimension'] == null
      ? null
      : Dimension.fromJson(json['dimension'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$ActionImplToJson(_$ActionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
      'description': instance.description,
      'category': instance.category,
      'difficulty': instance.difficulty,
      'status': instance.status,
      'icon': instance.icon,
      'fulfillment_score': instance.fulfillmentScore,
      'duration_minutes': instance.durationMinutes,
      'user_id': instance.userId,
      'dimension_id': instance.dimensionId,
      'completion_count': instance.completionCount,
      'sub_tasks': instance.subTasks,
      'is_recurring': instance.isRecurring,
      'dimension': instance.dimension?.toJson(),
    };

_$ActionCreateImpl _$$ActionCreateImplFromJson(Map<String, dynamic> json) =>
    _$ActionCreateImpl(
      description: json['description'] as String?,
      startTime: json['start_time'] == null
          ? null
          : DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'] as String),
      dimensionId: json['dimension_id'] as String,
      fulfillmentScore: (json['fulfillment_score'] as num).toInt(),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      category: json['category'] as String? ?? "Dovere",
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 3,
      status: json['status'] as String? ?? "COMPLETED",
      icon: json['icon'] as String? ?? "briefcase",
      subTasks:
          (json['sub_tasks'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      isRecurring: json['is_recurring'] as bool? ?? false,
    );

Map<String, dynamic> _$$ActionCreateImplToJson(_$ActionCreateImpl instance) =>
    <String, dynamic>{
      'description': instance.description,
      'start_time': instance.startTime?.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
      'dimension_id': instance.dimensionId,
      'fulfillment_score': instance.fulfillmentScore,
      'duration_minutes': instance.durationMinutes,
      'category': instance.category,
      'difficulty': instance.difficulty,
      'status': instance.status,
      'icon': instance.icon,
      'sub_tasks': instance.subTasks,
      'is_recurring': instance.isRecurring,
    };
