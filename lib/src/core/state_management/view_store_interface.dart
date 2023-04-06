import 'package:flutter/widgets.dart';
import 'package:equatable/equatable.dart';
import 'reducer_action.dart';

/// Formal Interface for all ViewStore implementations
abstract class ViewStoreInterface<S extends Equatable, A extends ReducerAction>
    implements ValueNotifier<S> {
  BuildContext? context;

  S get state;
  set state(S newState);
  Listenable get listenable;

  /// send/dispatch an action to the store to have it change state in a controlled manner
  void send(A action);
}
