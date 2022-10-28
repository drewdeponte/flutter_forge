import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_forge/flutter_forge.dart';

import 'counter.dart';

@immutable
class ComposeWithParentOwningStateState {
  const ComposeWithParentOwningStateState({required this.counter});
  final CounterState counter;
}

ComposeWithParentOwningStateState incrementCounter(Ref ref, ComposeWithParentOwningStateState state) {
  return ComposeWithParentOwningStateState(counter: CounterState(count: state.counter.count + 1));
}

class ComposeWithParentOwningState extends ComponentWidget<ComposeWithParentOwningStateState> {
  ComposeWithParentOwningState({super.key, required super.store});

  @override
  Widget buildView(context, ref, state, viewStore) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose with Parent Owning State'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Counter(
              store: store.scope(
                globalToLocalState: (appState) => appState.counter,
                localToGlobalAction: (localAction) {
                  return (Ref ref, ComposeWithParentOwningStateState state) async {
                    return ComposeWithParentOwningStateState(counter: await localAction(ref, state.counter));
                  };
                })
            ),
          ],
        ),
      ),
    );
  }
}
