library some_button;

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';

// Environment
class Environment {}

// State
@immutable
class State {}

// Actions
abstract class SomeButtonAction implements ReducerAction {}

class ButtonPressed implements SomeButtonAction {}

// Reducer
ReducerTuple<State, Environment, SomeButtonAction> someButtonReducer(
    State state, SomeButtonAction action) {
  return ReducerTuple(state, []);
}

// Widget
class SomeButton extends ComponentWidget<State, SomeButtonAction> {
  SomeButton({super.key, StoreInterface<State, SomeButtonAction>? store})
      : super(
            store: store ??
                Store(
                    initialState: State(),
                    reducer: someButtonReducer,
                    environment: Environment()));

  @override
  Widget build(context, state, viewStore) {
    return Column(children: [
      ElevatedButton(
          onPressed: () => viewStore.send(ButtonPressed()),
          child: const Text('Some Button')),
    ]);
  }
}
