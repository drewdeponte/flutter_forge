library load_on_component_init;

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';

// State definition
@immutable
class State {
  const State({required this.count, required this.name});
  final int count;
  final String name;
}

class Environment {}

// Effect Tasks
final loadNameEffect = EffectTask((state, environment) {
  return Future.delayed(const Duration(seconds: 5), () {})
      .then((_) => Action.setName("The Loaded Name"));
});

// Reducer Action
class Action {
  static ActionTuple<State, Environment> load(State state) {
    return ActionTuple(
      State(count: state.count, name: "Loading..."),
      [loadNameEffect],
    );
  }

  static ReducerAction<State, Environment> setName(String name) {
    return (state) {
      return ActionTuple(State(name: name, count: state.count), []);
    };
  }

  static ActionTuple<State, Environment> increment(State state) {
    return ActionTuple(State(count: state.count + 1, name: state.name), []);
  }
}

// Stateful Widget
class LoadOnInitComponentWidget extends ComponentWidget<State, Environment> {
  LoadOnInitComponentWidget(
      {super.key, StoreInterface<State, Environment>? store})
      : super(
            store: store ??
                Store(
                    initialState: const State(count: 0, name: "Initial"),
                    environment: Environment()));

  @override
  void postInitState(viewStore) {
    viewStore.send(Action.load);
  }

  @override
  Widget build(context, state, viewStore) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load On Init Component'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(children: [
              Text(state.name),
              Text(
                '${state.count}',
                style: Theme.of(context).textTheme.headline4,
              ),
              OutlinedButton(
                  onPressed: () => viewStore.send(Action.increment),
                  child: const Text("increment"))
            ])
          ],
        ),
      ),
    );
  }
}
