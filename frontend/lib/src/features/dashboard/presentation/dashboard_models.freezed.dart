// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TaskUIModel _$TaskUIModelFromJson(Map<String, dynamic> json) {
  return _TaskUIModel.fromJson(json);
}

/// @nodoc
mixin _$TaskUIModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @IconDataConverter()
  IconData get icon => throw _privateConstructorUsedError;
  @ColorConverter()
  Color get color => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int? get durationMinutes => throw _privateConstructorUsedError;
  int get difficulty => throw _privateConstructorUsedError;
  int get satisfaction => throw _privateConstructorUsedError;
  int get completionCount => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  bool get isRunning => throw _privateConstructorUsedError;
  int get totalSeconds => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get subTasks => throw _privateConstructorUsedError;
  bool get isRecurring => throw _privateConstructorUsedError;
  DateTime? get lastStartedAt => throw _privateConstructorUsedError;
  DateTime? get scheduledDate => throw _privateConstructorUsedError;

  /// Serializes this TaskUIModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskUIModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskUIModelCopyWith<TaskUIModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskUIModelCopyWith<$Res> {
  factory $TaskUIModelCopyWith(
    TaskUIModel value,
    $Res Function(TaskUIModel) then,
  ) = _$TaskUIModelCopyWithImpl<$Res, TaskUIModel>;
  @useResult
  $Res call({
    String id,
    String title,
    @IconDataConverter() IconData icon,
    @ColorConverter() Color color,
    bool isCompleted,
    String status,
    int? durationMinutes,
    int difficulty,
    int satisfaction,
    int completionCount,
    String category,
    bool isRunning,
    int totalSeconds,
    List<Map<String, dynamic>> subTasks,
    bool isRecurring,
    DateTime? lastStartedAt,
    DateTime? scheduledDate,
  });
}

/// @nodoc
class _$TaskUIModelCopyWithImpl<$Res, $Val extends TaskUIModel>
    implements $TaskUIModelCopyWith<$Res> {
  _$TaskUIModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskUIModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? icon = null,
    Object? color = null,
    Object? isCompleted = null,
    Object? status = null,
    Object? durationMinutes = freezed,
    Object? difficulty = null,
    Object? satisfaction = null,
    Object? completionCount = null,
    Object? category = null,
    Object? isRunning = null,
    Object? totalSeconds = null,
    Object? subTasks = null,
    Object? isRecurring = null,
    Object? lastStartedAt = freezed,
    Object? scheduledDate = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as IconData,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as Color,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            durationMinutes: freezed == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as int,
            satisfaction: null == satisfaction
                ? _value.satisfaction
                : satisfaction // ignore: cast_nullable_to_non_nullable
                      as int,
            completionCount: null == completionCount
                ? _value.completionCount
                : completionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            isRunning: null == isRunning
                ? _value.isRunning
                : isRunning // ignore: cast_nullable_to_non_nullable
                      as bool,
            totalSeconds: null == totalSeconds
                ? _value.totalSeconds
                : totalSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            subTasks: null == subTasks
                ? _value.subTasks
                : subTasks // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            isRecurring: null == isRecurring
                ? _value.isRecurring
                : isRecurring // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastStartedAt: freezed == lastStartedAt
                ? _value.lastStartedAt
                : lastStartedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            scheduledDate: freezed == scheduledDate
                ? _value.scheduledDate
                : scheduledDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TaskUIModelImplCopyWith<$Res>
    implements $TaskUIModelCopyWith<$Res> {
  factory _$$TaskUIModelImplCopyWith(
    _$TaskUIModelImpl value,
    $Res Function(_$TaskUIModelImpl) then,
  ) = __$$TaskUIModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    @IconDataConverter() IconData icon,
    @ColorConverter() Color color,
    bool isCompleted,
    String status,
    int? durationMinutes,
    int difficulty,
    int satisfaction,
    int completionCount,
    String category,
    bool isRunning,
    int totalSeconds,
    List<Map<String, dynamic>> subTasks,
    bool isRecurring,
    DateTime? lastStartedAt,
    DateTime? scheduledDate,
  });
}

