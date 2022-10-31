import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'store_interface.dart';
import 'reducer_action.dart';
import 'view_store_interface.dart';
import 'scoped_view_store.dart';

class ScopedStore<S, E, PS, PE> extends StoreInterface<S, E> {
  final StoreInterface<PS, PE> parentStore;
  final Provider<S> stateProvider;
  final ReducerAction<PS, PE> Function(ReducerAction<S, E>) fromChildAction;

  ScopedStore(
      {required this.parentStore,
      required this.stateProvider,
      required this.fromChildAction});

  @override
  AlwaysAliveProviderListenable<S> get provider {
    return stateProvider;
  }

  @override
  ViewStoreInterface<S, E> viewStore(WidgetRef ref) {
    return ScopedViewStore(parentStore.viewStore(ref), fromChildAction);
  }

  @override
  Consumer viewBuilder(
      Widget Function(S state, ViewStoreInterface<S, E> viewStore) builder) {
    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(stateProvider);
      return builder.call(state, viewStore(ref));
    });
  }

  @override
  StoreInterface<CS, CE> scope<CS, CE>(
      {required CS Function(S) toChildState,
      required ReducerAction<S, E> Function(ReducerAction<CS, CE>)
          fromChildAction}) {
    return ScopedStore<CS, CE, S, E>(
        parentStore: this,
        stateProvider: Provider<CS>((ref) {
          final parentState = ref.watch(stateProvider);
          return toChildState.call(parentState);
        }),
        fromChildAction: fromChildAction);
  }

  @override
  Consumer combinedViewBuilder<SB, EB>(
      StoreInterface<SB, EB> storeB,
      Widget Function(S stateA, ViewStoreInterface<S, E> viewStoreA, SB stateB,
              ViewStoreInterface<SB, EB> viewStoreB)
          builder) {
    return Consumer(builder: (context, ref, child) {
      final stateA = ref.watch(provider);
      final stateB = ref.watch(storeB.provider);
      return builder.call(
          stateA, viewStore(ref), stateB, storeB.viewStore(ref));
    });
  }
}
