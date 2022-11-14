import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'reducer.dart';
import 'reducer_action.dart';
import 'view_store_interface.dart';

/// Manage state updates in a controlled fashion
class ViewStore<S, E> extends StateNotifier<S>
    implements ViewStoreInterface<S, E> {
  ViewStore(
      {required this.ref,
      required S initialState,
      required this.environment,
      this.reducer})
      : super(initialState);
  final Ref ref;
  final Reducer<S, E>? reducer;
  final E environment;
  final Queue<ReducerAction<S, E>> actionQueue = Queue();
  late BuildContext _context;
  bool isSending = false;

  @override
  void send(ReducerAction<S, E> action) {
    actionQueue.addFirst(action);

    if (isSending) {
      return;
    }

    _processQueue();
  }

  Reducer<S, E> _reducer() {
    if (reducer != null) {
      return reducer!;
    } else {
      return (S state, ReducerAction<S, E> action) {
        return action(state);
      };
    }
  }

  Future<void> _processQueue() async {
    isSending = true;

    while (actionQueue.isNotEmpty) {
      final action = actionQueue.removeLast();
      // TODO: add some sort of hook for logging here
      // Fimber.d('send($action): begin:');

      final reducerTuple = _reducer()(state, action);
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

    isSending = false;
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
