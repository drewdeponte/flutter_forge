import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:equatable/equatable.dart';
import '../../utils/app_wrapper.dart';

@immutable
class _MyCounterWidgetState extends Equatable {
  const _MyCounterWidgetState({required this.count});

  final int count;

  @override
  List<Object> get props => [count];
}

class _MyCounterWidgetEnvironment {
  const _MyCounterWidgetEnvironment();
}

abstract class _MyCounterWidgetAction implements ReducerAction {}

class _MyCounterWidgetIncrementButtonTapped extends _MyCounterWidgetAction {}

final _myCounterReducer = Reducer<_MyCounterWidgetState,
    _MyCounterWidgetEnvironment, _MyCounterWidgetAction>((state, action) {
  if (action is _MyCounterWidgetIncrementButtonTapped) {
    return ReducerTuple(_MyCounterWidgetState(count: state.count + 1), []);
  }
  return ReducerTuple(state, []);
});

class _MyCounterWidget extends ComponentWidget<_MyCounterWidgetState,
    _MyCounterWidgetEnvironment, _MyCounterWidgetAction> {
  // ignore: unused_element
  const _MyCounterWidget(
      {super.key,
      required super.store,
      this.initStateCalled,
      this.postInitStateCalled,
      this.disposeCalled,
      this.listenCalled});

  final void Function()? initStateCalled;
  final void Function()? postInitStateCalled;
  final void Function()? disposeCalled;
  final void Function(BuildContext context, _MyCounterWidgetState state)?
      listenCalled;

  @override
  void initState(viewStore) {
    initStateCalled?.call();
    super.initState(viewStore);
  }

  @override
  void postInitState(viewStore) {
    postInitStateCalled?.call();
    super.postInitState(viewStore);
  }

  @override
  void dispose() {
    disposeCalled?.call();
    super.dispose();
  }

  @override
  void listen(BuildContext context, _MyCounterWidgetState state) {
    listenCalled?.call(context, state);
    super.listen(context, state);
  }

  @override
  Widget build(context, viewStore) {
    return Column(
      children: [
        Rebuilder(
            store: store,
            builder: (context, state, child) {
              return Text(state.count.toString());
            }),
        OutlinedButton(
            onPressed: () {
              viewStore.send(_MyCounterWidgetIncrementButtonTapped());
            },
            child: const Text('increment'))
      ],
    );
  }
}

void main() {
  testWidgets('ComponentWidget shows initial state',
      (WidgetTester tester) async {
    final store = Store(
        initialState: const _MyCounterWidgetState(count: 0),
        reducer: _myCounterReducer,
        environment: const _MyCounterWidgetEnvironment());

    await tester.pumpWidget(appWrapWidget(_MyCounterWidget(store: store)));

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('ComponentWidget allows override of initState',
      (WidgetTester tester) async {
    final store = Store(
        initialState: const _MyCounterWidgetState(count: 0),
        reducer: _myCounterReducer,
        environment: const _MyCounterWidgetEnvironment());

    bool initStateCalled = false;

    await tester.pumpWidget(appWrapWidget(_MyCounterWidget(
        store: store, initStateCalled: () => initStateCalled = true)));

    expect(initStateCalled, true);
  });

  testWidgets('ComponentWidget allows override of postInitState',
      (WidgetTester tester) async {
    final store = Store(
        initialState: const _MyCounterWidgetState(count: 0),
        reducer: _myCounterReducer,
        environment: const _MyCounterWidgetEnvironment());

    bool postInitStateCalled = false;

    await tester.pumpWidget(appWrapWidget(_MyCounterWidget(
        store: store, postInitStateCalled: () => postInitStateCalled = true)));

    expect(postInitStateCalled, true);
  });

  testWidgets('ComponentWidget allows override of dispose',
      (WidgetTester tester) async {
    final store = Store(
        initialState: const _MyCounterWidgetState(count: 0),
        reducer: _myCounterReducer,
        environment: const _MyCounterWidgetEnvironment());

    bool disposeCalled = false;

    await tester.pumpWidget(appWrapWidget(_MyCounterWidget(
        store: store, disposeCalled: () => disposeCalled = true)));
    await tester.pumpAndSettle();
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();

    expect(disposeCalled, true);
  });

  testWidgets('ComponentWidget allows override of listen',
      (WidgetTester tester) async {
    final store = Store(
        initialState: const _MyCounterWidgetState(count: 0),
        reducer: _myCounterReducer,
        environment: const _MyCounterWidgetEnvironment());

    _MyCounterWidgetState listenCalled = const _MyCounterWidgetState(count: 0);

    await tester.pumpWidget(appWrapWidget(_MyCounterWidget(
        store: store, listenCalled: (_, state) => listenCalled = state)));

    store.viewStore.send(_MyCounterWidgetIncrementButtonTapped());
    await tester.pump();

    expect(listenCalled, const _MyCounterWidgetState(count: 1));
  });
}
