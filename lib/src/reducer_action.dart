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

ReducerAction<S, E> combineActions<S, E>(
    ReducerAction<S, E> actionA, ReducerAction<S, E> actionB) {
  return (state) {
    final actionATuple = actionA(state);
    final actionBTuple = actionB(actionATuple.state);
    return ActionTuple(actionBTuple.state,
        actionATuple.effectTasks.toList() + actionBTuple.effectTasks.toList());
  };
}

ReducerAction<S, E> Function(ReducerAction<CS, CE>)
    pullbackAction<S, E, CS, CE>(
        {required StateScoper<S, CS> stateScoper,
        required EnvironmentScoper<E, CE> environmentScoper,
        required StatePullbacker<CS, S> statePullback}) {
  return (childAction) {
    return (parentState) {
      final childActionTuple = childAction(stateScoper(parentState));
      final newParentState = statePullback(childActionTuple.state);
      final newParentEffects = childActionTuple.effectTasks.map((effectTask) =>
          effectTask.pullback(
              stateScoper: stateScoper,
              environmentScoper: environmentScoper,
              statePullback: statePullback));
      return ActionTuple(newParentState, newParentEffects);
    };
  };
}

ReducerAction<S, E> Function(ReducerAction<CS, CE>)
    pullbackMapAction<S, E, CS, CE>(
        Map<ReducerAction<CS, CE>, ReducerAction<S, E>> actionMap,
        {required StateScoper<S, CS> stateScoper,
        required EnvironmentScoper<E, CE> environmentScoper,
        required StatePullbacker<CS, S> statePullback}) {
  return (childAction) {
    return (state) {
      // run the child action
      final pulledBackChildAction = pullbackAction(
          stateScoper: stateScoper,
          environmentScoper: environmentScoper,
          statePullback: statePullback)(childAction);
      final actionToRun = actionMap[childAction];
      if (actionToRun != null) {
        return combineActions(pulledBackChildAction, actionToRun)(state);
      } else {
        return pulledBackChildAction(state);
      }
    };
  };
}
