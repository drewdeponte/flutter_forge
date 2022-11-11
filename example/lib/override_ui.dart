library override_ui;

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'counter.dart' as counter;

class Environment {}

class State {
  State(this.name);
  String name;
}

class Action {
  static ActionTuple<State, Environment> appendYourMom(State state) {
    return ActionTuple(State("${state.name} your mom"), []);
  }
}

class CounterWithOverridenUi extends counter.Counter {
  CounterWithOverridenUi(
      {super.key, StoreInterface<counter.State, counter.Environment>? store})
      : super(
            store: store ??
                Store(
                    initialState: const counter.State(count: 0),
                    environment: counter.Environment()));

  @override
  Widget build(context, state, viewStore) {
    return Column(children: [
      Text(
        '${state.count}',
        style: Theme.of(context).textTheme.headline1,
      ),
      ElevatedButton(
          onPressed: () => viewStore.send(counter.Action.increment),
          child: const Text("overriden ui - increment"))
    ]);
  }
}

class OverrideUiComponent extends ComponentWidget<State, Environment> {
  OverrideUiComponent({super.key, required super.store});

  @override
  Widget build(context, state, viewStore) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Override Ui Component'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(state.name),
            CounterWithOverridenUi(),
            TextButton(
                onPressed: () => viewStore.send(Action.appendYourMom),
                child: const Text("parent append your mom to name"))
          ],
        ),
      ),
    );
  }
}
