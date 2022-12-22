import 'package:flutter/widgets.dart';
import 'reducer_action.dart';

/// Formal Interface for all ViewStore implementations
abstract class ViewStoreInterface<A extends ReducerAction> {
  void setContext(BuildContext context);
  BuildContext context();

  /// send/dispatch an action to the store to have it change state in a controlled manner
  void send(A action);
}
