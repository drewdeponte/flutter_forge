import 'package:flutter/material.dart';
import 'package:flutter_forge/src/combined_view_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'scoped_store.dart';
import 'store_interface.dart';
import 'reducer_action.dart';
import 'view_store_interface.dart';

class CombinedStore<S, E> extends StoreInterface<S, E> {
  final Provider<S> stateProvider;
  final Function(ReducerAction<S, E> action) converter;

  CombinedStore({required this.stateProvider, required this.converter});

  @override
  AlwaysAliveProviderListenable<S> get provider {
    return stateProvider;
  }

  @override
  ViewStoreInterface<S, E> viewStore(WidgetRef ref) {
    return CombinedViewStore(converter);
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
          return toChildState(parentState);
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
