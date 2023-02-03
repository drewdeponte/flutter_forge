import 'state_management/reducer_action.dart';
import 'state_management/view_store_interface.dart';
import 'package:equatable/equatable.dart';

/// Formal Interface for all Store implementations
abstract class StoreInterface<S extends Equatable, E, A extends ReducerAction> {
  /// get ViewStore - object to manage state changes in a controlled unidirectional flow
  ViewStoreInterface<S, A> get viewStore;

  /// scope a stores state concerns down to a portion of it's state
  StoreInterface<CS, CE, CA>
      scope<CS extends Equatable, CA extends ReducerAction, CE>(
          {required CS Function(S) toChildState,
          required A Function(CA) fromChildAction,
          required CE Function(E) toChildEnvironment});
}
