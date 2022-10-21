import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge/forge.dart';

import 'counter.dart';

final _sendActionToChildStoreStore = Store(initialState: const CounterState(count: 100));

class SendActionToChildStore extends ConsumerWidget {
  const SendActionToChildStore ({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Action to Child Store'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Counter(store: _sendActionToChildStoreStore),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _sendActionToChildStoreStore.viewStore(ref).send(increment),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}