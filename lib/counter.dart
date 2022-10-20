library counter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'store.dart';

// State definition
@immutable
class CounterState {
  const CounterState({required this.count});
  final int count;
}

// Reducer Action
CounterState increment(Ref ref, CounterState state) {
  return CounterState(count: state.count + 1);
}

// Widget
class Counter extends StatelessWidget {
  const Counter({super.key, required this.store});
  final StoreInterface<CounterState> store;

  @override
  Widget build(BuildContext context) {
    return store.viewBuilder((state, viewStore) {
      return Column(children: [
        Text('${state.count}', style: Theme.of(context).textTheme.headline4,),
        OutlinedButton(
          onPressed: () => viewStore.send(increment),
          child: const Text("increment"))
      ]);
    });
  }
}
