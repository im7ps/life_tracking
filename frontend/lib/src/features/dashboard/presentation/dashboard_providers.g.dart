// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availableCategoriesHash() =>
    r'ac881a8ebffeff4e29f8fee2c2398714a97c2c5d';

/// See also [availableCategories].
@ProviderFor(availableCategories)
final availableCategoriesProvider =
    AutoDisposeProvider<List<CategoryInfo>>.internal(
      availableCategories,
      name: r'availableCategoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$availableCategoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailableCategoriesRef = AutoDisposeProviderRef<List<CategoryInfo>>;
String _$tasksByCategoryHash() => r'cb19c10196cb5f878e86220220227f8aca337bb5';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [tasksByCategory].
@ProviderFor(tasksByCategory)
const tasksByCategoryProvider = TasksByCategoryFamily();

/// See also [tasksByCategory].
class TasksByCategoryFamily extends Family<List<TaskUIModel>> {
  /// See also [tasksByCategory].
  const TasksByCategoryFamily();

  /// See also [tasksByCategory].
  TasksByCategoryProvider call(String categoryId) {
    return TasksByCategoryProvider(categoryId);
  }

  @override
  TasksByCategoryProvider getProviderOverride(
    covariant TasksByCategoryProvider provider,
  ) {
    return call(provider.categoryId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tasksByCategoryProvider';
}

/// See also [tasksByCategory].
class TasksByCategoryProvider extends AutoDisposeProvider<List<TaskUIModel>> {
  /// See also [tasksByCategory].
  TasksByCategoryProvider(String categoryId)
    : this._internal(
        (ref) => tasksByCategory(ref as TasksByCategoryRef, categoryId),
        from: tasksByCategoryProvider,
        name: r'tasksByCategoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tasksByCategoryHash,
        dependencies: TasksByCategoryFamily._dependencies,
        allTransitiveDependencies:
            TasksByCategoryFamily._allTransitiveDependencies,
        categoryId: categoryId,
      );

  TasksByCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final String categoryId;

  @override
  Override overrideWith(
    List<TaskUIModel> Function(TasksByCategoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TasksByCategoryProvider._internal(
        (ref) => create(ref as TasksByCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<TaskUIModel>> createElement() {
    return _TasksByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TasksByCategoryProvider && other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TasksByCategoryRef on AutoDisposeProviderRef<List<TaskUIModel>> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _TasksByCategoryProviderElement
    extends AutoDisposeProviderElement<List<TaskUIModel>>
    with TasksByCategoryRef {
  _TasksByCategoryProviderElement(super.provider);

  @override
  String get categoryId => (origin as TasksByCategoryProvider).categoryId;
}

String _$rankByCategoryHash() => r'cadab95f58e75685d757799a9aca8b3a92378102';

/// See also [rankByCategory].
@ProviderFor(rankByCategory)
const rankByCategoryProvider = RankByCategoryFamily();

/// See also [rankByCategory].
class RankByCategoryFamily extends Family<double> {
  /// See also [rankByCategory].
  const RankByCategoryFamily();

  /// See also [rankByCategory].
  RankByCategoryProvider call(String categoryId) {
    return RankByCategoryProvider(categoryId);
  }

  @override
  RankByCategoryProvider getProviderOverride(
    covariant RankByCategoryProvider provider,
  ) {
    return call(provider.categoryId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'rankByCategoryProvider';
}

/// See also [rankByCategory].
class RankByCategoryProvider extends AutoDisposeProvider<double> {
  /// See also [rankByCategory].
  RankByCategoryProvider(String categoryId)
    : this._internal(
        (ref) => rankByCategory(ref as RankByCategoryRef, categoryId),
        from: rankByCategoryProvider,
        name: r'rankByCategoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$rankByCategoryHash,
        dependencies: RankByCategoryFamily._dependencies,
        allTransitiveDependencies:
            RankByCategoryFamily._allTransitiveDependencies,
        categoryId: categoryId,
      );

  RankByCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final String categoryId;

  @override
  Override overrideWith(double Function(RankByCategoryRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: RankByCategoryProvider._internal(
        (ref) => create(ref as RankByCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<double> createElement() {
    return _RankByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RankByCategoryProvider && other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RankByCategoryRef on AutoDisposeProviderRef<double> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _RankByCategoryProviderElement extends AutoDisposeProviderElement<double>
    with RankByCategoryRef {
  _RankByCategoryProviderElement(super.provider);

  @override
  String get categoryId => (origin as RankByCategoryProvider).categoryId;
}

String _$rankLabelByCategoryHash() =>
    r'd09a09f5e0aebb8fc2b0225f1306963a67aea17e';

/// See also [rankLabelByCategory].
@ProviderFor(rankLabelByCategory)
const rankLabelByCategoryProvider = RankLabelByCategoryFamily();

/// See also [rankLabelByCategory].
class RankLabelByCategoryFamily extends Family<String> {
  /// See also [rankLabelByCategory].
  const RankLabelByCategoryFamily();

  /// See also [rankLabelByCategory].
  RankLabelByCategoryProvider call(String categoryId) {
    return RankLabelByCategoryProvider(categoryId);
  }

  @override
  RankLabelByCategoryProvider getProviderOverride(
    covariant RankLabelByCategoryProvider provider,
  ) {
    return call(provider.categoryId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'rankLabelByCategoryProvider';
}

/// See also [rankLabelByCategory].
class RankLabelByCategoryProvider extends AutoDisposeProvider<String> {
  /// See also [rankLabelByCategory].
  RankLabelByCategoryProvider(String categoryId)
    : this._internal(
        (ref) => rankLabelByCategory(ref as RankLabelByCategoryRef, categoryId),
        from: rankLabelByCategoryProvider,
        name: r'rankLabelByCategoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$rankLabelByCategoryHash,
        dependencies: RankLabelByCategoryFamily._dependencies,
        allTransitiveDependencies:
            RankLabelByCategoryFamily._allTransitiveDependencies,
        categoryId: categoryId,
      );

  RankLabelByCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final String categoryId;

  @override
  Override overrideWith(
    String Function(RankLabelByCategoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RankLabelByCategoryProvider._internal(
        (ref) => create(ref as RankLabelByCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<String> createElement() {
    return _RankLabelByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RankLabelByCategoryProvider &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RankLabelByCategoryRef on AutoDisposeProviderRef<String> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _RankLabelByCategoryProviderElement
    extends AutoDisposeProviderElement<String>
    with RankLabelByCategoryRef {
  _RankLabelByCategoryProviderElement(super.provider);

  @override
  String get categoryId => (origin as RankLabelByCategoryProvider).categoryId;
}

String _$filteredTasksHash() => r'413e5ef2cd4d6cb86501316bd5d554082850d42b';

/// See also [filteredTasks].
@ProviderFor(filteredTasks)
final filteredTasksProvider = AutoDisposeProvider<List<TaskUIModel>>.internal(
  filteredTasks,
  name: r'filteredTasksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredTasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredTasksRef = AutoDisposeProviderRef<List<TaskUIModel>>;
String _$rankHash() => r'0dd471c30075fb88ffbfe179d5531f479350d0be';

/// See also [rank].
@ProviderFor(rank)
final rankProvider = AutoDisposeProvider<double>.internal(
  rank,
  name: r'rankProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rankHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RankRef = AutoDisposeProviderRef<double>;
String _$rankLabelHash() => r'70f91c9a5d1cef2a0a05cc46d6b197c389d8fa22';

/// See also [rankLabel].
@ProviderFor(rankLabel)
final rankLabelProvider = AutoDisposeProvider<String>.internal(
  rankLabel,
  name: r'rankLabelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rankLabelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RankLabelRef = AutoDisposeProviderRef<String>;
String _$timeBlockHash() => r'c515a0ac45070b82778888f2331247095e028469';

/// See also [TimeBlock].
@ProviderFor(TimeBlock)
final timeBlockProvider =
    AutoDisposeNotifierProvider<TimeBlock, TimeBlockType>.internal(
      TimeBlock.new,
      name: r'timeBlockProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$timeBlockHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TimeBlock = AutoDisposeNotifier<TimeBlockType>;
String _$taskSortHash() => r'4e01250e293f838561fba6a472b51e2e2993b60c';

/// See also [TaskSort].
@ProviderFor(TaskSort)
final taskSortProvider =
    AutoDisposeNotifierProvider<TaskSort, TaskSortOrder>.internal(
      TaskSort.new,
      name: r'taskSortProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$taskSortHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TaskSort = AutoDisposeNotifier<TaskSortOrder>;
String _$currentCategoryHash() => r'1d847a323fda6ee589ef9eac41c05f33e3cd3492';

/// See also [CurrentCategory].
@ProviderFor(CurrentCategory)
final currentCategoryProvider =
    AutoDisposeNotifierProvider<CurrentCategory, int>.internal(
      CurrentCategory.new,
      name: r'currentCategoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentCategoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentCategory = AutoDisposeNotifier<int>;
String _$categoryOrderHash() => r'8eab2f759ca7308a7b251573ed9f8c5e011e74e8';

/// See also [CategoryOrder].
@ProviderFor(CategoryOrder)
final categoryOrderProvider =
    AutoDisposeAsyncNotifierProvider<CategoryOrder, List<String>>.internal(
      CategoryOrder.new,
      name: r'categoryOrderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$categoryOrderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CategoryOrder = AutoDisposeAsyncNotifier<List<String>>;
String _$taskListHash() => r'10474630f5ed081cd9dccac762a1edbb3e0babfa';

/// See also [TaskList].
@ProviderFor(TaskList)
final taskListProvider =
    AutoDisposeAsyncNotifierProvider<TaskList, List<TaskUIModel>>.internal(
      TaskList.new,
      name: r'taskListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$taskListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TaskList = AutoDisposeAsyncNotifier<List<TaskUIModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
