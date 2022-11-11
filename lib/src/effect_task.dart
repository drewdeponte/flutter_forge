import 'dart:async';
import 'reducer_action.dart';

class EffectTask<S, E> {
  EffectTask(this.run);
  final Future<ReducerAction<S, E>?> Function(S state, E environment) run;

  EffectTask<PS, PE> pullback<PS, PE>(
      {required StateScoper<PS, S> stateScoper,
      required EnvironmentScoper<PE, E> environmentScoper,
      required StatePullbacker<S, PS> statePullback}) {
    return EffectTask((parentState, parentEnvironment) async {
      final optionalChildAction = await run(
          stateScoper(parentState), environmentScoper(parentEnvironment));
      return mapReducerAction(
          optionalChildAction,
          pullbackAction(
              stateScoper: stateScoper,
              environmentScoper: environmentScoper,
              statePullback: statePullback));
    });
  }
}
