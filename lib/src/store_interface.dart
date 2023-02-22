import 'dart:async';

import 'async_state.dart';
import 'async_state_widget.dart';
import 'state_management/reducer_action.dart';
import 'state_management/view_store_interface.dart';
import 'state_management/reducer.dart';
import 'package:equatable/equatable.dart';

/// Formal Interface for all Store implementations
abstract class StoreInterface<S extends Equatable, E, A extends ReducerAction> {
  /// get ViewStore - object to manage state changes in a controlled unidirectional flow
  ViewStoreInterface<S, A> get viewStore;

  /// scope a stores state concerns down to a portion of it's state
  StoreInterface<CS, CE, CA>
      scopeParentHandles<CS extends Equatable, CA extends ReducerAction, CE>(
          {required CS Function(S) toChildState,
          required A Function(CA) fromChildAction,
          required CE Function(E) toChildEnvironment});

  StoreInterface<CS, CE, CA>
      scopeSyncState<CS extends Equatable, CA extends ReducerAction, CE>(
          {required CS Function(S) toChildState,
          required S Function(S, CS) fromChildState,
          required Reducer<CS, CE, CA> childReducer,
          required CE Function(E) toChildEnvironment});

  StoreInterface<CS, CE, CA> scopeForwardActionsAndSyncState<
          CS extends Equatable, CA extends ReducerAction, CE>(
      {required CS Function(S) toChildState,
      required S Function(S, CS) fromChildState,
      required A Function(CA) fromChildAction,
      required Reducer<CS, CE, CA> childReducer,
      required CE Function(E) toChildEnvironment});

  AsyncStateWidget<T, E> loadAsyncStateWidget<T extends Equatable>(
      {required FutureOr<T> Function(E) loader,
      required AsyncState<T> Function(S) toChildState,
      required S Function(S, AsyncState<T>) fromChildState}) {
    return AsyncStateWidget(
        store: this.scopeSyncState(
            toChildState: toChildState,
            fromChildState: fromChildState,
            childReducer: asyncStateReducer(loader),
            toChildEnvironment: (env) => env));
  }
}
