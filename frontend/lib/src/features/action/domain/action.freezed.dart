// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'action.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Action _$ActionFromJson(Map<String, dynamic> json) {
  return _Action.fromJson(json);
}

/// @nodoc
mixin _$Action {
  String get id => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  int get difficulty => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  int get fulfillmentScore => throw _privateConstructorUsedError;
  int? get durationMinutes => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get dimensionId => throw _privateConstructorUsedError;
  int get completionCount => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get subTasks => throw _privateConstructorUsedError;
  bool get isRecurring => throw _privateConstructorUsedError;
  Dimension? get dimension => throw _privateConstructorUsedError;

  /// Serializes this Action to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Action
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActionCopyWith<Action> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActionCopyWith<$Res> {
  factory $ActionCopyWith(Action value, $Res Function(Action) then) =
      _$ActionCopyWithImpl<$Res, Action>;
  @useResult
  $Res call({
    String id,
    DateTime startTime,
    DateTime? endTime,
    String? description,
    String category,
    int difficulty,
    String status,
    String icon,
    int fulfillmentScore,
    int? durationMinutes,
    String userId,
    String dimensionId,
    int completionCount,
    List<Map<String, dynamic>> subTasks,
    bool isRecurring,
    Dimension? dimension,
  });

  $DimensionCopyWith<$Res>? get dimension;
}

/// @nodoc
class _$ActionCopyWithImpl<$Res, $Val extends Action>
    implements $ActionCopyWith<$Res> {
  _$ActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Action
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? description = freezed,
    Object? category = null,
    Object? difficulty = null,
    Object? status = null,
    Object? icon = null,
    Object? fulfillmentScore = null,
    Object? durationMinutes = freezed,
    Object? userId = null,
    Object? dimensionId = null,
    Object? completionCount = null,
    Object? subTasks = null,
    Object? isRecurring = null,
    Object? dimension = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: freezed == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            fulfillmentScore: null == fulfillmentScore
                ? _value.fulfillmentScore
                : fulfillmentScore // ignore: cast_nullable_to_non_nullable
                      as int,
            durationMinutes: freezed == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            dimensionId: null == dimensionId
                ? _value.dimensionId
                : dimensionId // ignore: cast_nullable_to_non_nullable
                      as String,
            completionCount: null == completionCount
                ? _value.completionCount
                : completionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            subTasks: null == subTasks
                ? _value.subTasks
                : subTasks // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            isRecurring: null == isRecurring
                ? _value.isRecurring
                : isRecurring // ignore: cast_nullable_to_non_nullable
                      as bool,
            dimension: freezed == dimension
                ? _value.dimension
                : dimension // ignore: cast_nullable_to_non_nullable
                      as Dimension?,
          )
          as $Val,
    );
  }

  /// Create a copy of Action
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DimensionCopyWith<$Res>? get dimension {
    if (_value.dimension == null) {
      return null;
    }

    return $DimensionCopyWith<$Res>(_value.dimension!, (value) {
      return _then(_value.copyWith(dimension: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ActionImplCopyWith<$Res> implements $ActionCopyWith<$Res> {
  factory _$$ActionImplCopyWith(
    _$ActionImpl value,
    $Res Function(_$ActionImpl) then,
  ) = __$$ActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime startTime,
    DateTime? endTime,
    String? description,
    String category,
    int difficulty,
    String status,
    String icon,
    int fulfillmentScore,
    int? durationMinutes,
    String userId,
    String dimensionId,
    int completionCount,
    List<Map<String, dynamic>> subTasks,
    bool isRecurring,
    Dimension? dimension,
  });

  @override
  $DimensionCopyWith<$Res>? get dimension;
}

/// @nodoc
class __$$ActionImplCopyWithImpl<$Res>
    extends _$ActionCopyWithImpl<$Res, _$ActionImpl>
    implements _$$ActionImplCopyWith<$Res> {
  __$$ActionImplCopyWithImpl(
    _$ActionImpl _value,
    $Res Function(_$ActionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Action
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? description = freezed,
    Object? category = null,
    Object? difficulty = null,
    Object? status = null,
    Object? icon = null,
    Object? fulfillmentScore = null,
    Object? durationMinutes = freezed,
    Object? userId = null,
    Object? dimensionId = null,
    Object? completionCount = null,
    Object? subTasks = null,
    Object? isRecurring = null,
    Object? dimension = freezed,
  }) {
    return _then(
      _$ActionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: freezed == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        fulfillmentScore: null == fulfillmentScore
            ? _value.fulfillmentScore
            : fulfillmentScore // ignore: cast_nullable_to_non_nullable
                  as int,
        durationMinutes: freezed == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        dimensionId: null == dimensionId
            ? _value.dimensionId
            : dimensionId // ignore: cast_nullable_to_non_nullable
                  as String,
        completionCount: null == completionCount
            ? _value.completionCount
            : completionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        subTasks: null == subTasks
            ? _value._subTasks
            : subTasks // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        isRecurring: null == isRecurring
            ? _value.isRecurring
            : isRecurring // ignore: cast_nullable_to_non_nullable
                  as bool,
        dimension: freezed == dimension
            ? _value.dimension
            : dimension // ignore: cast_nullable_to_non_nullable
                  as Dimension?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActionImpl implements _Action {
  const _$ActionImpl({
    required this.id,
    required this.startTime,
    this.endTime,
    this.description,
    this.category = "Dovere",
    this.difficulty = 3,
    this.status = "COMPLETED",
    this.icon = "briefcase",
    required this.fulfillmentScore,
    this.durationMinutes,
    required this.userId,
    required this.dimensionId,
    this.completionCount = 0,
    final List<Map<String, dynamic>> subTasks = const [],
    this.isRecurring = false,
    this.dimension,
  }) : _subTasks = subTasks;

  factory _$ActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActionImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;
  @override
  final String? description;
  @override
  @JsonKey()
  final String category;
  @override
  @JsonKey()
  final int difficulty;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final String icon;
  @override
  final int fulfillmentScore;
  @override
  final int? durationMinutes;
  @override
  final String userId;
  @override
  final String dimensionId;
  @override
  @JsonKey()
  final int completionCount;
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
  final Dimension? dimension;

  @override
  String toString() {
    return 'Action(id: $id, startTime: $startTime, endTime: $endTime, description: $description, category: $category, difficulty: $difficulty, status: $status, icon: $icon, fulfillmentScore: $fulfillmentScore, durationMinutes: $durationMinutes, userId: $userId, dimensionId: $dimensionId, completionCount: $completionCount, subTasks: $subTasks, isRecurring: $isRecurring, dimension: $dimension)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.fulfillmentScore, fulfillmentScore) ||
                other.fulfillmentScore == fulfillmentScore) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.dimensionId, dimensionId) ||
                other.dimensionId == dimensionId) &&
            (identical(other.completionCount, completionCount) ||
                other.completionCount == completionCount) &&
            const DeepCollectionEquality().equals(other._subTasks, _subTasks) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            (identical(other.dimension, dimension) ||
                other.dimension == dimension));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    startTime,
    endTime,
    description,
    category,
    difficulty,
    status,
    icon,
    fulfillmentScore,
    durationMinutes,
    userId,
    dimensionId,
    completionCount,
    const DeepCollectionEquality().hash(_subTasks),
    isRecurring,
    dimension,
  );

  /// Create a copy of Action
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActionImplCopyWith<_$ActionImpl> get copyWith =>
      __$$ActionImplCopyWithImpl<_$ActionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActionImplToJson(this);
  }
}

abstract class _Action implements Action {
  const factory _Action({
    required final String id,
    required final DateTime startTime,
    final DateTime? endTime,
    final String? description,
    final String category,
    final int difficulty,
    final String status,
    final String icon,
    required final int fulfillmentScore,
    final int? durationMinutes,
    required final String userId,
    required final String dimensionId,
    final int completionCount,
    final List<Map<String, dynamic>> subTasks,
    final bool isRecurring,
    final Dimension? dimension,
  }) = _$ActionImpl;

  factory _Action.fromJson(Map<String, dynamic> json) = _$ActionImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;
  @override
  String? get description;
  @override
  String get category;
  @override
  int get difficulty;
  @override
  String get status;
  @override
  String get icon;
  @override
  int get fulfillmentScore;
  @override
  int? get durationMinutes;
  @override
  String get userId;
  @override
  String get dimensionId;
  @override
  int get completionCount;
  @override
  List<Map<String, dynamic>> get subTasks;
  @override
  bool get isRecurring;
  @override
  Dimension? get dimension;

  /// Create a copy of Action
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActionImplCopyWith<_$ActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActionCreate _$ActionCreateFromJson(Map<String, dynamic> json) {
  return _ActionCreate.fromJson(json);
}

/// @nodoc
mixin _$ActionCreate {
  String? get description => throw _privateConstructorUsedError;
  DateTime? get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  String get dimensionId => throw _privateConstructorUsedError;
  int get fulfillmentScore => throw _privateConstructorUsedError;
  int? get durationMinutes => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  int get difficulty => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get subTasks => throw _privateConstructorUsedError;
  bool get isRecurring => throw _privateConstructorUsedError;

  /// Serializes this ActionCreate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActionCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActionCreateCopyWith<ActionCreate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActionCreateCopyWith<$Res> {
  factory $ActionCreateCopyWith(
    ActionCreate value,
    $Res Function(ActionCreate) then,
  ) = _$ActionCreateCopyWithImpl<$Res, ActionCreate>;
  @useResult
  $Res call({
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String dimensionId,
    int fulfillmentScore,
    int? durationMinutes,
    String category,
    int difficulty,
    String status,
    String icon,
    List<Map<String, dynamic>> subTasks,
    bool isRecurring,
  });
}

/// @nodoc
class _$ActionCreateCopyWithImpl<$Res, $Val extends ActionCreate>
    implements $ActionCreateCopyWith<$Res> {
  _$ActionCreateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActionCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? dimensionId = null,
    Object? fulfillmentScore = null,
    Object? durationMinutes = freezed,
    Object? category = null,
    Object? difficulty = null,
    Object? status = null,
    Object? icon = null,
    Object? subTasks = null,
    Object? isRecurring = null,
  }) {
    return _then(
      _value.copyWith(
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            startTime: freezed == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endTime: freezed == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            dimensionId: null == dimensionId
                ? _value.dimensionId
                : dimensionId // ignore: cast_nullable_to_non_nullable
                      as String,
            fulfillmentScore: null == fulfillmentScore
                ? _value.fulfillmentScore
                : fulfillmentScore // ignore: cast_nullable_to_non_nullable
                      as int,
            durationMinutes: freezed == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            subTasks: null == subTasks
                ? _value.subTasks
                : subTasks // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            isRecurring: null == isRecurring
                ? _value.isRecurring
                : isRecurring // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActionCreateImplCopyWith<$Res>
    implements $ActionCreateCopyWith<$Res> {
  factory _$$ActionCreateImplCopyWith(
    _$ActionCreateImpl value,
    $Res Function(_$ActionCreateImpl) then,
  ) = __$$ActionCreateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String dimensionId,
    int fulfillmentScore,
    int? durationMinutes,
    String category,
    int difficulty,
    String status,
    String icon,
    List<Map<String, dynamic>> subTasks,
    bool isRecurring,
  });
}

/// @nodoc
class __$$ActionCreateImplCopyWithImpl<$Res>
    extends _$ActionCreateCopyWithImpl<$Res, _$ActionCreateImpl>
    implements _$$ActionCreateImplCopyWith<$Res> {
  __$$ActionCreateImplCopyWithImpl(
    _$ActionCreateImpl _value,
    $Res Function(_$ActionCreateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActionCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? dimensionId = null,
    Object? fulfillmentScore = null,
    Object? durationMinutes = freezed,
    Object? category = null,
    Object? difficulty = null,
    Object? status = null,
    Object? icon = null,
    Object? subTasks = null,
    Object? isRecurring = null,
  }) {
    return _then(
      _$ActionCreateImpl(
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        startTime: freezed == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endTime: freezed == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dimensionId: null == dimensionId
            ? _value.dimensionId
            : dimensionId // ignore: cast_nullable_to_non_nullable
                  as String,
        fulfillmentScore: null == fulfillmentScore
            ? _value.fulfillmentScore
            : fulfillmentScore // ignore: cast_nullable_to_non_nullable
                  as int,
        durationMinutes: freezed == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        subTasks: null == subTasks
            ? _value._subTasks
            : subTasks // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        isRecurring: null == isRecurring
            ? _value.isRecurring
            : isRecurring // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActionCreateImpl implements _ActionCreate {
  const _$ActionCreateImpl({
    this.description,
    this.startTime,
    this.endTime,
    required this.dimensionId,
    required this.fulfillmentScore,
    this.durationMinutes,
    this.category = "Dovere",
    this.difficulty = 3,
    this.status = "COMPLETED",
    this.icon = "briefcase",
    final List<Map<String, dynamic>> subTasks = const [],
    this.isRecurring = false,
  }) : _subTasks = subTasks;

  factory _$ActionCreateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActionCreateImplFromJson(json);

  @override
  final String? description;
  @override
  final DateTime? startTime;
  @override
  final DateTime? endTime;
  @override
  final String dimensionId;
  @override
  final int fulfillmentScore;
  @override
  final int? durationMinutes;
  @override
  @JsonKey()
  final String category;
  @override
  @JsonKey()
  final int difficulty;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final String icon;
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
  String toString() {
    return 'ActionCreate(description: $description, startTime: $startTime, endTime: $endTime, dimensionId: $dimensionId, fulfillmentScore: $fulfillmentScore, durationMinutes: $durationMinutes, category: $category, difficulty: $difficulty, status: $status, icon: $icon, subTasks: $subTasks, isRecurring: $isRecurring)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActionCreateImpl &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.dimensionId, dimensionId) ||
                other.dimensionId == dimensionId) &&
            (identical(other.fulfillmentScore, fulfillmentScore) ||
                other.fulfillmentScore == fulfillmentScore) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            const DeepCollectionEquality().equals(other._subTasks, _subTasks) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    description,
    startTime,
    endTime,
    dimensionId,
    fulfillmentScore,
    durationMinutes,
    category,
    difficulty,
    status,
    icon,
    const DeepCollectionEquality().hash(_subTasks),
    isRecurring,
  );

  /// Create a copy of ActionCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActionCreateImplCopyWith<_$ActionCreateImpl> get copyWith =>
      __$$ActionCreateImplCopyWithImpl<_$ActionCreateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActionCreateImplToJson(this);
  }
}

abstract class _ActionCreate implements ActionCreate {
  const factory _ActionCreate({
    final String? description,
    final DateTime? startTime,
    final DateTime? endTime,
    required final String dimensionId,
    required final int fulfillmentScore,
    final int? durationMinutes,
    final String category,
    final int difficulty,
    final String status,
    final String icon,
    final List<Map<String, dynamic>> subTasks,
    final bool isRecurring,
  }) = _$ActionCreateImpl;

  factory _ActionCreate.fromJson(Map<String, dynamic> json) =
      _$ActionCreateImpl.fromJson;

  @override
  String? get description;
  @override
  DateTime? get startTime;
  @override
  DateTime? get endTime;
  @override
  String get dimensionId;
  @override
  int get fulfillmentScore;
  @override
  int? get durationMinutes;
  @override
  String get category;
  @override
  int get difficulty;
  @override
  String get status;
  @override
  String get icon;
  @override
  List<Map<String, dynamic>> get subTasks;
  @override
  bool get isRecurring;

  /// Create a copy of ActionCreate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActionCreateImplCopyWith<_$ActionCreateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
