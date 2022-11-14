import 'package:flutter/widgets.dart';

import 'reducer_action.dart';

/// Formal Interface for all ViewStore implementations
abstract class ViewStoreInterface<S, E> {
  void setContext(BuildContext context);
  BuildContext context();

  /// send/dispatch an action to the store to have it change state in a controlled manner
  void send(ReducerAction<S, E> action);
}
