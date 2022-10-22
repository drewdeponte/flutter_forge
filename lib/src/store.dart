import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'store_interface.dart';
import 'reducer_action.dart';
import 'view_store_provider.dart';
import 'view_store_interface.dart';
import 'view_store.dart';
import 'scoped_store.dart';

class Store<State> extends StoreInterface<State> {
  Store({required State initialState}): _stateNotifierProvider = viewStoreProvider(initialState);
  final StateNotifierProvider<ViewStore<State>, State> _stateNotifierProvider;

  @override
  AlwaysAliveProviderListenable<State> get provider {
    return _stateNotifierProvider;
  }

  @override
  ViewStore<State> viewStore(WidgetRef ref) {
    return ref.read(_stateNotifierProvider.notifier);
  }

  @override
  Consumer viewBuilder(Widget Function(State state, ViewStoreInterface<State> viewStore) builder) {
    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(_stateNotifierProvider);
      return builder.call(state, viewStore(ref));
    },);
  }

  @override
  StoreInterface<ChildState> scope<ChildState>({required ChildState Function(State) globalToLocalState, required ReducerAction<State> Function(ReducerAction<ChildState>) localToGlobalAction}) {
    return ScopedStore<ChildState, State>(
      parentStore: this,
      stateProvider: Provider<ChildState>((ref) {
        final parentState = ref.watch(_stateNotifierProvider);
        return globalToLocalState.call(parentState);
      }),
      localActionToGlobalAction: localToGlobalAction
    );
  }

  @override
  Consumer combinedViewBuilder<StateB>(StoreInterface<StateB> storeB, Widget Function(State stateA, ViewStoreInterface<State> viewStoreA, StateB stateB, ViewStoreInterface<StateB> viewStoreB) builder) {
    return Consumer(builder: (context, ref, child) {
      final stateA = ref.watch(provider);
      final stateB = ref.watch(storeB.provider);
      return builder.call(stateA, viewStore(ref), stateB, storeB.viewStore(ref));
    });
  }
}
