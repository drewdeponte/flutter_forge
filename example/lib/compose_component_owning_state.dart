library compose_component_owning_state;

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';

import 'counter.dart' as counter;

class Environment {}

class State {
  State(this.name);
  String name;
}

class Action {
  static ActionTuple<State, Environment> appendYourMom(State state) {
    return ActionTuple(State("${state.name} your mom"), null);
  }
}

class ComposeComponentOwningState extends ComponentWidget<State, Environment> {
  ComposeComponentOwningState({super.key, required super.store});

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
            counter.Counter.selfContained(),
            TextButton(
                onPressed: () => viewStore.send(Action.appendYourMom),
                child: const Text("parent append your mom to name"))
          ],
        ),
      ),
    );
  }
}
