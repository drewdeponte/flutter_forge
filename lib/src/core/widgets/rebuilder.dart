import 'package:flutter/widgets.dart';
import '../state_management/store_interface.dart';
import '../state_management/reducer_action.dart';

/// Rebuild a portion of the widget tree when state changes.
///
/// The [Rebuilder] widget is designed be used in combination with
/// [ComponentWidget] to scope rebuilding down to a specific section of
/// the widget tree. This is because the [ComponentWidget] does not
/// automatically rebuild on state change for performance reasons.
@immutable
class Rebuilder<S, E, A extends ReducerAction> extends StatelessWidget {
  final StoreInterface<S, E, A> store;
  final Widget Function(BuildContext context, S state, Widget? child) builder;

  const Rebuilder({super.key, required this.store, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: store.viewStore,
        builder: (context, state, child) {
          return builder(context, state, child);
        });
  }
}
