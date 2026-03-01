// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$actionListHash() => r'42b354dd8b8e07de6c51d08b4385078c36fd19d5';

/// See also [actionList].
@ProviderFor(actionList)
final actionListProvider =
    AutoDisposeFutureProvider<List<domain_action.Action>>.internal(
      actionList,
      name: r'actionListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$actionListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActionListRef =
    AutoDisposeFutureProviderRef<List<domain_action.Action>>;
String _$portfolioHash() => r'1cdf700a719ea1d9b5895f8f22749ba328dc2332';

/// See also [Portfolio].
@ProviderFor(Portfolio)
final portfolioProvider =
    AutoDisposeAsyncNotifierProvider<Portfolio, List<TaskUIModel>>.internal(
      Portfolio.new,
      name: r'portfolioProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$portfolioHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Portfolio = AutoDisposeAsyncNotifier<List<TaskUIModel>>;
String _$actionCreateControllerHash() =>
    r'3f43c12ba560eeec074027f0e893762c0102ab28';

/// See also [ActionCreateController].
@ProviderFor(ActionCreateController)
final actionCreateControllerProvider =
    AutoDisposeNotifierProvider<
      ActionCreateController,
      AsyncValue<void>
    >.internal(
      ActionCreateController.new,
      name: r'actionCreateControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$actionCreateControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActionCreateController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
