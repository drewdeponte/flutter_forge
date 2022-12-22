import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'view_store.dart';
import 'reducer_action.dart';
import 'reducer.dart';

typedef ViewStoreProvider<S, E, A extends ReducerAction>
    = StateNotifierProvider<ViewStore<S, E, A>, S>;

ViewStoreProvider<S, E, A> viewStoreProvider<S, E, A extends ReducerAction>(
    S initialState, Reducer<S, E, A> reducer, E environment) {
  return ViewStoreProvider<S, E, A>((ref) => ViewStore<S, E, A>(
      ref: ref,
      initialState: initialState,
      reducer: reducer,
      environment: environment));
}
