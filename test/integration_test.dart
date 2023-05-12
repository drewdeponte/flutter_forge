import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:equatable/equatable.dart';
import 'utils/app_wrapper.dart';

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
  const _MyCounterWidget({super.key, required super.store});

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
  testWidgets('Counter widget', (WidgetTester tester) async {
    // Create the widget store
    final store = Store(
        initialState: const _MyCounterWidgetState(count: 0),
        reducer: _myCounterReducer,
        environment: const _MyCounterWidgetEnvironment());

    // Build our app and trigger a frame.
    await tester.pumpWidget(appWrapWidget(_MyCounterWidget(store: store)));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the 'increment' button and trigger a frame.
    await tester.tap(find.text('increment'));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
