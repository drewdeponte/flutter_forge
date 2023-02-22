library async_state_widget_example;

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';
import 'package:equatable/equatable.dart';

// State definition
@immutable
class Foo extends Equatable {
  final String name;
  const Foo(this.name);

  @override
  List<Object> get props => [name];
}

@immutable
class AsyncStateWidgetExampleState extends Equatable {
  const AsyncStateWidgetExampleState({required this.count, required this.foo});

  final int count;
  final AsyncState<Foo> foo;

  @override
  List<Object> get props => [count, foo];
}

class AsyncStateWidgetExampleEnvironment {}

// Effect Tasks

// Actions
abstract class AsyncStateWidgetExampleAction implements ReducerAction {}

class AsyncStateWidgetExampleIncrementAction
    implements AsyncStateWidgetExampleAction {}

// Reducer
final asyncStateWidgetExampleReducer = Reducer<
    AsyncStateWidgetExampleState,
    AsyncStateWidgetExampleEnvironment,
    AsyncStateWidgetExampleAction>((state, action) {
  if (action is AsyncStateWidgetExampleIncrementAction) {
    return ReducerTuple(
        AsyncStateWidgetExampleState(count: state.count + 1, foo: state.foo),
        []);
  } else {
    return ReducerTuple(state, []);
  }
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
                        count: 0, foo: AsyncState.initial()),
                    reducer: asyncStateWidgetExampleReducer.debug(
                        name: "asyncStateWidgetExampleReducer"),
                    environment: AsyncStateWidgetExampleEnvironment()));

  @override
  Widget build(context, state, viewStore) {
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
                      loader: (_) => Future.delayed(
                            const Duration(seconds: 5),
                            () => const Foo("Woot woot!"),
                          ),
                      toChildState: (s) => s.foo,
                      fromChildState: (s, cs) => AsyncStateWidgetExampleState(
                            foo: cs,
                            count: s.count,
                          ))),
              state.foo.when(
                  initial: () => const Text('Foo Initial'),
                  loading: () => const Text('Loading...'),
                  data: (v) => Text('data = $v'),
                  error: (e, __) => Text('error = ${e.toString()}')),
              Text(
                '${state.count}',
                style: Theme.of(context).textTheme.headline4,
              ),
              OutlinedButton(
                  onPressed: () =>
                      viewStore.send(AsyncStateWidgetExampleIncrementAction()),
                  child: const Text("increment"))
            ])
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    print("AsyncStateWidgetExampleComponentWidget dispose() called");
    super.dispose();
  }
}
