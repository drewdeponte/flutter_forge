library compose_component_owning_state;

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';

import 'counter.dart' as counter;

class Environment {}

class State {
  State(this.name);
  String name;
}

abstract class ComposeComponentOwningStateAction implements ReducerAction {}

class AppendYourMom implements ComposeComponentOwningStateAction {}

final composeComponentOwningStateReducer =
    Reducer<State, Environment, ComposeComponentOwningStateAction>(
        (State state, ComposeComponentOwningStateAction action) {
  if (action is AppendYourMom) {
    return ReducerTuple(State("${state.name} your mom"), []);
  } else {
    return ReducerTuple(state, []);
  }
});

class ComposeComponentOwningState extends ComponentWidget<State, Environment,
    ComposeComponentOwningStateAction> {
  const ComposeComponentOwningState({super.key, required super.store});

  @override
  Widget build(context, state, viewStore) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose Component Owning State'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(state.name),
            counter.Counter(),
            TextButton(
                onPressed: () => viewStore.send(AppendYourMom()),
                child: const Text("parent append your mom to name"))
          ],
        ),
      ),
    );
  }
}
