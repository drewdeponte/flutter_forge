import 'store_interface.dart';
import 'state_management/reducer_action.dart';
import 'state_management/view_store.dart';
import 'state_management/reducer.dart';
import 'state_management/reducer_tuple.dart';
import 'listener_function_view_store_binding.dart';
import 'package:equatable/equatable.dart';

class Store<S extends Equatable, E, A extends ReducerAction>
    extends StoreInterface<S, E, A> {
  Store(
      {required S initialState,
      required Reducer<S, E, A> reducer,
      required E environment})
      : _environment = environment,
        viewStore = ViewStore(
            initialState: initialState,
            reducer: reducer,
            environment: environment);
  @override
  final ViewStore<S, E, A> viewStore;
  final E _environment;
  static final Finalizer<ListenerFunctionViewStoreBinding> _finalizer =
      Finalizer((binding) {
    binding.viewStore.removeListener(binding.listenerFunction);
  });

  @override
  StoreInterface<CS, CE, CA>
      scopeParentHandles<CS extends Equatable, CA extends ReducerAction, CE>(
          {required CS Function(S) toChildState,
          required A Function(CA) fromChildAction,
          required CE Function(E) toChildEnvironment}) {
    var isDueToChildAction = false;
    // Handle actions happening in the child and being handled in the parent
    final childReducer = Reducer<CS, CE, CA>((CS childState, CA childAction) {
      isDueToChildAction = true;
      final parentAction = fromChildAction(childAction);
      viewStore.send(parentAction);
      final newChildState = toChildState(viewStore.state);
      isDueToChildAction = false;

      return ReducerTuple(newChildState, []);
    });

    final childStore = Store(
        initialState: toChildState(viewStore.state),
        reducer: childReducer,
        environment: toChildEnvironment(_environment));

    // Handle state changing in the parent and it updating the child
    final weakChildStore = WeakReference(childStore);
    final weakParentStore = WeakReference(this);
    // ignore: prefer_function_declarations_over_variables
    final syncParentToChildState = () {
      if (isDueToChildAction) {
        return;
      } else {
        if (weakChildStore.target != null && weakParentStore.target != null) {
          weakChildStore.target!.viewStore.state =
              toChildState(weakParentStore.target!.viewStore.state);
        }
      }
    };

    viewStore.addListener(syncParentToChildState);
    final listenerViewStoreBinding = ListenerFunctionViewStoreBinding(
        viewStore: viewStore, listenerFunction: syncParentToChildState);
    _finalizer.attach(childStore, listenerViewStoreBinding, detach: childStore);

    return childStore;
  }

  @override
  StoreInterface<CS, CE, CA>
      scopeSyncState<CS extends Equatable, CA extends ReducerAction, CE>(
          {required CS Function(S) toChildState,
          required S Function(S, CS) fromChildState,
          required Reducer<CS, CE, CA> childReducer,
          required CE Function(E) toChildEnvironment}) {
    final childStore = Store(
        initialState: toChildState(viewStore.state),
        reducer: childReducer,
        environment: toChildEnvironment(_environment));

    final weakChildStore = WeakReference(childStore);
    final weakParentStore = WeakReference(this);

    // listen to parent and sync state to child
    // ignore: prefer_function_declarations_over_variables
    final syncParentToChildState = () {
      if (weakChildStore.target != null && weakParentStore.target != null) {
        weakChildStore.target!.viewStore.state =
            toChildState(weakParentStore.target!.viewStore.state);
      }
    };
    viewStore.addListener(syncParentToChildState);
    final parentListenerViewStoreBinding = ListenerFunctionViewStoreBinding(
        viewStore: viewStore, listenerFunction: syncParentToChildState);
    _finalizer.attach(childStore, parentListenerViewStoreBinding,
        detach: childStore);

    // listen to child and sync state to the parent
    // ignore: prefer_function_declarations_over_variables
    final syncChildToParentState = () {
      if (weakChildStore.target != null && weakParentStore.target != null) {
        weakParentStore.target!.viewStore.state = fromChildState(
            weakParentStore.target!.viewStore.state,
            weakChildStore.target!.viewStore.state);
      }
    };
    childStore.viewStore.addListener(syncChildToParentState);
    final childListenerViewStoreBinding = ListenerFunctionViewStoreBinding(
        viewStore: viewStore, listenerFunction: syncChildToParentState);
    _finalizer.attach(this, childListenerViewStoreBinding, detach: this);

    return childStore;
  }

  @override
  StoreInterface<CS, CE, CA> scopeForwardActionsAndSyncState<
          CS extends Equatable, CA extends ReducerAction, CE>(
      {required CS Function(S) toChildState,
      required S Function(S, CS) fromChildState,
      required A Function(CA) fromChildAction,
      required Reducer<CS, CE, CA> childReducer,
      required CE Function(E) toChildEnvironment}) {
    final propagateActionReducer = Reducer<CS, CE, CA>((state, action) {
      final reducerTuple = childReducer.run(state, action);
      final parentAction = fromChildAction(action);
      viewStore.send(parentAction);
      return reducerTuple;
    });

    return scopeSyncState(
        toChildState: toChildState,
        fromChildState: fromChildState,
        childReducer: propagateActionReducer,
        toChildEnvironment: toChildEnvironment);
  }
}