/// @nodoc
class __$$TaskUIModelImplCopyWithImpl<$Res>
    extends _$TaskUIModelCopyWithImpl<$Res, _$TaskUIModelImpl>
    implements _$$TaskUIModelImplCopyWith<$Res> {
  __$$TaskUIModelImplCopyWithImpl(
    _$TaskUIModelImpl _value,
    $Res Function(_$TaskUIModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaskUIModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? icon = null,
    Object? color = null,
    Object? isCompleted = null,
    Object? status = null,
    Object? durationMinutes = freezed,
    Object? difficulty = null,
    Object? satisfaction = null,
    Object? completionCount = null,
    Object? category = null,
    Object? isRunning = null,
    Object? totalSeconds = null,
    Object? subTasks = null,
    Object? isRecurring = null,
    Object? lastStartedAt = freezed,
    Object? scheduledDate = freezed,
  }) {
    return _then(
      _$TaskUIModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as IconData,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as Color,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        durationMinutes: freezed == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as int,
        satisfaction: null == satisfaction
            ? _value.satisfaction
            : satisfaction // ignore: cast_nullable_to_non_nullable
                  as int,
        completionCount: null == completionCount
            ? _value.completionCount
            : completionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        isRunning: null == isRunning
            ? _value.isRunning
            : isRunning // ignore: cast_nullable_to_non_nullable
                  as bool,
        totalSeconds: null == totalSeconds
            ? _value.totalSeconds
            : totalSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        subTasks: null == subTasks
            ? _value._subTasks
            : subTasks // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        isRecurring: null == isRecurring
            ? _value.isRecurring
            : isRecurring // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastStartedAt: freezed == lastStartedAt
            ? _value.lastStartedAt
            : lastStartedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        scheduledDate: freezed == scheduledDate
            ? _value.scheduledDate
            : scheduledDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskUIModelImpl implements _TaskUIModel {
  const _$TaskUIModelImpl({
    required this.id,
    required this.title,
    @IconDataConverter() required this.icon,
    @ColorConverter() required this.color,
    this.isCompleted = false,
    this.status = "COMPLETED",
    this.durationMinutes,
    required this.difficulty,
    required this.satisfaction,
    this.completionCount = 0,
    required this.category,
    this.isRunning = false,
    this.totalSeconds = 0,
    final List<Map<String, dynamic>> subTasks = const [],
    this.isRecurring = false,
    this.lastStartedAt,
    this.scheduledDate,
  }) : _subTasks = subTasks;

  factory _$TaskUIModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskUIModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  @IconDataConverter()
  final IconData icon;
  @override
  @ColorConverter()
  final Color color;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  @JsonKey()
  final String status;
  @override
  final int? durationMinutes;
  @override
  final int difficulty;
  @override
  final int satisfaction;
  @override
  @JsonKey()
  final int completionCount;
  @override
  final String category;
  @override
  @JsonKey()
  final bool isRunning;
  @override
  @JsonKey()
  final int totalSeconds;
  final List<Map<String, dynamic>> _subTasks;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get subTasks {
    if (_subTasks is EqualUnmodifiableListView) return _subTasks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subTasks);
  }

  @override
  @JsonKey()
  final bool isRecurring;
  @override
  final DateTime? lastStartedAt;
  @override
  final DateTime? scheduledDate;

  @override
  String toString() {
    return 'TaskUIModel(id: $id, title: $title, icon: $icon, color: $color, isCompleted: $isCompleted, status: $status, durationMinutes: $durationMinutes, difficulty: $difficulty, satisfaction: $satisfaction, completionCount: $completionCount, category: $category, isRunning: $isRunning, totalSeconds: $totalSeconds, subTasks: $subTasks, isRecurring: $isRecurring, lastStartedAt: $lastStartedAt, scheduledDate: $scheduledDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskUIModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.satisfaction, satisfaction) ||
                other.satisfaction == satisfaction) &&
            (identical(other.completionCount, completionCount) ||
                other.completionCount == completionCount) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.isRunning, isRunning) ||
                other.isRunning == isRunning) &&
            (identical(other.totalSeconds, totalSeconds) ||
                other.totalSeconds == totalSeconds) &&
            const DeepCollectionEquality().equals(other._subTasks, _subTasks) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            (identical(other.lastStartedAt, lastStartedAt) ||
                other.lastStartedAt == lastStartedAt) &&
            (identical(other.scheduledDate, scheduledDate) ||
                other.scheduledDate == scheduledDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    icon,
    color,
    isCompleted,
    status,
    durationMinutes,
    difficulty,
    satisfaction,
    completionCount,
    category,
    isRunning,
    totalSeconds,
    const DeepCollectionEquality().hash(_subTasks),
    isRecurring,
    lastStartedAt,
    scheduledDate,
  );

  /// Create a copy of TaskUIModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskUIModelImplCopyWith<_$TaskUIModelImpl> get copyWith =>
      __$$TaskUIModelImplCopyWithImpl<_$TaskUIModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskUIModelImplToJson(this);
  }
}

abstract class _TaskUIModel implements TaskUIModel {
  const factory _TaskUIModel({
    required final String id,
    required final String title,
    @IconDataConverter() required final IconData icon,
    @ColorConverter() required final Color color,
    final bool isCompleted,
    final String status,
    final int? durationMinutes,
    required final int difficulty,
    required final int satisfaction,
    final int completionCount,
    required final String category,
    final bool isRunning,
    final int totalSeconds,
    final List<Map<String, dynamic>> subTasks,
    final bool isRecurring,
    final DateTime? lastStartedAt,
    final DateTime? scheduledDate,
  }) = _$TaskUIModelImpl;

  factory _TaskUIModel.fromJson(Map<String, dynamic> json) =
      _$TaskUIModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  @IconDataConverter()
  IconData get icon;
  @override
  @ColorConverter()
  Color get color;
  @override
  bool get isCompleted;
  @override
  String get status;
  @override
  int? get durationMinutes;
  @override
  int get difficulty;
  @override
  int get satisfaction;
  @override
  int get completionCount;
  @override
  String get category;
  @override
  bool get isRunning;
  @override
  int get totalSeconds;
  @override
  List<Map<String, dynamic>> get subTasks;
  @override
  bool get isRecurring;
  @override
  DateTime? get lastStartedAt;
  @override
  DateTime? get scheduledDate;

  /// Create a copy of TaskUIModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskUIModelImplCopyWith<_$TaskUIModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
