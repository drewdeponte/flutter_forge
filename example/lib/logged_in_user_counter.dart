library logged_in_user_counter;

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';

// Environment
class LoggedInUserCounterEnvironment {}

// State
@immutable
class LoggedInUserCounterState {
  const LoggedInUserCounterState(
      {required this.isLoggedIn, required this.count});
  final bool isLoggedIn;
  final int count;
}

// Actions
class LoggedInUserCounterAction {
  static ActionTuple<LoggedInUserCounterState, LoggedInUserCounterEnvironment>
      increment(LoggedInUserCounterState state) {
    return ActionTuple(
        LoggedInUserCounterState(
            isLoggedIn: state.isLoggedIn, count: state.count + 1),
        null);
  }

  static ActionTuple<LoggedInUserCounterState, LoggedInUserCounterEnvironment>
      toggleIsLoggedIn(LoggedInUserCounterState state) {
    return ActionTuple(
        LoggedInUserCounterState(
            isLoggedIn: !state.isLoggedIn, count: state.count),
        null);
  }

  static ActionTuple<LoggedInUserCounterState, LoggedInUserCounterEnvironment>
      foo(LoggedInUserCounterState state) {
    return ActionTuple(
        LoggedInUserCounterState(
            isLoggedIn: state.isLoggedIn, count: state.count),
        null);
  }
}

// Widget
class LoggedInUserCounter extends StatelessWidget {
  const LoggedInUserCounter({super.key, required this.store});
  final StoreInterface<LoggedInUserCounterState, LoggedInUserCounterEnvironment>
      store;

  @override
  Widget build(BuildContext context) {
    return store.viewBuilder((state, viewStore) {
      return Column(children: [
        Text('isLoggedIn: ${state.isLoggedIn}'),
        Text(
          '${state.count}',
          style: Theme.of(context).textTheme.headline4,
        ),
        OutlinedButton(
            onPressed: () =>
                viewStore.send(LoggedInUserCounterAction.increment),
            child: const Text("increment")),
        OutlinedButton(
            onPressed: () => viewStore.send(LoggedInUserCounterAction.foo),
            child: const Text("foo"))
      ]);
    });
  }
}
