import 'view_store_interface.dart';
import 'reducer_action.dart';

class CombinedViewStore<State, NewState> implements ViewStoreInterface<State> {
  CombinedViewStore(this.converter);

  final Function(ReducerAction<State> action) converter;

  @override
  void send(ReducerAction<State> action) {
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
}