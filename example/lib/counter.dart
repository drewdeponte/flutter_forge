library counter;

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';

// Environment
class Environment {}

// State
@immutable
class State {
  const State({required this.count});
  final int count;
}

// Actions
class Action {
  static ActionTuple<State, Environment> increment(State state) {
    return ActionTuple(State(count: state.count + 1), null);
  }
}

// Widget
class Counter extends ComponentWidget<State, Environment> {
  Counter({super.key, required super.store});

  factory Counter.selfContained() {
    return Counter(
        store: Store(
            initialState: const State(count: 0), environment: Environment()));
  }

  @override
  Widget build(context, state, viewStore) {
    return Column(children: [
      Text(
        '${state.count}',
        style: Theme.of(context).textTheme.headline4,
      ),
      OutlinedButton(
          onPressed: () => viewStore.send(Action.increment),
          child: const Text("increment"))
    ]);
  }
}
