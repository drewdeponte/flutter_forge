import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_forge/flutter_forge.dart';
import 'package:flutter_riverpod_composable_arch/trigger_nav_by_child_component.dart';

import 'compose_with_parent_owning_state.dart'
    as compose_with_parent_owning_state;
import 'compose_component_owning_state.dart' as compose_component_owning_state;
import 'load_on_component_init.dart' as load_on_component_init;
import 'override_ui.dart' as override_ui;

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
    initialState: compose_component_owning_state.State("hello"),
    environment: compose_component_owning_state.Environment());
final overrideUiStore = Store(
    initialState: override_ui.State('override ui'),
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
                        builder: (context) =>
                            const TriggerNavByChildComponent()));
              },
              child: const Text('Trigger Nav by Child Component'),
            ),
          ),
        ])));
  }
}
