import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'reducer.dart';
import 'reducer_action.dart';
import 'view_store_interface.dart';

/// Manage state updates in a controlled fashion
class ViewStore<S, E, A extends ReducerAction> extends StateNotifier<S>
    implements ViewStoreInterface<A> {
  ViewStore({
    required this.ref,
    required S initialState,
    required this.reducer,
    required this.environment,
  }) : super(initialState);

  final Ref ref;
  final Reducer<S, E, A> reducer;
  final E environment;
  final Queue<A> _actionQueue = Queue();
  late BuildContext _context;
  bool _isSending = false;

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

      final reducerTuple = reducer.run(state, action);
      state = reducerTuple.state;
      try {
        reducerTuple.effectTasks.forEach((effectTask) {
          effectTask.run(state, environment, context()).then((optionalAction) {
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

  @override
  String toString() => 'ViewStore(ref: $ref)';
}
