library some_button;

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';

// Environment
class Environment {}

// State
@immutable
class State {}

// Actions
class Action {
  static ActionTuple<State, Environment> buttonPressed(State state) {
    return ActionTuple.noop(state);
  }
}

// Widget
class SomeButton extends ComponentWidget<State, Environment> {
  SomeButton({super.key, StoreInterface<State, Environment>? store})
      : super(
            store: store ??
                Store(initialState: State(), environment: Environment()));

  @override
  Widget build(context, state, viewStore) {
    return Column(children: [
      ElevatedButton(
          onPressed: () => viewStore.send(Action.buttonPressed),
          child: const Text('Some Button')),
    ]);
  }
}
