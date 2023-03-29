library integrate_with_riverpod;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State definition
@immutable
class State extends Equatable {
  const State({required this.count, required this.name});

  final int count;
  final String name;

  @override
  List<Object> get props => [count, name];
}

// Environment
class Environment {
  FutureOr<String> Function() getName;
  Environment({required this.getName});
}

// Effect Tasks
final loadNameEffect =
    EffectTask<State, Environment, IntegrateWithRiverpodAction>(
        (state, environment, context) async {
  final name = await environment.getName();
  return SetName(name);
});

// Actions
abstract class IntegrateWithRiverpodAction implements ReducerAction {}

class Load implements IntegrateWithRiverpodAction {}

class SetName implements IntegrateWithRiverpodAction {
  final String name;
  SetName(this.name);
}

class Increment implements IntegrateWithRiverpodAction {}

// Reducer
final integrateWithRiverpodReducer =
    Reducer<State, Environment, IntegrateWithRiverpodAction>(
        (State state, IntegrateWithRiverpodAction action) {
  if (action is Load) {
    return ReducerTuple(
        State(count: state.count, name: "Loading..."), [loadNameEffect]);
  } else if (action is SetName) {
    return ReducerTuple(State(count: state.count, name: action.name), []);
  } else if (action is Increment) {
    return ReducerTuple(State(count: state.count + 1, name: state.name), []);
  } else {
    return ReducerTuple(state, []);
  }
});

// Stateful Widget
class IntegrateWithRiverpodComponentWidget
    extends ComponentWidget<State, Environment, IntegrateWithRiverpodAction> {
  const IntegrateWithRiverpodComponentWidget({super.key, required super.store});

  @override
  void postInitState(viewStore) {
    viewStore.send(Load());
  }

  @override
  Widget build(context, viewStore) {
    // ignore: avoid_print
    print("IntegrateWithRiverpodComponentWidget build called");
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Rebuilder(
              store: store,
              builder: (context, state, child) {
                return Column(children: [
                  Text(state.name),
                  Text(
                    '${state.count}',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  OutlinedButton(
                      onPressed: () => viewStore.send(Increment()),
                      child: const Text("increment"))
                ]);
              })
        ],
      ),
    );
  }

  @override
  void dispose() {
    // ignore: avoid_print
    print("IntegrateWithRiverpodComponentWidget dispose() called");
    super.dispose();
  }
}

// Riverpod stuff
class CountNotifier extends Notifier<State> {
  @override
  State build() {
    return const State(count: 0, name: '');
  }

  addFive() {
    state = State(count: state.count + 5, name: '');
  }

  increment() {
    state = State(count: state.count + 1, name: '');
  }
}

final countNotifierProvider =
    NotifierProvider<CountNotifier, State>(CountNotifier.new);

Reducer<S, E, A>
    riverpodReducer<S extends Equatable, E, A extends ReducerAction>(
        WidgetRef ref,
        Function(WidgetRef ref, S state, A action) actionHandler) {
  return Reducer((state, action) {
    actionHandler(ref, state, action);
    return ReducerTuple(state, []);
  });
}

ourRiverpodActionHandler(
    WidgetRef ref, State state, IntegrateWithRiverpodAction action) {
  if (action is Increment) {
    ref.read(countNotifierProvider.notifier).increment();
  }
}

// Read-only case
@immutable
class MyRiverpodReadonlyWidget extends ConsumerWidget {
  const MyRiverpodReadonlyWidget({super.key});

  @override
  Widget build(context, ref) {
    final state = ref.watch(countNotifierProvider);

    final store = Store(
        initialState: state,
        reducer: Reducer.combine(
            integrateWithRiverpodReducer,
            riverpodReducer<State, Environment, IntegrateWithRiverpodAction>(
                ref, ourRiverpodActionHandler)),
        // reducer: Reducer.combine(integrateWithRiverpodReducer,
        //     riverpodReducer(ref, ourRiverpodActionHandler)),
        environment: Environment(getName: () => "someString"));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Load On Init Component'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IntegrateWithRiverpodComponentWidget(store: store),
            OutlinedButton(
                onPressed: () =>
                    ref.read(countNotifierProvider.notifier).addFive(),
                child: const Text("parent riverpod increment by 5"))
          ],
        ),
      ),
    );
  }
}
