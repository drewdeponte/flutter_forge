library logged_in_user_counter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_forge/flutter_forge.dart';

// State definition
@immutable
class LoggedInUserCounterState {
  const LoggedInUserCounterState({required this.count});
  final int count;
}

@immutable
class LoggedInUserSysState {
  const LoggedInUserSysState({required this.isLoggedIn});
  final bool isLoggedIn;
}

// Reducer Action
LoggedInUserCounterState increment(Ref ref, LoggedInUserCounterState  state) {
  return LoggedInUserCounterState(count: state.count + 1);
}

// Widget
class LoggedInUserCounter extends StatelessWidget {
  const LoggedInUserCounter({super.key, required this.counterStore, required this.sysStore});
  final StoreInterface<LoggedInUserCounterState> counterStore;
  final StoreInterface<LoggedInUserSysState> sysStore;

  @override
  Widget build(BuildContext context) {
    return counterStore.combinedViewBuilder(sysStore, (counterState, counterViewStore, sysState, sysStateViewStore) {
      return Column(children: [
        Text('isLoggedIn: ${sysState.isLoggedIn}'),
        Text('${counterState.count}', style: Theme.of(context).textTheme.headline4,),
        OutlinedButton(
          onPressed: () => counterViewStore.send(increment),
          child: const Text("increment"))
      ]);
    });
  }
}
