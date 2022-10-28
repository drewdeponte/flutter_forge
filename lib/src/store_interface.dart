import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'view_store_interface.dart';
import 'reducer_action.dart';

/// Formal Interface for all Store implementations
abstract class StoreInterface<S> {
  /// get ViewStore - object to manage state changes in a controlled unidirectional flow
  ViewStoreInterface<S> viewStore(WidgetRef ref);
  /// escape hatch out of this framework back to Riverpod land
  AlwaysAliveProviderListenable<S> get provider;
  /// register a function to build your widget anytime state changes
  Consumer viewBuilder(Widget Function(S state, ViewStoreInterface<S> viewStore) builder);
  /// scope a stores state concerns down to a portion of it's state
  StoreInterface<ChildState> scope<ChildState>({required ChildState Function(S) globalToLocalState, required ReducerAction<S> Function(ReducerAction<ChildState>) localToGlobalAction});
  /// binding multiple stores to the view
  Consumer combinedViewBuilder<StateB>(StoreInterface<StateB> storeB, Widget Function(S stateA, ViewStoreInterface<S> viewStoreA, StateB stateB, ViewStoreInterface<StateB> viewStoreB) builder);
}
