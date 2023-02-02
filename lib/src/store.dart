import 'store_interface.dart';
import 'state_management/reducer_action.dart';
import 'state_management/view_store.dart';
import 'state_management/reducer.dart';
import 'state_management/reducer_tuple.dart';
import 'package:flutter/widgets.dart';

class ListenerFunctionViewStoreBinding<S, E, A extends ReducerAction> {
  ListenerFunctionViewStoreBinding(
      {required this.viewStore, required this.listenerFunction});
  final VoidCallback listenerFunction;
  final ViewStore<S, E, A> viewStore;
}

class Store<S, E, A extends ReducerAction> extends StoreInterface<S, E, A> {
  Store(
      {required S initialState,
      required Reducer<S, E, A> reducer,
      required E environment})
      : _environment = environment,
        viewStore = ViewStore(
            initialState: initialState,
            reducer: reducer,
            environment: environment);
  final ViewStore<S, E, A> viewStore;
  final E _environment;
  static final Finalizer<ListenerFunctionViewStoreBinding> _finalizer =
      Finalizer((binding) {
    binding.viewStore.removeListener(binding.listenerFunction);
  });

  @override
  StoreInterface<CS, CE, CA> scope<CS, CA extends ReducerAction, CE>(
      {required CS Function(S) toChildState,
      required A Function(CA) fromChildAction,
      required CE Function(E) toChildEnvironment}) {
    var isDueToChildAction = false;
    // Handle actions happening in the child and being handled in the parent
    final childReducer = Reducer<CS, CE, CA>((CS childState, CA childAction) {
      isDueToChildAction = true;
      final parentAction = fromChildAction(childAction);
      this.viewStore.send(parentAction);
      final newChildState = toChildState(this.viewStore.state);
      isDueToChildAction = false;

      return ReducerTuple(newChildState, []);
    });

    final childStore = Store(
        initialState: toChildState(viewStore.state),
        reducer: childReducer,
        environment: toChildEnvironment(_environment));

    // Handle state changing in the parent and it updating the child
    final syncParentToChildState = () {
      if (isDueToChildAction) {
        return;
      } else {
        childStore.viewStore.state = toChildState(this.viewStore.state);
      }
    };

    this.viewStore.addListener(syncParentToChildState);
    final listenerViewStoreBinding = ListenerFunctionViewStoreBinding(
        viewStore: this.viewStore, listenerFunction: syncParentToChildState);
    _finalizer.attach(childStore, listenerViewStoreBinding, detach: childStore);

    return childStore;
  }
}
