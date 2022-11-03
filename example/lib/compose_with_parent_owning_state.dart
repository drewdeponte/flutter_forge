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
class Action {
  static ActionTuple<State, Environment> incrementCounter(State state) {
    return ActionTuple(
        State(counterState: counter.State(count: state.counterState.count + 1)),
        null);
  }
}

// Widget
class ComposeWithParentOwningState extends ComponentWidget<State, Environment> {
  ComposeWithParentOwningState({super.key, required super.store});

  factory ComposeWithParentOwningState.selfContained() {
    return ComposeWithParentOwningState(
        store: Store(
            initialState: const State(counterState: counter.State(count: 10)),
            environment: Environment()));
  }

  @override
  Widget build(context, state, viewStore) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose with Parent Owning State'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            counter.Counter(
                store: store.scope(
                    toChildState: (state) => state.counterState,
                    fromChildAction: pullbackAction<State, Environment,
                            counter.State, counter.Environment>(
                        stateScoper: (parentState) => parentState.counterState,
                        environmentScoper: (_) => counter.Environment(),
                        statePullback: (childState) =>
                            State(counterState: childState)))),
            TextButton(
                onPressed: () => viewStore.send(Action.incrementCounter),
                child: const Text("parent increment counter"))
          ],
        ),
      ),
    );
  }
}
