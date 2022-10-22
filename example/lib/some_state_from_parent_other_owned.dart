import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_forge/flutter_forge.dart';

import 'logged_in_user_counter.dart';

@immutable
class SomeStateFromParentOtherOwnedState {
  const SomeStateFromParentOtherOwnedState({required this.isLoggedIn});
  final bool isLoggedIn;
}

SomeStateFromParentOtherOwnedState toggleIsLoggedIn(Ref ref, SomeStateFromParentOtherOwnedState state) {
  return SomeStateFromParentOtherOwnedState(isLoggedIn: !state.isLoggedIn);
}

final _counterStore = Store(initialState: const LoggedInUserCounterState(count: 0));

class SomeStateFromParentOtherOwned extends StatelessWidget {
  const SomeStateFromParentOtherOwned({super.key, required this.store});
  final StoreInterface<SomeStateFromParentOtherOwnedState> store;

  @override
  Widget build(BuildContext context) {
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
                sysStore: store.scope(
                  globalToLocalState: (state) => LoggedInUserSysState(isLoggedIn: state.isLoggedIn),
                  localToGlobalAction: (localAction) {
                    return (Ref ref, SomeStateFromParentOtherOwnedState state) async {
                      return state;
                    };
                  },),
                counterStore: _counterStore,
              ),
              ElevatedButton(
                onPressed: () { viewStore.send(toggleIsLoggedIn); },
                child: const Text('Toggle isLoggedIn')
              )
            ],
          ),
        ),
      );
    });
  }
}
