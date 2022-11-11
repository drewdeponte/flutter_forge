import 'effect_task.dart';

class ReducerTuple<S, E> {
  ReducerTuple(this.state, this.effectTasks);
  final S state;
  final Iterable<EffectTask<S, E>> effectTasks;

  factory ReducerTuple.noop(S state) {
    return ReducerTuple(state, []);
  }
}
