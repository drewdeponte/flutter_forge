library counter;

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';

// Environment
class CounterEnvironment {}

// State
@immutable
class CounterState {
  const CounterState({required this.count});
  final int count;
}

// Actions
class CounterAction {
  static ActionTuple<CounterState, CounterEnvironment> increment(
      CounterState state) {
    return ActionTuple(CounterState(count: state.count + 1), null);
  }
}

// Widget
class Counter extends ComponentWidget<CounterState, CounterEnvironment> {
  Counter({super.key, required super.store});

  factory Counter.selfContained() {
    return Counter(
        store: Store(
            initialState: const CounterState(count: 0),
            environment: CounterEnvironment()));
  }

  @override
  Widget build(context, state, viewStore) {
    return Column(children: [
      Text(
        '${state.count}',
        style: Theme.of(context).textTheme.headline4,
      ),
      OutlinedButton(
          onPressed: () => viewStore.send(CounterAction.increment),
          child: const Text("increment"))
    ]);
  }
}
