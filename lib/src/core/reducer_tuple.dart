import 'effect_task.dart';
import 'reducer_action.dart';

class ReducerTuple<S, E, A extends ReducerAction> {
  ReducerTuple(this.state, this.effectTasks);
  final S state;
  final Iterable<EffectTask<S, E, A>> effectTasks;

  factory ReducerTuple.noop(S state) {
    return ReducerTuple(state, []);
  }
}
