import 'package:flutter/widgets.dart';

import 'view_store_interface.dart';
import 'reducer_action.dart';

class CombinedViewStore<S, E> implements ViewStoreInterface<S, E> {
  CombinedViewStore(this.converter);

  late BuildContext _context;

  final Function(ReducerAction<S, E> action) converter;

  @override
  void send(ReducerAction<S, E> action) {
    this.converter(action);
    // if action == LoggedInUserCounterAction.increment {
    //   // convert action to counter store action
    //   // send converter counter store action to counter store
    // } else if action == LoggedInUserCounterAction.increment {
    //   // convert action to app state store action
    //   // send converter app store action to app store
    // }
    // // does this action go to parent A or parent B? how do we know?
    // parentViewStore.send(childToParentAction(action));
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  BuildContext context() {
    return _context;
  }
}
