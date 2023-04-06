import 'reducer_action.dart';
import 'view_store.dart';
import 'package:flutter/widgets.dart';
import 'package:equatable/equatable.dart';

class ListenerFunctionViewStoreBinding<S extends Equatable, E,
    A extends ReducerAction> {
  ListenerFunctionViewStoreBinding(
      {required this.viewStore, required this.listenerFunction});
  final VoidCallback listenerFunction;
  final ViewStore<S, E, A> viewStore;
}
