import 'state_management/reducer_action.dart';
import 'state_management/reducer.dart';
import 'package:equatable/equatable.dart';

class ActionStateTuple<A extends ReducerAction, S extends Equatable> {
  final A action;
  final S state;
  ActionStateTuple(this.action, this.state);

  @override
  String toString() => "ActionStateTuple($action, $state)";
}

class TestStore<S extends Equatable, E, A extends ReducerAction,
    CS extends Equatable, CA extends ReducerAction> {
  TestStore(
      {required S initialState,
      required Reducer<S, E, A> reducer,
      required E environment,
      CS Function(S)? toChildState,
      A Function(CA)? fromChildAction})
      : _environment = environment,
        _state = initialState,
        _reducer = reducer;
  final E _environment;
  final Reducer<S, E, A> _reducer;
  S _state;

  S get state {
    return _state;
  }

  Future<List<ActionStateTuple<A, S>>> send(A action) async {
    List<ActionStateTuple<A, S>> actionStateTuples = [];

    final reducerTuple = _reducer.run(_state, action);
    _state = reducerTuple.state;
    actionStateTuples.add(ActionStateTuple(action, reducerTuple.state));

    await Future.forEach(reducerTuple.effectTasks, (effectTask) async {
      final optionalAction = await effectTask.run(_state, _environment, null);
      if (optionalAction != null) {
        final reducerTuple = _reducer.run(_state, optionalAction);
        _state = reducerTuple.state;
        actionStateTuples
            .add(ActionStateTuple(optionalAction, reducerTuple.state));
      }
    });

    return actionStateTuples;
  }
}
