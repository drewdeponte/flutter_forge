import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:equatable/equatable.dart';

import 'reducer_action.dart';

class EffectTask<S extends Equatable, E, A extends ReducerAction> {
  EffectTask(this.run);
  final Future<A?> Function(S state, E environment, BuildContext? context) run;

  EffectTask<PS, PE, PA>
      pullback<PS extends Equatable, PE, PA extends ReducerAction>({
    required S Function(PS) toChildState,
    required E Function(PE) toChildEnvironment,
    required PA Function(A) fromChildAction,
    required BuildContext? Function(BuildContext?) toChildContext,
  }) {
    return EffectTask((parentState, parentEnv, parentContext) async {
      final optionalAction = await run(
        toChildState(parentState),
        toChildEnvironment(parentEnv),
        toChildContext(parentContext),
      );

      if (optionalAction == null) {
        return null;
      } else {
        return fromChildAction(optionalAction);
      }
    });
  }
}
