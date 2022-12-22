library trigger_nav_by_child_component;

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';
import 'package:flutter_riverpod_composable_arch/some_button.dart';

import 'some_button.dart' as some_button;

// Environment
class Environment {}

// State
@immutable
class State {
  const State();
}

// Effects
class Effects {
  static final navigateToAnotherPage =
      EffectTask<State, Environment, TriggerNavByChildComponentAction>(
          (s, e, context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AnotherPage()));
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

// Note: In a real world application where it isn't 100% flutter forge components up
// and down the stack, which this layer is representing that boundary as it is just
// a StatelessWidget, you have to decide if you want your store to be global or if
// you want it to be created & destroyed with a widget. If the later you should create
// the store as part of a StatefulWidget
final triggerNavByChildComponentStore = Store(
    initialState: const State(),
    reducer: triggerNavByChildComponentReducer,
    environment: Environment());

// Widget
class TriggerNavByChildComponent extends StatelessWidget {
  const TriggerNavByChildComponent({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trigger Nav By Child Component'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SomeButton(
                store: triggerNavByChildComponentStore.scope(
              toChildState: (state) => some_button.State(),
              fromChildAction: (childAction) {
                return ButtonPressed();
              },
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
