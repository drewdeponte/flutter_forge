library counter;

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';
import 'package:equatable/equatable.dart';

// Environment
class Environment {}

// State
@immutable
class State extends Equatable {
  const State({required this.count});

  final int count;

  @override
  List<Object> get props => [count];
}

// Actions
abstract class CounterAction implements ReducerAction {}

class IncrementCounterByOne implements CounterAction {}

// Reducer
final counterReducer = Reducer<State, Environment, CounterAction>(
    (State state, CounterAction action) {
  if (action is IncrementCounterByOne) {
    return ReducerTuple(State(count: state.count + 1), []);
  } else {
    return ReducerTuple(state, []);
  }
});

// Widget
class Counter extends ComponentWidget<State, Environment, CounterAction> {
  Counter({super.key, StoreInterface<State, Environment, CounterAction>? store})
      : super(
            store: store ??
                Store(
                    initialState: const State(count: 0),
                    reducer: counterReducer.debug(name: "counter"),
                    environment: Environment()));

  @override
  Widget build(context, state, viewStore) {
    print("CounterComponent build called");
    return Column(children: [
      Text(
        '${state.count}',
        style: Theme.of(context).textTheme.headline4,
      ),
      OutlinedButton(
          onPressed: () => viewStore.send(IncrementCounterByOne()),
          child: const Text("increment"))
    ]);
  }

  @override
  void dispose() {
    print("Counter dispose() called");
    super.dispose();
  }
}
