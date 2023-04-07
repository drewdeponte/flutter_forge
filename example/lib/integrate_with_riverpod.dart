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

ourRiverpodActionHandler(
    WidgetRef ref, State state, IntegrateWithRiverpodAction action) {
  if (action is Increment) {
    ref.read(countNotifierProvider.notifier).increment();
  }
}

/// Use a Flutter Forge component inside a Riverpod widget
///
/// This is a RiverpodWidget that wraps a Flutter Forge component and
/// provides the interface to define the mapping between the Flutter Forge
/// components Actions & State to Riverpod side of the would while also
/// observing the provided provider for changes and rebuilding the Flutter
/// Forge component when it changes.
///
/// provider - the Riverpod provider that will be observed for state changes and propagated to the Flutter Forge component
/// actionHandler - function responsible for interpreting the State and Action and handling it, could be by calling a Riverpod Notifier method, or anything
/// environment - the environment of the Flutter Forge component to faciliate dependency injection
/// reducer - optionally provider a Flutter Forge reducer for the component if you want its default logic, otherwise only the actionHandler will be used
@immutable
class RiverpodWrappedFlutterForgeComponent<S extends Equatable, E,
    A extends ReducerAction> extends ConsumerWidget {
  final ProviderBase<S> provider;
  final Reducer<S, E, A>? reducer;
  final Function(WidgetRef ref, S state, A action) actionHandler;
  final E environment;
  final ComponentWidget<S, E, A> Function(Store<S, E, A> store) builder;

  const RiverpodWrappedFlutterForgeComponent(
      {super.key,
      required this.provider,
      required this.actionHandler,
      required this.environment,
      this.reducer,
      required this.builder});

  @override
  Widget build(context, ref) {
    final state = ref.watch(provider);
    final store = Store(
        initialState: state,
        reducer: reducer != null
            ? Reducer.combine(reducer!, riverpodReducer(ref, actionHandler))
            : riverpodReducer(ref, actionHandler),
        environment: environment);
    return builder(store);
  }

  Reducer<S, E, A> riverpodReducer(
      WidgetRef ref, Function(WidgetRef ref, S state, A action) actionHandler) {
    return Reducer<S, E, A>((state, action) {
      actionHandler(ref, state, action);
      return ReducerTuple(state, []);
    });
  }
}

@immutable
class MyRiverpodReadonlyWidget extends ConsumerWidget {
  const MyRiverpodReadonlyWidget({super.key});

  @override
  Widget build(context, ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load On Init Component'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RiverpodWrappedFlutterForgeComponent(
                provider: countNotifierProvider,
                actionHandler: ourRiverpodActionHandler,
                environment: Environment(getName: () => "someString"),
                reducer: integrateWithRiverpodReducer,
                builder: (store) {
                  return IntegrateWithRiverpodComponentWidget(store: store);
                }),
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
