library trigger_nav_by_child_component;

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';
import 'package:equatable/equatable.dart';

import 'some_button.dart' as some_button;

// Environment
class Environment {}

// State
@immutable
class State extends Equatable {
  const State();

  @override
  List<Object> get props => [];
}

// Effects
class Effects {
  static final navigateToAnotherPage =
      EffectTask<State, Environment, TriggerNavByChildComponentAction>(
          (s, e, context) async {
    Navigator.push(
        context!, MaterialPageRoute(builder: (context) => const AnotherPage()));
    return null;
  });
}

// Actions
abstract class TriggerNavByChildComponentAction implements ReducerAction {}

class ButtonPressed implements TriggerNavByChildComponentAction {}

// Reducer
final triggerNavByChildComponentReducer =
    Reducer<State, Environment, TriggerNavByChildComponentAction>(
        (State state, TriggerNavByChildComponentAction action) {
  if (action is ButtonPressed) {
    return ReducerTuple(state, [Effects.navigateToAnotherPage]);
  } else {
    return ReducerTuple(state, []);
  }
});

// Widget
class TriggerNavByChildComponent extends ComponentWidget<State, Environment,
    TriggerNavByChildComponentAction> {
  TriggerNavByChildComponent(
      {super.key,
      StoreInterface<State, Environment, TriggerNavByChildComponentAction>?
          store})
      : super(
            store: store ??
                Store(
                    initialState: const State(),
                    reducer: triggerNavByChildComponentReducer.debug(
                        name: "triggerNavByChildComponent"),
                    environment: Environment()));

  @override
  Widget build(context, viewStore) {
    print("TriggerNavByChildComponent build called");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trigger Nav By Child Component'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            some_button.SomeButton(
                store: store.scopeForwardActionsAndSyncState(
              toChildState: (state) => const some_button.State(),
              fromChildState: (state, childState) => state,
              fromChildAction: (childAction) {
                return ButtonPressed();
              },
              toChildEnvironment: (_) => some_button.Environment(),
              childReducer:
                  some_button.someButtonReducer.debug(name: "someButton"),
            ))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    print("TriggerNavByChildComponent dispose() called");
    super.dispose();
  }
}

class AnotherPage extends StatelessWidget {
  const AnotherPage({super.key});

  @override
  Widget build(BuildContext context) {
    print("AnotherPage build called");
    return Scaffold(
      appBar: AppBar(title: const Text('Another Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Another Page'),
          ],
        ),
      ),
    );
  }
}
