import 'dart:async';

import 'reducer_action.dart';
import 'view_store_interface.dart';
import 'reducer.dart';

// TODO: It feels weird that within core we are accessing and using something from the convenience layer.
// We should probably rethink this. Maybe we don't need it here or we aren't using that scopeAsyncStateSync()
// function anymore. Or maybe it should be mixed in somehow but live completely in the convenience area.
import '../../convenience/async_state.dart';
import '../../convenience/async_state_widget.dart';

/// Formal Interface for all Store implementations
abstract class StoreInterface<S, E, A extends ReducerAction> {
  /// get ViewStore - object to manage state changes in a controlled unidirectional flow
  ViewStoreInterface<S, A> get viewStore;

  /// scope a stores state concerns down to a portion of it's state
  StoreInterface<CS, CE, CA>
      scopeParentHandles<CS, CA extends ReducerAction, CE>(
          {required CS Function(S) toChildState,
          required A Function(CA) fromChildAction,
          required CE Function(E) toChildEnvironment});

  StoreInterface<CS, CE, CA> scopeSyncState<CS, CA extends ReducerAction, CE>(
      {required CS Function(S) toChildState,
      required S Function(S, CS) fromChildState,
      required Reducer<CS, CE, CA> childReducer,
      required CE Function(E) toChildEnvironment});

  StoreInterface<CS, CE, CA>
      scopeForwardActionsAndSyncState<CS, CA extends ReducerAction, CE>(
          {required CS Function(S) toChildState,
          required S Function(S, CS) fromChildState,
          required A Function(CA) fromChildAction,
          required Reducer<CS, CE, CA> childReducer,
          required CE Function(E) toChildEnvironment});

  StoreInterface<AsyncState<T>, E, AsyncStateAction>
      scopeAsyncStateSync<T extends Object, CA extends ReducerAction, CE>(
          {required FutureOr<T> Function(E) loader,
          required AsyncState<T> Function(S) toChildState,
          required S Function(S, AsyncState<T>) fromChildState}) {
    return scopeSyncState(
        toChildState: toChildState,
        fromChildState: fromChildState,
        childReducer: asyncStateReducer(loader),
        toChildEnvironment: (env) => env);
  }
}
