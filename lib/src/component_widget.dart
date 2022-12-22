import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/store_interface.dart';
import 'core/view_store_interface.dart';
import 'core/reducer_action.dart';

abstract class ComponentWidget<S, A extends ReducerAction>
    extends ConsumerStatefulWidget {
  ComponentWidget({super.key, required this.store});
  final StoreInterface<S, A> store;

  void initState(ViewStoreInterface<A> viewStore) {}
  void postInitState(ViewStoreInterface<A> viewStore) {}
  void dispose() {}

  Widget build(BuildContext context, S state, ViewStoreInterface<A> viewStore);

  @override
  createState() => _ComponentState(store);
}

class _ComponentState<S, A extends ReducerAction>
    extends ConsumerState<ComponentWidget> {
  _ComponentState(this.store);
  final StoreInterface<S, A> store;

  @override
  WidgetRef get ref => context as WidgetRef;

  @override
  void initState() {
    super.initState();
    store.viewStore(ref).setContext(context);
    widget.initState(store.viewStore(ref));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.postInitState(store.viewStore(ref));
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(store.provider);
    return widget.build(context, state, store.viewStore(ref));
  }

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }
}
