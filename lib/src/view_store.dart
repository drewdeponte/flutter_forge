import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'reducer_action.dart';
import 'view_store_interface.dart';

/// Manage state updates in a controlled fashion
class ViewStore<State> extends StateNotifier<State> implements ViewStoreInterface<State> {
  ViewStore(this.ref, State initialState) : super(initialState);
  final Ref ref;
  final Queue<ReducerAction<State>> actionQueue = Queue();
  bool isSending = false;

  @override
  void send(ReducerAction<State> action) {
    actionQueue.addFirst(action);

    if (isSending) {
      return;
    }

    _processQueue();
  }

  Future<void> _processQueue() async {
    isSending = true;

    while (actionQueue.isNotEmpty) {
      final action = actionQueue.removeLast();
      // TODO: add some sort of hook for logging here
      // Fimber.d('send($action): begin:');

      try {
        final newState = await action(ref, state);
        // TODO: add some sort of hook for logging here
        // Fimber.d('send($action): end:\nnewState: $newState');
        state = newState;
      } catch (error) {
        // TODO: add some sort of hook for logging here
        // Fimber.d('error executing action: $action\nerror: $error');
      }
    }

    isSending = false;
  }

  @override
  String toString() => 'ViewStore(ref: $ref)';
}
