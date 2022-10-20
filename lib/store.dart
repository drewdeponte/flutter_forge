import 'dart:collection';
import 'dart:async';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Two ways I can think of using Riverpod to scope down
// - ref.watch(provider.select(do scoping here))
// - Construct a new provider that is based on a ref.watch() of another provider - this might make the most sense in terms of scoping down from a parent state to a child state

typedef ReducerAction<State> = FutureOr<State> Function(Ref, State);

typedef ViewStoreProvider<State> = StateNotifierProvider<ViewStore<State>, State>;

typedef ViewStoreProviderBuilder<State> = ViewStoreProvider<State> Function(State);

ViewStoreProvider<State> viewStoreProvider<State>(State initialState) {
  return ViewStoreProvider<State>((ref) => ViewStore<State>(ref, initialState));
}

/// Formal Interface for all Store implementations
abstract class StoreInterface<State> {
  /// get ViewStore - object to manage state changes in a controlled unidirectional flow
  ViewStoreInterface<State> viewStore(WidgetRef ref);
  /// escape hatch out of this framework back to Riverpod land
  AlwaysAliveProviderListenable<State> get provider;
  /// register a function to build your widget anytime state changes
  Consumer viewBuilder(Widget Function(State state, ViewStoreInterface<State> viewStore) builder);
  /// scope a stores state concerns down to a portion of it's state
  StoreInterface<ChildState> scope<ChildState>({required ChildState Function(State) globalToLocalState, required ReducerAction<State> Function(ReducerAction<ChildState>) localToGlobalAction});
  /// binding multiple stores to the view
  Consumer combinedViewBuilder<StateB>(StoreInterface<StateB> storeB, Widget Function(State stateA, ViewStoreInterface<State> viewStoreA, StateB stateB, ViewStoreInterface<StateB> viewStoreB) builder);
}

/// Formal Interface for all ViewStore implementations
abstract class ViewStoreInterface<State> {
  /// send/dispatch an action to the store to have it change state in a controlled manner
  void send(ReducerAction<State> action);
}

// Maybe I can give a widget either a store that fully owns it's own state or a
// store that is filtering/transforming state from another store above that
// owns it. The trick though is figuring out how to manage the translaction of
// the actions back up the chain. Although it might not be that hard.

class Store<State> extends StoreInterface<State> {
  Store({required State initialState}): _stateNotifierProvider = viewStoreProvider(initialState);
  final StateNotifierProvider<ViewStore<State>, State> _stateNotifierProvider;

  @override
  AlwaysAliveProviderListenable<State> get provider {
    return _stateNotifierProvider;
  }

  @override
  ViewStore<State> viewStore(WidgetRef ref) {
    return ref.read(_stateNotifierProvider.notifier);
  }

  @override
  Consumer viewBuilder(Widget Function(State state, ViewStoreInterface<State> viewStore) builder) {
    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(_stateNotifierProvider);
      return builder.call(state, viewStore(ref));
    },);
  }

  @override
  StoreInterface<ChildState> scope<ChildState>({required ChildState Function(State) globalToLocalState, required ReducerAction<State> Function(ReducerAction<ChildState>) localToGlobalAction}) {
    return ScopedStore<ChildState, State>(
      parentStore: this,
      stateProvider: Provider<ChildState>((ref) {
        final parentState = ref.watch(_stateNotifierProvider);
        return globalToLocalState.call(parentState);
      }),
      localActionToGlobalAction: localToGlobalAction
    );
  }

  @override
  Consumer combinedViewBuilder<StateB>(StoreInterface<StateB> storeB, Widget Function(State stateA, ViewStoreInterface<State> viewStoreA, StateB stateB, ViewStoreInterface<StateB> viewStoreB) builder) {
    return Consumer(builder: (context, ref, child) {
      final stateA = ref.watch(provider);
      final stateB = ref.watch(storeB.provider);
      return builder.call(stateA, viewStore(ref), stateB, storeB.viewStore(ref));
    });
  }
}

class ScopedStore<State, ParentState> extends StoreInterface<State> {
  final StoreInterface<ParentState> parentStore;
  final Provider<State> stateProvider;
  final ReducerAction<ParentState> Function(ReducerAction<State>) localActionToGlobalAction;

  ScopedStore({required this.parentStore, required this.stateProvider, required this.localActionToGlobalAction});

  @override
  AlwaysAliveProviderListenable<State> get provider {
    return stateProvider;
  }

  @override
  ViewStoreInterface<State> viewStore(WidgetRef ref) {
    return ScopedViewStore(parentStore.viewStore(ref), localActionToGlobalAction);
  }

