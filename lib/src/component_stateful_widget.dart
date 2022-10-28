import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'store_interface.dart';
import 'view_store_interface.dart';

abstract class ComponentStatefulWidget<S> extends ConsumerStatefulWidget {
  ComponentStatefulWidget({super.key, required this.store});
  final StoreInterface<S> store;
}

abstract class ComponentStatefulWidgetState<S, W extends ComponentStatefulWidget<S>> extends ConsumerState<W> {
  ComponentStatefulWidgetState({required this.store});
  final StoreInterface<S> store;

  Widget buildView(BuildContext context, WidgetRef ref, S state, ViewStoreInterface<S> viewStore);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(store.provider);
    return buildView(context, ref, state, store.viewStore(ref));
  }
}
