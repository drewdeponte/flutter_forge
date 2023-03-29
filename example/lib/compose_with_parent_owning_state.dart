library compose_with_parent_owning_state;

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';
import 'package:equatable/equatable.dart';

import 'counter.dart' as counter;

// Environment
class Environment {}

// State
@immutable
class State extends Equatable {
  const State({required this.counterState});

  final counter.State counterState;

  @override
  List<Object> get props => [counterState];
}

// Actions
abstract class ComposeWithParentOwningStateAction implements ReducerAction {}

class CounterWidgetAction implements ComposeWithParentOwningStateAction {
  final counter.CounterAction action;
  CounterWidgetAction(this.action);
}

class IncrementCounter implements ComposeWithParentOwningStateAction {}

// Reducer
final composeWithParentOwningStateReducer =
    Reducer<State, Environment, ComposeWithParentOwningStateAction>(
        (State state, ComposeWithParentOwningStateAction action) {
  if (action is IncrementCounter) {
    return ReducerTuple(
        State(counterState: counter.State(count: state.counterState.count + 1)),
        []);
  } else {
    return ReducerTuple(State(counterState: state.counterState), []);
  }
});

// Widget
class ComposeWithParentOwningState extends ComponentWidget<State, Environment,
    ComposeWithParentOwningStateAction> {
  ComposeWithParentOwningState(
      {super.key,
      StoreInterface<State, Environment, ComposeWithParentOwningStateAction>?
          store})
      : super(
            store: store ??
                Store(
                    initialState:
                        const State(counterState: counter.State(count: 10)),
                    reducer: composeWithParentOwningStateReducer.debug(
                        name: "ComposeWithParentOwningState"),
                    environment: Environment()));

  @override
  Widget build(context, viewStore) {
    // ignore: avoid_print
    print("ComposeWithParentOwningState build called");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose with Parent Owning State'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            counter.Counter(
                store: store.scopeSyncState(
              toChildState: (state) => state.counterState,
              fromChildState: (state, childState) =>
                  State(counterState: childState),
              toChildEnvironment: (_) => counter.Environment(),
              childReducer: counter.counterReducer.debug(name: "Counter"),
            )),
            TextButton(
                onPressed: () => viewStore.send(IncrementCounter()),
                child: const Text("parent increment counter"))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // ignore: avoid_print
    print("ComposeWithParentOwningState dispose() called");
    super.dispose();
  }
}
