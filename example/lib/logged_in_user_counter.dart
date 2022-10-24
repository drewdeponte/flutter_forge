library logged_in_user_counter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_forge/flutter_forge.dart';
// import 'package:flutter_riverpod_composable_arch/some_state_from_parent_other_owned.dart';

@immutable
class LoggedInUserCounterState {
  const LoggedInUserCounterState({required this.isLoggedIn, required this.count});
  final bool isLoggedIn;
  final int count;
}


// enum LoggedInUserCounterAction {
//   foo = 1,
//   bar = 2,
//   car = 3
// }

class LoggedInUserCounterAction {
  static LoggedInUserCounterState increment(Ref ref, LoggedInUserCounterState  state) {
    return LoggedInUserCounterState(isLoggedIn: state.isLoggedIn, count: state.count + 1);
  }

  static LoggedInUserCounterState toggleIsLoggedIn(Ref ref, LoggedInUserCounterState state) {
    return LoggedInUserCounterState(isLoggedIn: !state.isLoggedIn, count: state.count);
  }

  static LoggedInUserCounterState foo(Ref ref, LoggedInUserCounterState state) {
    return LoggedInUserCounterState(isLoggedIn: state.isLoggedIn, count: state.count);
  }
}

// enum LoggedInUserCounterAction {
//   incrementCount(int),
//   toggleIsLoggedIn()
// }

// LoggedInUserCounterState reducer(LoggedInUserCounterState state) {
//   switch state {
//     case incrementCount(by):
//       return LoggedInUserCounterState(isLoggedIn: state.isLoggedIn, count: state.count + by);
//     case toggleIsLoggedIn:
//       return LoggedInUserCounterState(isLoggedIn: !state.isLoggedIn, count: state.count);
//   }
// }

// Reducer Action
// LoggedInUserCounterState increment(Ref ref, LoggedInUserCounterState  state) {
//   return LoggedInUserCounterState(isLoggedIn: state.isLoggedIn, count: state.count + 1);
// }

// Widget
class LoggedInUserCounter extends StatelessWidget {
  const LoggedInUserCounter({super.key, required this.store});
  final StoreInterface<LoggedInUserCounterState> store;

  @override
  Widget build(BuildContext context) {
    return store.viewBuilder((state, viewStore) {
      return Column(children: [
        Text('isLoggedIn: ${state.isLoggedIn}'),
        Text('${state.count}', style: Theme.of(context).textTheme.headline4,),
        OutlinedButton(
          onPressed: () => viewStore.send(LoggedInUserCounterAction.increment),
          child: const Text("increment")),
        OutlinedButton(
          onPressed: () => viewStore.send(LoggedInUserCounterAction.foo),
          child: const Text("foo"))
      ]);
    });
  }
}
