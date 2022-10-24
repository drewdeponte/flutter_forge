import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_forge/flutter_forge.dart';

import 'logged_in_user_counter.dart';

@immutable
class SomeStateFromParentOtherOwnedState {
  const SomeStateFromParentOtherOwnedState({required this.count});
  final int count;
}

@immutable
class GlobalAppState {
  const GlobalAppState({required this.isLoggedIn});
  final bool isLoggedIn;
}

SomeStateFromParentOtherOwnedState incrementCount(Ref ref, SomeStateFromParentOtherOwnedState state) {
  return SomeStateFromParentOtherOwnedState(count: state.count + 1);
}

GlobalAppState toggleIsLoggedIn(Ref ref, GlobalAppState state) {
  return GlobalAppState(isLoggedIn: !state.isLoggedIn);
}

final _appStore = Store(initialState: const GlobalAppState(isLoggedIn: false));

class SomeStateFromParentOtherOwned extends ConsumerWidget {
  const SomeStateFromParentOtherOwned({super.key, required this.store});
  final StoreInterface<SomeStateFromParentOtherOwnedState> store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return store.viewBuilder((state, viewStore) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Compose with Parent Owning State'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              LoggedInUserCounter(
                store: Store.combine(
                  storeA: store,
                  storeB: _appStore,
                  build: (myState, appState) => LoggedInUserCounterState(isLoggedIn: appState.isLoggedIn, count: myState.count),
                  converter: (ReducerAction<LoggedInUserCounterState> action) {
                    if (action == LoggedInUserCounterAction.increment) {
                      print("DREW: converted counter increment");
                      viewStore.send(incrementCount);
                    } else if (action == LoggedInUserCounterAction.toggleIsLoggedIn) {
                      print("DREW: converted toggle is logged in");
                      _appStore.viewStore(ref).send(toggleIsLoggedIn);
                    } else if (action == LoggedInUserCounterAction.foo) {
                      print("DREW: swallowed foo");
                    } else {
                      print("YOU LOSE DREW!");
                    }
                  })
              ),
              ElevatedButton(
                onPressed: () { _appStore.viewStore(ref).send(toggleIsLoggedIn); },
                child: const Text('Toggle isLoggedIn')
              )
            ],
          ),
        ),
      );
    });
  }
}
