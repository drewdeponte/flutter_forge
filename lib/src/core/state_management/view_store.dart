import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'reducer.dart';
import 'reducer_action.dart';
import 'view_store_interface.dart';

/// ViewStore is a Riverpod Notifier designed to use the Redux pattern to
/// facilitate managing state change in a controlled way
///
/// To mutate state with it you have to create an Action and send that
/// Action to the ViewStore via the send() method. The Action is then
/// interpreted by the Reducer provided at initialization and the Reducer
/// produces the new representation of state which the ViewStore then
/// applies and notifies any observers of that state.
class ViewStore<S, E, A extends ReducerAction> extends ValueNotifier<S>
    implements ViewStoreInterface<S, A> {
  ViewStore({
    required S initialState,
    required Reducer<S, E, A> reducer,
    required E environment,
  })  : _reducer = reducer,
        _environment = environment,
        super(initialState);

  final Reducer<S, E, A> _reducer;
  final E _environment;
  final Queue<A> _actionQueue = Queue();
  @override
  BuildContext? context;
  bool _isSending = false;

  @override
  S get state {
    return value;
  }

  @override
  set state(S newState) {
    value = newState;
  }

  @override
  Listenable get listenable {
    return this;
  }

  @override
  void send(A action) {
    _actionQueue.addFirst(action);

    if (_isSending) {
      return;
    }

    _processQueue();
  }

  Future<void> _processQueue() async {
    _isSending = true;

    while (_actionQueue.isNotEmpty) {
      final action = _actionQueue.removeLast();

      final reducerTuple = _reducer.run(value, action);
      value = reducerTuple.state;
      try {
        for (final effectTask in reducerTuple.effectTasks) {
          effectTask.run(state, _environment, context).then((optionalAction) {
            if (optionalAction != null) {
              send(optionalAction);
            }
          });
        }
      } catch (error) {
        // ignore: avoid_print
        print("Error while processing effects: $error");
      }
    }

    _isSending = false;
  }
}
