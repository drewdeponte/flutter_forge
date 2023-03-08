import 'package:flutter/widgets.dart';
import 'store_interface.dart';
import 'state_management/view_store_interface.dart';
import 'state_management/reducer_action.dart';
import 'package:equatable/equatable.dart';

/// Base intended to be extended to create the widget portion of a Flutter
/// Forge component.
///
/// There are two general strategies for setting up the construction of the
/// component. One where the component owns it's own [Store] and another
/// where it is given its store as a parent owns it.
///
/// The following is an example where the component owns and therefore
/// provides it's own store. You only want this if you want the state to be
/// reset when the widget is destroyed and recreated.
///
/// ```
/// class Counter extends ComponentWidget<State, Environment, CounterAction> {
///   Counter({super.key, StoreInterface<State, Environment, CounterAction>? store})
///     : super(
///            store: store ??
///                Store(
///                    initialState: const State(count: 0),
///                    reducer: counterReducer.debug(name: "counter"),
///                    environment: Environment()));
///
///   @override
///   Widget build(context, state, viewStore) {
///     ...
///   }
/// }
/// ```
///
/// Creating a component where a parent has to own the store is as follows.
/// This is generally what you want if you don't want the state to be reset
/// when the widget is destroyed and created.
///
/// ```
/// class Counter extends ComponentWidget<State, Environment, CounterAction> {
///   Counter({super.key, StoreInterface<State, Environment, CounterAction> store})
///     : super(store: store);
///
///   @override
///   Widget build(context, state, viewStore) {
///     ...
///   }
/// }
/// ```
///
/// [ComponentWidget] is designed to be used in combination with the
/// [Rebuilder] widget to facilitate rebuilding targeted focused sections
/// of the widget tree when state changes rather than rebuilding the entire
/// widget tree. This is more and more important as you do more composition.
abstract class ComponentWidget<S extends Equatable, E, A extends ReducerAction>
    extends StatefulWidget {
  const ComponentWidget({
    super.key,
    required this.store,
  });
  final StoreInterface<S, E, A> store;

  /// Widget lifecycle method that can be overriden to facilitate
  /// initializing state.
  ///
  /// This is especially useful in situations where you want to trigger
  /// fetching of asynchronous state when a widget is created.
  void initState(ViewStoreInterface<S, A> viewStore) {}

  /// Widget lifecycle method that can be overriden to facilitate
  /// performing actions after state initialization.
  ///
  /// This happens at the end of the frame.
  void postInitState(ViewStoreInterface<S, A> viewStore) {}

  /// Widget lifecycle method that can be overiden to facilitate
  /// performing actions when state has changed.
  void listen(BuildContext context, S state) {}

  /// Widget lifecycle method that can be overriden to facilitate
  /// performing actions when the widget is disposed.
  void dispose() {}

  /// Widget [build] method that must be defined by the extending class.
  ///
  /// The [build] method is handed the [context] and the [viewStore] to
  /// facilitate building out its widget tree.
  Widget build(BuildContext context, ViewStoreInterface<S, A> viewStore);

  @override
  createState() => _ComponentState(store);
}

class _ComponentState<S extends Equatable, E, A extends ReducerAction>
    extends State<ComponentWidget> {
  _ComponentState(this.store);
  final StoreInterface<S, E, A> store;

  @override
  void initState() {
    super.initState();
    store.viewStore.context = context;
    store.viewStore.addListener(_triggerListener);
    widget.initState(store.viewStore);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.postInitState(store.viewStore);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.build(context, store.viewStore);
  }

  @override
  void dispose() {
    store.viewStore.removeListener(_triggerListener);
    widget.dispose();
    super.dispose();
  }

  void _triggerListener() {
    widget.listen(context, store.viewStore.state);
  }
}

/// Rebuild a portion of the widget tree when state changes.
///
/// The [Rebuilder] widget is designed be used in combination with
/// [ComponentWidget] to scope rebuilding down to a specific section of
/// the widget tree. This is because the [ComponentWidget] does not
/// automatically rebuild on state change for performance reasons.
class Rebuilder<S extends Equatable, E, A extends ReducerAction>
    extends StatelessWidget {
  final StoreInterface<S, E, A> store;
  final Widget Function(BuildContext context, S state, Widget? child) builder;
  Rebuilder(this.store, this.builder);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: store.viewStore,
        builder: (context, state, child) {
          return this.builder(context, state, child);
        });
  }
}
