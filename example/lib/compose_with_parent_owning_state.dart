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

class CounterWidgetAction implements ComposeWithParentOwningStateAction {
  final counter.CounterAction childCounterAction;
  CounterWidgetAction(this.childCounterAction);
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

counter.CounterAction? toChildAction(
    ComposeWithParentOwningStateAction action) {
  if (action is CounterWidgetAction) {
    return action.childCounterAction;
  }
  return null;
}

final ourReducer =
    Reducer.combine<State, Environment, ComposeWithParentOwningStateAction>(
        counter.counterReducer.pullback(
          toChildState: (ps) => ps.counterState,
          toChildAction: toChildAction,
          toChildEnvironment: (pe) => counter.Environment(),
          fromChildState: (cs) => State(counterState: cs),
          fromChildAction: (ca) => CounterWidgetAction(ca),
        ),
        composeWithParentOwningStateReducer);

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
                    reducer: ourReducer,
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
              fromChildAction: (childAction) =>
                  CounterWidgetAction(childAction),
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
