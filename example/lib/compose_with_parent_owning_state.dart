library compose_with_parent_owning_state;

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';

import 'counter.dart' as counter;

// Environment
class Environment {}

// State
@immutable
class State {
  const State({required this.counterState});
  final counter.State counterState;
}

// Actions
abstract class ComposeWithParentOwningStateAction implements ReducerAction {}

class IncrementCounter implements ComposeWithParentOwningStateAction {}

// Reducer
ReducerTuple<State, Environment, ComposeWithParentOwningStateAction>
    composeWithParentOwningStateReducer(
        State state, ComposeWithParentOwningStateAction action) {
  if (action is IncrementCounter) {
    return ReducerTuple(
        State(counterState: counter.State(count: state.counterState.count + 1)),
        []);
  } else {
    return ReducerTuple(State(counterState: state.counterState), []);
  }
}

// Widget
class ComposeWithParentOwningState
    extends ComponentWidget<State, ComposeWithParentOwningStateAction> {
  ComposeWithParentOwningState(
      {super.key,
      StoreInterface<State, ComposeWithParentOwningStateAction>? store})
      : super(
            store: store ??
                Store(
                    initialState:
                        const State(counterState: counter.State(count: 10)),
                    reducer: composeWithParentOwningStateReducer,
                    environment: Environment()));

  @override
  Widget build(context, state, viewStore) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose with Parent Owning State'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            counter.Counter(
                store: store.scope(
              toChildState: (state) => state.counterState,
              fromChildAction: (childAction) => IncrementCounter(),
            )),
            TextButton(
                onPressed: () => viewStore.send(IncrementCounter()),
                child: const Text("parent increment counter"))
          ],
        ),
      ),
    );
  }
}
