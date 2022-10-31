import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'view_store.dart';

typedef ViewStoreProvider<S, E> = StateNotifierProvider<ViewStore<S, E>, S>;

ViewStoreProvider<S, E> viewStoreProvider<S, E>(S initialState, E environment) {
  return ViewStoreProvider<S, E>((ref) => ViewStore<S, E>(
      ref: ref, initialState: initialState, environment: environment));
}
