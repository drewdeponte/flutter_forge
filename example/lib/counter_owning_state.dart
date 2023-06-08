library counter_owning_state;

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
sealed class CounterAction implements ReducerAction {}

class CounterIncrementButtonTapped implements CounterAction {}

// Reducer
final counterReducer = Reducer<State, Environment, CounterAction>(
    (State state, CounterAction action) {
  switch (action) {
    case CounterIncrementButtonTapped _:
      return ReducerTuple(State(count: state.count + 1), []);
  }
});

// Widget
class Counter extends ComponentWidget<State, Environment, CounterAction> {
  Counter(
      {super.key,
      StoreInterface<State, Environment, CounterAction>? store,
      super.builder})
      : super(
            store: store ??
                Store(
                    initialState: const State(count: 0),
                    reducer: counterReducer.debug(name: "counter"),
                    environment: Environment()));

  // @override
  // void listen(context, state) {
  //   print("Listened to state change: ${state.count}");
  //   const snackBar = SnackBar(
  //     content: Text('Yay! A SnackBar!'),
  //   );
  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  // }

  @override
  Widget build(context, viewStore) {
    // ignore: avoid_print
    print("CounterComponent build called");

    return Column(children: [
      Rebuilder(
          store: store,
          builder: (context, state, child) {
            return Text(
              '${state.count}',
              style: Theme.of(context).textTheme.headlineMedium,
            );
          }),
      OutlinedButton(
          onPressed: () => viewStore.send(CounterIncrementButtonTapped()),
          child: const Text("increment"))
    ]);
  }

  @override
  void dispose() {
    // ignore: avoid_print
    print("Counter dispose() called");
    super.dispose();
  }
}
