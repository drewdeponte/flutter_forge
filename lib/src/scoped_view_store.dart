import 'package:flutter/widgets.dart';

import 'core/view_store_interface.dart';
import 'core/reducer_action.dart';

// Is this really a borrowed state view store? Or maybe the concept of Scoping is by definition borrowing and focusing
class ScopedViewStore<S, E, A extends ReducerAction, PS, PE,
    PA extends ReducerAction> implements ViewStoreInterface<A> {
  ScopedViewStore(this.parentViewStore, this.childToParentAction);

  final ViewStoreInterface<PA> parentViewStore;
  final PA Function(A) childToParentAction;

  @override
  void send(A action) {
    parentViewStore.send(childToParentAction(action));
  }

  void setContext(BuildContext context) {
    parentViewStore.setContext(context);
  }

  BuildContext context() {
    return parentViewStore.context();
  }
}
