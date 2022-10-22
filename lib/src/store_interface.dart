import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'view_store_interface.dart';
import 'reducer_action.dart';

/// Formal Interface for all Store implementations
abstract class StoreInterface<State> {
  /// get ViewStore - object to manage state changes in a controlled unidirectional flow
  ViewStoreInterface<State> viewStore(WidgetRef ref);
  /// escape hatch out of this framework back to Riverpod land
  AlwaysAliveProviderListenable<State> get provider;
  /// register a function to build your widget anytime state changes
  Consumer viewBuilder(Widget Function(State state, ViewStoreInterface<State> viewStore) builder);
  /// scope a stores state concerns down to a portion of it's state
  StoreInterface<ChildState> scope<ChildState>({required ChildState Function(State) globalToLocalState, required ReducerAction<State> Function(ReducerAction<ChildState>) localToGlobalAction});
  /// binding multiple stores to the view
  Consumer combinedViewBuilder<StateB>(StoreInterface<StateB> storeB, Widget Function(State stateA, ViewStoreInterface<State> viewStoreA, StateB stateB, ViewStoreInterface<StateB> viewStoreB) builder);
}
