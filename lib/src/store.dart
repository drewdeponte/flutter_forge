import 'package:flutter/material.dart';
import 'package:flutter_forge/src/combined_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'store_interface.dart';
import 'reducer_action.dart';
import 'view_store_provider.dart';
import 'view_store_interface.dart';
import 'view_store.dart';
import 'scoped_store.dart';

class Store<S, E> extends StoreInterface<S, E> {
  Store({required S initialState, required E environment})
      : _stateNotifierProvider = viewStoreProvider(initialState, environment);
  final StateNotifierProvider<ViewStore<S, E>, S> _stateNotifierProvider;

  @override
  AlwaysAliveProviderListenable<S> get provider {
    return _stateNotifierProvider;
  }

  @override
  ViewStore<S, E> viewStore(WidgetRef ref) {
    return ref.read(_stateNotifierProvider.notifier);
  }

  @override
  Consumer viewBuilder(
      Widget Function(S state, ViewStoreInterface<S, E> viewStore) builder) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(_stateNotifierProvider);
        return builder.call(state, viewStore(ref));
      },
    );
  }

  @override
  StoreInterface<CS, CE> scope<CS, CE>(
      {required CS Function(S) toChildState,
      required ReducerAction<S, E> Function(ReducerAction<CS, CE>)
          fromChildAction}) {
    return ScopedStore<CS, CE, S, E>(
        parentStore: this,
        stateProvider: Provider<CS>((ref) {
          final parentState = ref.watch(_stateNotifierProvider);
          return toChildState.call(parentState);
        }),
        fromChildAction: fromChildAction);
  }

  static StoreInterface<CS, CE> combine<SA, EA, SB, EB, CS, CE>(
      {required StoreInterface<SA, EA> storeA,
      required StoreInterface<SB, EB> storeB,
      required CS Function(SA, SB) build,
      required Function(ReducerAction<CS, CE> action) converter}) {
    return CombinedStore(
        stateProvider: Provider((ref) {
          final stateA = ref.watch(storeA.provider);
          final stateB = ref.watch(storeB.provider);
          return build.call(stateA, stateB);
        }),
        converter: converter);
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
