import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'view_store.dart';
import 'reducer_action.dart';
import 'reducer.dart';

typedef ViewStoreProvider<S, E, A extends ReducerAction>
    = NotifierProvider<ViewStore<S, E, A>, S>;

ViewStoreProvider<S, E, A> viewStoreProvider<S, E, A extends ReducerAction>(
    S initialState, Reducer<S, E, A> reducer, E environment) {
  return ViewStoreProvider<S, E, A>(() => ViewStore<S, E, A>(
      initialState: initialState, reducer: reducer, environment: environment));
}
