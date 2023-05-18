import 'reducer_tuple.dart';
import 'reducer_action.dart';

class Reducer<S, E, A extends ReducerAction> {
  Reducer(this.run);
  final ReducerTuple<S, E, A> Function(S state, A action) run;

  Reducer<S, E, A> debug({String? name}) {
    return Reducer<S, E, A>((S state, A action) {
      final displayName = name ?? "";
      // ignore: avoid_print
      print("${displayName}Reducer received");
      // ignore: avoid_print
      print("  action: $action");
      // ignore: avoid_print
      print("  state: $state");
      final newReducerTuple = run(state, action);
      // ignore: avoid_print
      print("and computed");
      // ignore: avoid_print
      print("  state: ${newReducerTuple.state}");
      return newReducerTuple;
    });
  }

  Reducer<PS, PE, PA> pullback<PS, PE, PA extends ReducerAction>(
      {required S Function(PS) toChildState,
      required PS Function(S) fromChildState,
      required A? Function(PA) toChildAction,
      required PA Function(A) fromChildAction,
      required E Function(PE) toChildEnvironment}) {
    return Reducer<PS, PE, PA>((PS state, PA action) {
      final childState = toChildState(state);
      final optionalChildAction = toChildAction(action);
      if (optionalChildAction == null) {
        return ReducerTuple(state, []);
      } else {
        final childReducerTuple = run(childState, optionalChildAction);

        final newState = fromChildState(childReducerTuple.state);

        final effectTasks = childReducerTuple.effectTasks.map((effectTask) =>
            effectTask.pullback(
                toChildState: toChildState,
                toChildEnvironment: toChildEnvironment,
                fromChildAction: fromChildAction,
                toChildContext: (cx) => cx));

        return ReducerTuple(newState, effectTasks);
      }
    });
  }

  static Reducer<COMBS, COMBE, COMBA>
      combine<COMBS, COMBE, COMBA extends ReducerAction>(
          Reducer<COMBS, COMBE, COMBA> reducerA,
          Reducer<COMBS, COMBE, COMBA> reducerB) {
    return Reducer((state, action) {
      final reducerTupleA = reducerA.run(state, action);
      final reducerTupleB = reducerB.run(reducerTupleA.state, action);
      return ReducerTuple(reducerTupleB.state,
          [...reducerTupleA.effectTasks, ...reducerTupleB.effectTasks]);
    });
  }
}
