import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';
import 'trigger_nav_by_child_component.dart';
import 'compose_with_parent_owning_state.dart'
    as compose_with_parent_owning_state;
import 'compose_component_owning_state.dart' as compose_component_owning_state;
import 'load_on_component_init.dart' as load_on_component_init;
import 'async_state_widget_example.dart' as async_state_widget_example;
import 'integrate_with_riverpod.dart' as integrate_with_riverpod;
import 'override_ui.dart' as override_ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Forge Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

final composeComponentOwningStateStore = Store(
    initialState: const compose_component_owning_state.State("hello"),
    reducer: compose_component_owning_state.composeComponentOwningStateReducer
        .debug(name: "composeComponentOwningState"),
    environment: compose_component_owning_state.Environment());
final overrideUiStore = Store(
    initialState: const override_ui.State('override ui'),
    reducer: override_ui.overrideUiReducer.debug(name: "overrideUi"),
    environment: override_ui.Environment());

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Flutter Forge Examples')),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => compose_component_owning_state
                            .ComposeComponentOwningState(
                                store: composeComponentOwningStateStore)));
              },
              child: const Text('Compose with Component Owning State'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => compose_with_parent_owning_state
                            .ComposeWithParentOwningState()));
              },
              child: const Text('Compose with Parent Owning State'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => load_on_component_init
                            .LoadOnInitComponentWidget()));
              },
              child: const Text('Load On Init Component'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => override_ui.OverrideUiComponent(
                            store: overrideUiStore)));
              },
              child: const Text('Override UI keeping business logic'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TriggerNavByChildComponent()));
              },
              child: const Text('Trigger Nav by Child Component'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => async_state_widget_example
                            .AsyncStateWidgetExampleComponentWidget()));
              },
              child: const Text('AsyncStateWidget Example'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const integrate_with_riverpod
                            .MyRiverpodReadonlyWidget()));
              },
              child: const Text('IntegrateWithRiverpodComponentWidget Example'),
            ),
          ),
        ])));
  }
}
