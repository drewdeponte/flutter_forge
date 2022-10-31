import 'view_store_interface.dart';
import 'reducer_action.dart';

// Is this really a borrowed state view store? Or maybe the concept of Scoping is by definition borrowing and focusing
class ScopedViewStore<S, E, PS, PE> implements ViewStoreInterface<S, E> {
  ScopedViewStore(this.parentViewStore, this.childToParentAction);

  final ViewStoreInterface<PS, PE> parentViewStore;
  final ReducerAction<PS, PE> Function(ReducerAction<S, E>) childToParentAction;

  @override
  void send(ReducerAction<S, E> action) {
    parentViewStore.send(childToParentAction(action));
  }
}
