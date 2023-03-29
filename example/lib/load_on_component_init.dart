library load_on_component_init;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';
import 'package:equatable/equatable.dart';

// State definition
@immutable
class State extends Equatable {
  const State({required this.count, required this.name});

  final int count;
  final String name;

  @override
  List<Object> get props => [count, name];
}

class Environment {
  FutureOr<String> Function() getName;
  Environment({required this.getName});
}

// Effect Tasks
final loadNameEffect =
    EffectTask<State, Environment, LoadOnComponentInitAction>(
        (state, environment, context) async {
  final name = await environment.getName();
  return SetName(name);
});

// Actions
abstract class LoadOnComponentInitAction implements ReducerAction {}

class Load implements LoadOnComponentInitAction {}

class SetName implements LoadOnComponentInitAction {
  final String name;
  SetName(this.name);
}

class Increment implements LoadOnComponentInitAction {}

// Reducer
final loadOnComponentInitReducer =
    Reducer<State, Environment, LoadOnComponentInitAction>(
        (State state, LoadOnComponentInitAction action) {
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
class LoadOnInitComponentWidget
    extends ComponentWidget<State, Environment, LoadOnComponentInitAction> {
  LoadOnInitComponentWidget(
      {super.key,
      StoreInterface<State, Environment, LoadOnComponentInitAction>? store})
      : super(
            store: store ??
                Store(
                    initialState: const State(count: 0, name: "Initial"),
                    reducer: loadOnComponentInitReducer.debug(
                        name: "loadOnComponentInit"),
                    environment: Environment(
                        getName: () => Future.delayed(
                            const Duration(seconds: 5),
                            () => 'The Loaded Name'))));

  @override
  void postInitState(viewStore) {
    viewStore.send(Load());
  }

  @override
  Widget build(context, viewStore) {
    // ignore: avoid_print
    print("LoadOnInitComponentWidget build called");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load On Init Component'),
      ),
      body: Center(
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
      ),
    );
  }

  @override
  void dispose() {
    // ignore: avoid_print
    print("LoadOnInitComponentWidget dispose() called");
    super.dispose();
  }
}
