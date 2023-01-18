library load_with_riverpod_future_provider;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_forge/flutter_forge.dart';

final nameProvider = FutureProvider<String>((ref) async {
  return Future.delayed(const Duration(seconds: 5), () {
    return "The Loaded Name";
  });
});

// State definition
@immutable
class State {
  const State({required this.count, required this.name});
  final int count;
  final AsyncValue<String> name;
}

class Environment {}

// Actions
abstract class LoadWithRiverpodFutureProviderAction implements ReducerAction {}

class Increment implements LoadWithRiverpodFutureProviderAction {}

// Reducer
final loadWithRiverpodFutureProviderReducer =
    Reducer<State, Environment, LoadWithRiverpodFutureProviderAction>(
        (State state, LoadWithRiverpodFutureProviderAction action) {
  if (action is Increment) {
    return ReducerTuple(State(count: state.count + 1, name: state.name), []);
  } else {
    return ReducerTuple(state, []);
  }
});

// Stateful Widget
class LoadWithRiverpodFutureProviderComponentWidget
    extends ComponentWidget<State, LoadWithRiverpodFutureProviderAction> {
  LoadWithRiverpodFutureProviderComponentWidget(
      {super.key,
      StoreInterface<State, LoadWithRiverpodFutureProviderAction>? store})
      : super(
            store: store ??
                Store(
                  initialState:
                      const State(count: 0, name: AsyncValue.data("Initial")),
                  reducer: loadWithRiverpodFutureProviderReducer,
                  environment: Environment(),
                  extProviderConnector: ExternalProviderConnector(
                    provider: nameProvider,
                    fromExtState: (state, subState) =>
                        State(count: state.count, name: subState),
                  ),
                ));

  @override
  Widget build(context, state, viewStore) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load With Riverpod Future Provider Component'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(children: [
              state.name.when(
                data: (data) => Text(data),
                error: (_, __) => const Text("Some error"),
                loading: () => const Text("Loading..."),
              ),
              Text(
                '${state.count}',
                style: Theme.of(context).textTheme.headline4,
              ),
              OutlinedButton(
                  onPressed: () => viewStore.send(Increment()),
                  child: const Text("increment"))
            ])
          ],
        ),
      ),
    );
  }
}
