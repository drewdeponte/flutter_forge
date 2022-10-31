import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';

import 'logged_in_user_counter.dart';

// Normally these app level state, environment, and actions wouldn't be located in this file. But they are here just to make this example complete.
@immutable
class GlobalAppState {
  const GlobalAppState({required this.isLoggedIn});
  final bool isLoggedIn;
}

class AppEnvironment {}

class AppAction {
  static ActionTuple<GlobalAppState, AppEnvironment> toggleIsLoggedIn(
      GlobalAppState state) {
    return ActionTuple(GlobalAppState(isLoggedIn: !state.isLoggedIn), null);
  }
}

final _appStore = Store(
    initialState: const GlobalAppState(isLoggedIn: false),
    environment: AppEnvironment());

// Environment
class SomeStateFromParentOtherOwnedEnvironment {}

// State
@immutable
class SomeStateFromParentOtherOwnedState {
  const SomeStateFromParentOtherOwnedState({required this.count});
  final int count;
}

// Actions
class SomeStateFromParentOtherOwnedAction {
  static ActionTuple<SomeStateFromParentOtherOwnedState,
          SomeStateFromParentOtherOwnedEnvironment>
      incrementCount(SomeStateFromParentOtherOwnedState state) {
    return ActionTuple(
        SomeStateFromParentOtherOwnedState(count: state.count + 1), null);
  }
}

// Widget
class SomeStateFromParentOtherOwned extends ComponentWidget<
    SomeStateFromParentOtherOwnedState,
    SomeStateFromParentOtherOwnedEnvironment> {
  SomeStateFromParentOtherOwned({super.key, required super.store});

  @override
  Widget buildView(context, ref, state, viewStore) {
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
                    build: (myState, appState) => LoggedInUserCounterState(
                        isLoggedIn: appState.isLoggedIn, count: myState.count),
                    converter: (action) {
                      if (action == LoggedInUserCounterAction.increment) {
                        viewStore.send(
                            SomeStateFromParentOtherOwnedAction.incrementCount);
                      } else if (action ==
                          LoggedInUserCounterAction.toggleIsLoggedIn) {
                        _appStore
                            .viewStore(ref)
                            .send(AppAction.toggleIsLoggedIn);
                      } else if (action == LoggedInUserCounterAction.foo) {
                        // intentionally swallow an action
                      }
                    })),
            ElevatedButton(
                onPressed: () {
                  _appStore.viewStore(ref).send(AppAction.toggleIsLoggedIn);
                },
                child: const Text('Toggle isLoggedIn'))
          ],
        ),
      ),
    );
  }
}
