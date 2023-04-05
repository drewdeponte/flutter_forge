import 'package:flutter/widgets.dart';
import 'store_interface.dart';
import 'state_management/reducer_action.dart';
import 'package:equatable/equatable.dart';
import 'selected_value_notifier.dart';

/// Rebuild a portion of the widget tree when a selected portion of state changes.
///
/// The [SelectRebuilder] widget is designed be used in combination with
/// [ComponentWidget] to scope rebuilding down to a specific section of
/// the widget tree. This is because the [ComponentWidget] does not
/// automatically rebuild on state change for performance reasons.
///
/// [SelectRebuilder] takes a store from the [ComponentWidget] and a `select`
/// function that is responsible for taking in the stores state and returning
/// the piece of that state which you want to trigger rebuild on. It also takes
/// the `bulider` function in to build a widget based on changed value.
@immutable
class SelectRebuilder<S extends Equatable, E, A extends ReducerAction, T>
    extends StatelessWidget {
  final StoreInterface<S, E, A> store;
  final T Function(S) select;
  final Widget Function(BuildContext context, T value, Widget? child) builder;

  const SelectRebuilder(
      {super.key,
      required this.store,
      required this.select,
      required this.builder});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: SelectedValueNotifier(store.viewStore, select),
        builder: (context, t, child) {
          return builder(context, t, child);
        });
  }
}
