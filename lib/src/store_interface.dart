import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'view_store_interface.dart';
import 'reducer_action.dart';

/// Formal Interface for all Store implementations
abstract class StoreInterface<S, E> {
  /// get ViewStore - object to manage state changes in a controlled unidirectional flow
  ViewStoreInterface<S, E> viewStore(WidgetRef ref);

  /// escape hatch out of this framework back to Riverpod land
  AlwaysAliveProviderListenable<S> get provider;

  /// register a function to build your widget anytime state changes
  Consumer viewBuilder(
      Widget Function(S state, ViewStoreInterface<S, E> viewStore) builder);

  /// scope a stores state concerns down to a portion of it's state
  StoreInterface<CS, CE> scope<CS, CE>(
      {required CS Function(S) toChildState,
      required ReducerAction<S, E> Function(ReducerAction<CS, CE>)
          fromChildAction});

  /// binding multiple stores to the view
  Consumer combinedViewBuilder<SB, EB>(
      StoreInterface<SB, EB> storeB,
      Widget Function(S stateA, ViewStoreInterface<S, E> viewStoreA, SB stateB,
              ViewStoreInterface<SB, EB> viewStoreB)
          builder);
}
