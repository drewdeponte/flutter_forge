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

// Actions
class Action {}

final triggerNavByChildComponentStore =
    Store(initialState: const State(), environment: Environment());

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
                      return (State state) {
                        if (childAction == some_button.Action.buttonPressed) {
                          return ActionTuple(state, [
                            EffectTask((s, e) async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AnotherPage()));
                              return null;
                            })
                          ]);
                        } else {
                          return ActionTuple(state, []);
                        }
                      };
                    }))
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
