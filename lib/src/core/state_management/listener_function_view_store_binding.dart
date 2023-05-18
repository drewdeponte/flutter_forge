import 'reducer_action.dart';
import 'view_store.dart';
import 'package:flutter/widgets.dart';

class ListenerFunctionViewStoreBinding<S, E, A extends ReducerAction> {
  ListenerFunctionViewStoreBinding(
      {required this.viewStore, required this.listenerFunction});
  final VoidCallback listenerFunction;
  final ViewStore<S, E, A> viewStore;
}
