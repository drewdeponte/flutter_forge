import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'store_interface.dart';
import 'view_store_interface.dart';

abstract class ComponentWidget<S, E> extends ConsumerStatefulWidget {
  ComponentWidget({super.key, required this.store});
  final StoreInterface<S, E> store;

  void initState(ViewStoreInterface<S, E> viewStore) {}

  Widget build(
      BuildContext context, S state, ViewStoreInterface<S, E> viewStore);

  @override
  createState() => _ComponentState(store);
}

class _ComponentState<S, E> extends ConsumerState<ComponentWidget> {
  _ComponentState(this.store);
  final StoreInterface<S, E> store;

  @override
  WidgetRef get ref => context as WidgetRef;

  @override
  void initState() {
    widget.initState(store.viewStore(ref));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(store.provider);
    return widget.build(context, state, store.viewStore(ref));
  }
}
