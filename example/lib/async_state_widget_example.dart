library async_state_widget_example;

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';
import 'package:equatable/equatable.dart';

class EquatableString extends Equatable {
  final String val;
  const EquatableString(this.val);

  @override
  List<Object> get props => [val];
}

@immutable
class AsyncStateWidgetExampleState extends Equatable {
  const AsyncStateWidgetExampleState({required this.name});

  final AsyncState<EquatableString> name;

  @override
  List<Object> get props => [name];
}

class AsyncStateWidgetExampleEnvironment {}

// Effect Tasks

// Actions
abstract class AsyncStateWidgetExampleAction implements ReducerAction {}

// Reducer
final asyncStateWidgetExampleReducer = Reducer<
    AsyncStateWidgetExampleState,
    AsyncStateWidgetExampleEnvironment,
    AsyncStateWidgetExampleAction>((state, action) {
  return ReducerTuple(state, []);
});

// Stateful Widget
class AsyncStateWidgetExampleComponentWidget extends ComponentWidget<
    AsyncStateWidgetExampleState,
    AsyncStateWidgetExampleEnvironment,
    AsyncStateWidgetExampleAction> {
  AsyncStateWidgetExampleComponentWidget(
      {super.key,
      StoreInterface<
              AsyncStateWidgetExampleState,
              AsyncStateWidgetExampleEnvironment,
              AsyncStateWidgetExampleAction>?
          store})
      : super(
            store: store ??
                Store(
                    initialState: const AsyncStateWidgetExampleState(
                        name: AsyncState.initial()),
                    reducer: asyncStateWidgetExampleReducer.debug(
                        name: "asyncStateWidgetExampleReducer"),
                    environment: AsyncStateWidgetExampleEnvironment()));

  @override
  Widget build(context, viewStore) {
    // ignore: avoid_print
    print("AsyncStateWidgetExampleComponentWidget build called");
    return Scaffold(
      appBar: AppBar(
        title: const Text('AsyncStateWidgetExampleComponent'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(children: [
              AsyncStateWidget(
                  store: store.scopeAsyncStateSync(
                      loader: (_) => Future.delayed(const Duration(seconds: 5),
                          () => const EquatableString("Woot woot!")),
                      toChildState: (s) => s.name,
                      fromChildState: (s, cs) =>
                          AsyncStateWidgetExampleState(name: cs))),
              Rebuilder(
                  store: store,
                  builder: (context, state, child) {
                    return Column(children: [
                      state.name.when(
                          initial: () => const Text('Name Initial'),
                          loading: () => const Text('Loading...'),
                          data: (v) => Text('data = $v'),
                          error: (e, __) => Text('error = ${e.toString()}')),
                    ]);
                  }),
            ])
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // ignore: avoid_print
    print("AsyncStateWidgetExampleComponentWidget dispose() called");
    super.dispose();
  }
}
