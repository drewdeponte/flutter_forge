library trigger_nav_by_child_component;

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';
import 'package:flutter_riverpod_composable_arch/some_button.dart';
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
                    reducer: triggerNavByChildComponentReducer,
                    environment: Environment()));

  @override
  Widget build(context, state, viewStore) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trigger Nav By Child Component'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SomeButton(
                store: store.scope(
              toChildState: (state) => const some_button.State(),
              fromChildAction: (childAction) {
                return ButtonPressed();
              },
              toChildEnvironment: (_) => some_button.Environment(),
            ))
          ],
        ),
      ),
    );
  }
}

class AnotherPage extends StatelessWidget {
  const AnotherPage({super.key});

  @override
  Widget build(BuildContext context) {
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
