import 'package:flutter/widgets.dart';
import 'store_interface.dart';
import 'state_management/view_store_interface.dart';
import 'state_management/reducer_action.dart';

abstract class ComponentWidget<S, E, A extends ReducerAction>
    extends StatefulWidget {
  const ComponentWidget({super.key, required this.store});
  final StoreInterface<S, E, A> store;

  void initState(ViewStoreInterface<S, A> viewStore) {}
  void postInitState(ViewStoreInterface<S, A> viewStore) {}
  void dispose() {}

  Widget build(
      BuildContext context, S state, ViewStoreInterface<S, A> viewStore);

  @override
  createState() => _ComponentState(store);
}

class _ComponentState<S, E, A extends ReducerAction>
    extends State<ComponentWidget> {
  _ComponentState(this.store);
  final StoreInterface<S, E, A> store;

  @override
  void initState() {
    super.initState();
    store.viewStore.context = context;
    widget.initState(store.viewStore);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.postInitState(store.viewStore);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: store.viewStore.listenable,
        builder: (context, child) {
          return widget.build(context, store.viewStore.state, store.viewStore);
        });
  }

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }
}
