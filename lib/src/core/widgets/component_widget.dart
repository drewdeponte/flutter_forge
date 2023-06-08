import 'package:flutter/widgets.dart';
import '../state_management/store_interface.dart';
import '../state_management/view_store_interface.dart';
import '../state_management/reducer_action.dart';

/// Base intended to be extended to create the widget portion of a Flutter
/// Forge component.
///
/// There are two general strategies for setting up the construction of the
/// component. One where the component owns it's own [Store] and another
/// where it is given its store as some parent owns it.
///
/// The following is an example where the component owns and therefore
/// provides it's own store. You only want this if you want the state to be
/// reset when the widget is destroyed and recreated.
///
/// ```
/// class Counter extends ComponentWidget<State, Environment, CounterAction> {
///   Counter({super.key, StoreInterface<State, Environment, CounterAction>? store, super.builder})
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
///   const Counter({super.key, required super.store, super.builder});
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
///
/// [ComponentWidget] has an optional `builder` argument in it's constructor.
/// When you define your component widget constructor, make sure sure to proxy
/// that argument through to ComponentWidget using `super.builder` as shown in
/// the example above. This is important as the `builder` argument is a mechanism
/// provided to allow consumers of widgets to override the body of the component
/// without having to create a new widget that inherits from the component's
/// widget, and then overrides the `body` method. Using this would look something
/// like the following.
///
/// Counter(
///     store: counterStore,
///     builder: (context, store, viewStore) {
///         return const Text('override of ui')
///     },
/// )
///
/// The inheritance based approach to overriding the UI of a component would look
/// as follows.
///
/// class MyCounter extends Counter {
///     const MyCounter({super.key, required super.store, super.builder});
///
///     @override
///     Widget build(context, viewStore) {
///         return const Text('override of ui');
///     }
/// }
abstract class ComponentWidget<S, E, A extends ReducerAction>
    extends StatefulWidget {
  const ComponentWidget({
    super.key,
    required this.store,
    this.builder,
  });
  final StoreInterface<S, E, A> store;
  final Widget Function(BuildContext context, StoreInterface<S, E, A> store,
      ViewStoreInterface<S, A> viewStore)? builder;

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
  // ignore: no_logic_in_create_state
  createState() => _ComponentState(store);
}

class _ComponentState<S, E, A extends ReducerAction>
    extends State<ComponentWidget<S, E, A>> {
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
    if (widget.builder == null) return widget.build(context, store.viewStore);
    return widget.builder!.call(context, store, store.viewStore);
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
