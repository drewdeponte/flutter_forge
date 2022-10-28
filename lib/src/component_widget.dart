import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'store_interface.dart';
import 'view_store_interface.dart';

abstract class ComponentWidget<S> extends ConsumerWidget {
  ComponentWidget({super.key, required this.store});
  final StoreInterface<S> store;

  Widget buildView(BuildContext context, WidgetRef ref, S state, ViewStoreInterface<S> viewStore);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(store.provider);
    return buildView(context, ref, state, store.viewStore(ref));
  }
}
