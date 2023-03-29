import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:equatable/equatable.dart';

import 'state_management/effect_task.dart';
import 'state_management/reducer.dart';
import 'state_management/reducer_action.dart';
import 'state_management/reducer_tuple.dart';
import 'store_interface.dart';
import 'component_widget.dart';
import 'async_state.dart';

// Actions
abstract class AsyncStateAction extends ReducerAction {}

class AsyncStateLoadAction extends AsyncStateAction {}

class AsyncStateLoadCompleteAction<T extends Equatable>
    extends AsyncStateAction {
  final T value;
  AsyncStateLoadCompleteAction(this.value);
}

class AsyncStateLoadFailedAction extends AsyncStateAction {
  final Object error;
  final StackTrace stackTrace;
  AsyncStateLoadFailedAction(this.error, this.stackTrace);
}

class AsyncStateResetAction extends AsyncStateAction {}

// Reducer
Reducer<AsyncState<T>, E, AsyncStateAction>
    asyncStateReducer<T extends Equatable, E>(FutureOr<T> Function(E) load) {
  final loadEffect = EffectTask<AsyncState<T>, E, AsyncStateAction>(
    (state, environment, context) async {
      try {
        final tValue = await load(environment);
        return AsyncStateLoadCompleteAction(tValue);
      } catch (e, stack) {
        return AsyncStateLoadFailedAction(e, stack);
      }
    },
  );

  return Reducer<AsyncState<T>, E, AsyncStateAction>((state, action) {
    if (action is AsyncStateLoadAction) {
      return ReducerTuple(const AsyncState.loading(), [loadEffect]);
    } else if (action is AsyncStateLoadCompleteAction<T>) {
      return ReducerTuple(AsyncState.data(action.value), []);
    } else if (action is AsyncStateLoadFailedAction) {
      return ReducerTuple(
          AsyncState.error(action.error, action.stackTrace), []);
    } else if (action is AsyncStateResetAction) {
      return ReducerTuple(const AsyncState.initial(), []);
    } else {
      return ReducerTuple(state, []);
    }
  });
}

// Widget
@immutable
class AsyncStateWidget<T extends Equatable, E>
    extends ComponentWidget<AsyncState<T>, E, AsyncStateAction> {
  const AsyncStateWidget(
      {super.key,
      required StoreInterface<AsyncState<T>, E, AsyncStateAction> store})
      : super(store: store);

  @override
  void postInitState(viewStore) {
    viewStore.send(AsyncStateLoadAction());
  }

  @override
  Widget build(context, viewStore) {
    return const SizedBox(width: 0, height: 0);
  }
}
