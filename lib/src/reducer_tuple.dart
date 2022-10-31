import 'effect_task.dart';

class ReducerTuple<S, E> {
  ReducerTuple(this.state, this.effectTask);
  final S state;
  final EffectTask<S, E>? effectTask;

  EffectTask<NS, NE>? mapEffectTask<NS, NE>(
      EffectTask<NS, NE> Function(EffectTask<S, E>) mapper) {
    if (this.effectTask == null) {
      return null;
    } else {
      return mapper(this.effectTask!);
    }
  }
}
