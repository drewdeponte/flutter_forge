import 'package:flutter/material.dart';
import 'package:flutter_forge/src/combined_view_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'scoped_store.dart';
import 'store_interface.dart';
import 'reducer_action.dart';
import 'view_store_interface.dart';

class CombinedStore<State> extends StoreInterface<State> {
  final Provider<State> stateProvider;
  final Function(ReducerAction<State> action) converter;

  CombinedStore({required this.stateProvider, required this.converter});

  @override
  AlwaysAliveProviderListenable<State> get provider {
    return stateProvider;
  }

  @override
  ViewStoreInterface<State> viewStore(WidgetRef ref) {
    return CombinedViewStore(converter);
  }

  @override
  Consumer viewBuilder(Widget Function(State state, ViewStoreInterface<State> viewStore) builder) {
    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(stateProvider);
      return builder.call(state, viewStore(ref));
    });
  }

  @override
  StoreInterface<ChildState> scope<ChildState>({required ChildState Function(State) globalToLocalState, required ReducerAction<State> Function(ReducerAction<ChildState>) localToGlobalAction}) {
    return ScopedStore<ChildState, State>(
      parentStore: this,
      stateProvider: Provider<ChildState>((ref) {
        final parentState = ref.watch(stateProvider);
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
