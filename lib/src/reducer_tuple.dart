import 'effect_task.dart';

class ReducerTuple<S, E> {
  ReducerTuple(this.state, this.effectTask);
  final S state;
  final EffectTask<S, E>? effectTask;

  factory ReducerTuple.noop(S state) {
    return ReducerTuple(state, null);
  }
}
