import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_forge/flutter_forge.dart';

import 'compose_with_parent_owning_state.dart'
    as compose_with_parent_owning_state;
import 'compose_component_owning_state.dart' as compose_component_owning_state;
import 'send_action_to_child_store.dart' as send_action_to_child_store;
import 'load_on_component_init.dart' as load_on_component_init;

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
                            .ComposeWithParentOwningState.selfContained()));
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
                        builder: (context) => const send_action_to_child_store
                            .SendActionToChildStore()));
              },
              child: const Text('Send Action to Child Store'),
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
                            .LoadOnInitComponentWidget.selfContained()));
              },
              child: const Text('Load On Init Component'),
            ),
          ),
        ])));
  }
}
