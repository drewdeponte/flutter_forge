import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'view_store.dart';

typedef ViewStoreProvider<State> = StateNotifierProvider<ViewStore<State>, State>;

ViewStoreProvider<State> viewStoreProvider<State>(State initialState) {
  return ViewStoreProvider<State>((ref) => ViewStore<State>(ref, initialState));
}
