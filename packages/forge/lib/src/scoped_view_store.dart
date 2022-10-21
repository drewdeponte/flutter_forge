import 'view_store_interface.dart';
import 'reducer_action.dart';

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
