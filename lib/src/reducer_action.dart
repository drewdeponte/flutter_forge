import 'action_tuple.dart';
import 'effect_task.dart';

typedef ReducerAction<S, E> = ActionTuple<S, E> Function(S state);

ReducerAction<NS, NE>? mapReducerAction<S, E, NS, NE>(
    ReducerAction<S, E>? action,
    ReducerAction<NS, NE> Function(ReducerAction<S, E>) mapper) {
  if (action != null) {
    return mapper(action);
  } else {
    return null;
  }
}

typedef StateScoper<S, CS> = CS Function(S parentState);
typedef EnvironmentScoper<E, CE> = CE Function(E parentEnvironment);
typedef StatePullbacker<CS, S> = S Function(CS childState);
typedef EffectPullbacker<CS, CE, S, E> = EffectTask<S, E> Function(
    EffectTask<CS, CE> childEffect);

ReducerAction<S, E> Function(ReducerAction<CS, CE>)
    pullbackAction<S, E, CS, CE>(
        {required StateScoper<S, CS> stateScoper,
        required EnvironmentScoper<E, CE> environmentScoper,
        required StatePullbacker<CS, S> statePullback}) {
  return (childAction) {
    return (parentState) {
      final childActionTuple = childAction(stateScoper(parentState));
      final newParentState = statePullback(childActionTuple.state);
      final newParentEffect = childActionTuple.mapEffectTask(pullbackEffectTask(
          stateScoper: stateScoper,
          environmentScoper: environmentScoper,
          statePullback: statePullback));
      return ActionTuple(newParentState, newParentEffect);
    };
  };
}

EffectTask<S, E> Function(EffectTask<CS, CE>) pullbackEffectTask<S, E, CS, CE>(
    {required StateScoper<S, CS> stateScoper,
    required EnvironmentScoper<E, CE> environmentScoper,
    required StatePullbacker<CS, S> statePullback}) {
  return (EffectTask<CS, CE> effectTask) {
    return (parentEnvironment) async {
      final optionalChildAction =
          await effectTask(environmentScoper(parentEnvironment));
      return mapReducerAction(
          optionalChildAction,
          pullbackAction(
              stateScoper: stateScoper,
              environmentScoper: environmentScoper,
              statePullback: statePullback));
    };
  };
}
