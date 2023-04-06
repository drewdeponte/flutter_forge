import 'package:flutter/widgets.dart';

/// Create a value notifier based on a selection of another value notifier
///
/// This creates a new value notifier that will listen to changes from the
/// given parentValueNotifier and when changes are observed in the
/// parentValueNotifier it selects the portion of the parentValueNotifier
/// value it cares about, by using the provided `select` function, and then
/// updates the value of the [SelectedValueNotifier] in turn notifying its
/// observers.
class SelectedValueNotifier<S, T> extends ValueNotifier<T> {
  final ValueNotifier<S> parentValueNotifier;
  final T Function(S) select;

  SelectedValueNotifier(this.parentValueNotifier, this.select)
      : super(select(parentValueNotifier.value)) {
    parentValueNotifier.addListener(selector);
  }

  void selector() {
    value = select(parentValueNotifier.value);
  }

  @override
  void dispose() {
    parentValueNotifier.removeListener(selector);
    super.dispose();
  }
}
