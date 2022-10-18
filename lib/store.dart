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

abstract class StoreInterface<State> {
  ViewStoreInterface<State> viewStore(WidgetRef ref);
  Consumer viewBuilder(Widget Function(State state, ViewStoreInterface<State> viewStore) builder);
  StoreInterface<ChildState> scope<ChildState>({required ChildState Function(State) globalToLocalState, required ReducerAction<State> Function(ReducerAction<ChildState>) localToGlobalAction});
}

abstract class ViewStoreInterface<State> {
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
}

class ScopedStore<State, ParentState> extends StoreInterface<State> {
  final StoreInterface<ParentState> parentStore;
  final Provider<State> stateProvider;
  final ReducerAction<ParentState> Function(ReducerAction<State>) localActionToGlobalAction;

  ScopedStore({required this.parentStore, required this.stateProvider, required this.localActionToGlobalAction});

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
}

class ScopedViewStore<State, ParentState> implements ViewStoreInterface<State> {
  ScopedViewStore(this.parentViewStore, this.childToParentAction);

  final ViewStoreInterface<ParentState> parentViewStore;
  final ReducerAction<ParentState> Function(ReducerAction<State>) childToParentAction;

  @override
  void send(ReducerAction<State> action) {
    parentViewStore.send(childToParentAction(action));
  }
}

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
