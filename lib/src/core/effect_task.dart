import 'dart:async';
import 'package:flutter/widgets.dart';

import 'reducer_action.dart';

class EffectTask<S, E, A extends ReducerAction> {
  EffectTask(this.run);
  final Future<A?> Function(S state, E environment, BuildContext context) run;

  // EffectTask<PS, PE> pullback<PS, PE>(
  //     {required StateScoper<PS, S> stateScoper,
  //     required EnvironmentScoper<PE, E> environmentScoper,
  //     required StatePullbacker<S, PS> statePullback}) {
  //   return EffectTask((parentState, parentEnvironment, parentContext) async {
  //     final optionalChildAction = await run(stateScoper(parentState),
  //         environmentScoper(parentEnvironment), parentContext);
  //     return mapReducerAction(
  //         optionalChildAction,
  //         pullbackAction(
  //             stateScoper: stateScoper,
  //             environmentScoper: environmentScoper,
  //             statePullback: statePullback));
  //   });
  // }
}
