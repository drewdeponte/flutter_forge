library counter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_forge/flutter_forge.dart';

// State definition
@immutable
class CounterState {
  const CounterState({required this.count});
  final int count;
}

// Reducer Action
class CounterAction {
  static CounterState increment(Ref ref, CounterState state) {
    return CounterState(count: state.count + 1);
  }
}

// Widget
class Counter extends ComponentWidget<CounterState> {
  Counter({super.key, required super.store});

  @override
  Widget buildView(context, ref, state, viewStore) {
    return Column(children: [
      Text('${state.count}', style: Theme.of(context).textTheme.headline4,),
      OutlinedButton(
        onPressed: () => viewStore.send(CounterAction.increment),
        child: const Text("increment"))
    ]);
  }
}
