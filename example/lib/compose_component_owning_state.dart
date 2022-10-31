import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';

import 'counter.dart';

final _counterStore = Store(
    initialState: const CounterState(count: 100),
    environment: CounterEnvironment());

class ComposeComponentOwningState extends StatelessWidget {
  const ComposeComponentOwningState({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose Component Owning State'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Counter(store: _counterStore),
          ],
        ),
      ),
    );
  }
}
