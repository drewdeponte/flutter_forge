import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
class ViewStore<S, E, A extends ReducerAction> extends Notifier<S>
    implements ViewStoreInterface<A> {
  ViewStore({
    required S initialState,
    required Reducer<S, E, A> reducer,
    required E environment,
  })  : _initialState = initialState,
        _reducer = reducer,
        _environment = environment;

  final S _initialState;
  final Reducer<S, E, A> _reducer;
  final E _environment;
  final Queue<A> _actionQueue = Queue();
  late BuildContext _context;
  bool _isSending = false;

  @override
  S build() {
    return _initialState;
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
      // TODO: add some sort of hook for logging here
      // Fimber.d('send($action): begin:');

      final reducerTuple = _reducer.run(state, action);
      state = reducerTuple.state;
      try {
        reducerTuple.effectTasks.forEach((effectTask) {
          effectTask.run(state, _environment, context()).then((optionalAction) {
            if (optionalAction != null) {
              send(optionalAction);
            }
          });
        });
      } catch (error) {
        // TODO: add some sort of hook for logging here
        // Fimber.d('error executing action: $action\nerror: $error');
      }
    }

    _isSending = false;
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  BuildContext context() {
    return _context;
  }
}
