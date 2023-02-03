library override_ui;

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';
import 'package:equatable/equatable.dart';

import 'counter.dart' as counter;

// Component with overriden ui
class CounterWithOverridenUi extends counter.Counter {
  CounterWithOverridenUi(
      {super.key,
      StoreInterface<counter.State, counter.Environment, counter.CounterAction>?
          store})
      : super(
            store: store ??
                Store(
                    initialState: const counter.State(count: 0),
                    reducer: counter.counterReducer
                        .debug(name: "CounterWithOverridenUi"),
                    environment: counter.Environment()));

  @override
  Widget build(context, state, viewStore) {
    return Column(children: [
      Text(
        '${state.count}',
        style: Theme.of(context).textTheme.headline1,
      ),
      ElevatedButton(
          onPressed: () => viewStore.send(counter.IncrementCounterByOne()),
          child: const Text("overriden ui - increment"))
    ]);
  }
}

// Environment
class Environment {}

// State
@immutable
class State extends Equatable {
  const State(this.name);

  final String name;

  @override
  List<Object> get props => [name];
}

// Actions
abstract class OverrideUiAction implements ReducerAction {}

class AppendYourMom implements OverrideUiAction {}

// Reducer
final overrideUiReducer = Reducer<State, Environment, OverrideUiAction>(
    (State state, OverrideUiAction action) {
  if (action is AppendYourMom) {
    return ReducerTuple(State("${state.name} your mom"), []);
  } else {
    return ReducerTuple(state, []);
  }
});

// Component housing the component with overriden ui
class OverrideUiComponent
    extends ComponentWidget<State, Environment, OverrideUiAction> {
  const OverrideUiComponent({super.key, required super.store});

  @override
  Widget build(context, state, viewStore) {
    print("OverrideUiComponent build called");
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
                onPressed: () => viewStore.send(AppendYourMom()),
                child: const Text("parent append your mom to name"))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    print("OverrideUiComponent dispose() called");
    super.dispose();
  }
}
