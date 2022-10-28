import 'package:flutter/material.dart';
import 'package:flutter_forge/src/combined_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'store_interface.dart';
import 'reducer_action.dart';
import 'view_store_provider.dart';
import 'view_store_interface.dart';
import 'view_store.dart';
import 'scoped_store.dart';

class Store<S> extends StoreInterface<S> {
  Store({required S initialState}): _stateNotifierProvider = viewStoreProvider(initialState);
  final StateNotifierProvider<ViewStore<S>, S> _stateNotifierProvider;

  @override
  AlwaysAliveProviderListenable<S> get provider {
    return _stateNotifierProvider;
  }

  @override
  ViewStore<S> viewStore(WidgetRef ref) {
    return ref.read(_stateNotifierProvider.notifier);
  }

  @override
  Consumer viewBuilder(Widget Function(S state, ViewStoreInterface<S> viewStore) builder) {
    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(_stateNotifierProvider);
      return builder.call(state, viewStore(ref));
    },);
  }

  @override
  StoreInterface<ChildState> scope<ChildState>({required ChildState Function(S) globalToLocalState, required ReducerAction<S> Function(ReducerAction<ChildState>) localToGlobalAction}) {
    return ScopedStore<ChildState, S>(
      parentStore: this,
      stateProvider: Provider<ChildState>((ref) {
        final parentState = ref.watch(_stateNotifierProvider);
        return globalToLocalState.call(parentState);
      }),
      localActionToGlobalAction: localToGlobalAction
    );
  }

  static StoreInterface<ChildState> combine<StoreAState, StoreBState, ChildState>({
    required StoreInterface<StoreAState> storeA,
    required StoreInterface<StoreBState> storeB,
    required ChildState Function(StoreAState, StoreBState) build,
    required Function(ReducerAction<ChildState> action) converter
  }) {
    return CombinedStore(
      stateProvider: Provider((ref) {
        final stateA = ref.watch(storeA.provider);
        final stateB = ref.watch(storeB.provider);
        return build.call(stateA, stateB);
      }),
      converter: converter
    );
  }

  @override
  Consumer combinedViewBuilder<StateB>(StoreInterface<StateB> storeB, Widget Function(S stateA, ViewStoreInterface<S> viewStoreA, StateB stateB, ViewStoreInterface<StateB> viewStoreB) builder) {
    return Consumer(builder: (context, ref, child) {
      final stateA = ref.watch(provider);
      final stateB = ref.watch(storeB.provider);
      return builder.call(stateA, viewStore(ref), stateB, storeB.viewStore(ref));
    });
  }
}
