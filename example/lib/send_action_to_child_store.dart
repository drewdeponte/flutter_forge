library send_action_to_child_store;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_forge/flutter_forge.dart';

import 'counter.dart' as counter;

final _sendActionToChildStoreStore = Store(
    initialState: const counter.State(count: 100),
    environment: counter.Environment());

// Widget
class SendActionToChildStore extends ConsumerWidget {
  const SendActionToChildStore({super.key});

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
            counter.Counter(store: _sendActionToChildStoreStore),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _sendActionToChildStoreStore
            .viewStore(ref)
            .send(counter.Action.increment),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