  @override
  Consumer viewBuilder(Widget Function(State state, ViewStoreInterface<State> viewStore) builder) {
    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(stateProvider);
      return builder.call(state, viewStore(ref));
    });
  }

  @override
  StoreInterface<ChildState> scope<ChildState>({required ChildState Function(State) globalToLocalState, required ReducerAction<State> Function(ReducerAction<ChildState>) localToGlobalAction}) {
    return ScopedStore<ChildState, State>(
      parentStore: this,
      stateProvider: Provider<ChildState>((ref) {
        final parentState = ref.watch(stateProvider);
        return globalToLocalState.call(parentState);
      }),
      localActionToGlobalAction: localToGlobalAction
    );
  }

  @override
  Consumer combinedViewBuilder<StateB>(StoreInterface<StateB> storeB, Widget Function(State stateA, ViewStoreInterface<State> viewStoreA, StateB stateB, ViewStoreInterface<StateB> viewStoreB) builder) {
    return Consumer(builder: (context, ref, child) {
      final stateA = ref.watch(provider);
      final stateB = ref.watch(storeB.provider);
      return builder.call(stateA, viewStore(ref), stateB, storeB.viewStore(ref));
    });
  }
}

// class CombinedStore<State, ParentAState, ParentBState> extends StoreInterface<State> {
//   final StoreInterface<ParentAState> parentAStore;
//   final StoreInterface<ParentBState> parentBStore;
//   final Provider<State> stateProvider;

//   CombinedStore({required this.parentAStore, required this.parentBStore, required this.stateProvider});

//   @override
//   AlwaysAliveProviderListenable<State> get provider {
//     return stateProvider;
//   }

//   // What if I introduce a concept of OwnedState and BorrowedState? Then I might be able to handle the view store
//   @override
//   ViewStoreInterface<State> viewStore(WidgetRef ref) {
//     // CombinedViewStore()
//     return ScopedViewStore(parentStore.viewStore(ref), localActionToGlobalAction);
//   }

//   @override
//   Consumer viewBuilder(Widget Function(State state, ViewStoreInterface<State> viewStore) builder) {
//     return Consumer(builder: (context, ref, child) {
//       final state = ref.watch(stateProvider);
//       return builder.call(state, viewStore(ref));
//     });
//   }

//   @override
//   StoreInterface<ChildState> scope<ChildState>({required ChildState Function(State) globalToLocalState, required ReducerAction<State> Function(ReducerAction<ChildState>) localToGlobalAction}) {
//     return ScopedStore<ChildState, State>(
//       parentStore: this,
//       stateProvider: Provider<ChildState>((ref) {
//         final parentState = ref.watch(stateProvider);
//         return globalToLocalState.call(parentState);
//       }),
//       localActionToGlobalAction: localToGlobalAction
//     );
//   }
// }

// class CombinedViewStore<CombinedState> implements ViewStoreInterface<State> {
//   CombinedViewStore(this.parentViewStore, this.childToParentAction);

//   @override
//   void send(ReducerAction<CombinedState> action) {
//     // ReducerAction<CombinedState> ->  some how need to know if the action is
//     // targeted at impacting the owned state or the borrowed state. If it is at
//     // the owned state then it the action would need to be converted to an
//     // action of the owned state and applied to that store. If it is at the
//     // borrowed state it would need to be converted to an action of borrowed
//     // state and applied to that store.

//     // I guess another option would be somehow having states be identifiable
//     // and expose that identification through the `send` interface and it's
//     // typing so that the user somehow. Either that or we would have to somehow
//     // have multiple stores accessible within a widget.
//     parentViewStore.send(childToParentAction(action));
//   }
// }

// Is this really a borrowed state view store? Or maybe the concept of Scoping is by definition borrowing and focusing
class ScopedViewStore<State, ParentState> implements ViewStoreInterface<State> {
  ScopedViewStore(this.parentViewStore, this.childToParentAction);

  final ViewStoreInterface<ParentState> parentViewStore;
  final ReducerAction<ParentState> Function(ReducerAction<State>) childToParentAction;

  @override
  void send(ReducerAction<State> action) {
    parentViewStore.send(childToParentAction(action));
  }
}

/// Manage state updates in a controlled fashion
class ViewStore<State> extends StateNotifier<State> implements ViewStoreInterface<State> {
  ViewStore(this.ref, State initialState) : super(initialState);
  final Ref ref;
  final Queue<ReducerAction<State>> actionQueue = Queue();
  bool isSending = false;

  @override
  void send(ReducerAction<State> action) {
    actionQueue.addFirst(action);

    if (isSending) {
      return;
    }

    _processQueue();
  }

  Future<void> _processQueue() async {
    isSending = true;

    while (actionQueue.isNotEmpty) {
      final action = actionQueue.removeLast();
      Fimber.d('send($action): begin:');

      try {
        final newState = await action(ref, state);
        Fimber.d('send($action): end:\nnewState: $newState');
        state = newState;
      } catch (error) {
        Fimber.d('error executing action: $action\nerror: $error');
      }
    }

    isSending = false;
  }

  @override
  String toString() => 'ViewStore(ref: $ref)';
}
