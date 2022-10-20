import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'store.dart';

import 'compose_with_parent_owning_state.dart';
import 'compose_component_owning_state.dart';
import 'send_action_to_child_store.dart';

import 'counter.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

final composeWithParentOwningStateStore = Store(initialState: const ComposeWithParentOwningStateState(counter: CounterState(count: 10)));

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod Composable Arch Examples')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const ComposeComponentOwningState())); },
                child: const Text('Compose with Component Owning State'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => ComposeWithParentOwningState(store: composeWithParentOwningStateStore))); },
                child: const Text('Compose with Parent Owning State'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const SendActionToChildStore())); },
                child: const Text('Send Action to Child Store'),
              ),
            ),
          ]
        )
      )
    );
  }
}
