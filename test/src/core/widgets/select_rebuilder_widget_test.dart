import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:equatable/equatable.dart';
import '../../../utils/app_wrapper.dart';

@immutable
class _MyCounterWidgetState extends Equatable {
  const _MyCounterWidgetState({required this.otherCount, required this.count});

  final int otherCount;
  final int count;

  @override
  List<Object> get props => [otherCount, count];
}

class _MyCounterWidgetEnvironment {
  const _MyCounterWidgetEnvironment();
}

abstract class _MyCounterWidgetAction implements ReducerAction {}

class _MyCounterWidgetIncrementCount extends _MyCounterWidgetAction {}

class _MyCounterWidgetIncrementOtherCount extends _MyCounterWidgetAction {}

final _myCounterReducer = Reducer<_MyCounterWidgetState,
    _MyCounterWidgetEnvironment, _MyCounterWidgetAction>((state, action) {
  if (action is _MyCounterWidgetIncrementCount) {
    return ReducerTuple(
        _MyCounterWidgetState(
            otherCount: state.otherCount, count: state.count + 1),
        []);
  } else if (action is _MyCounterWidgetIncrementOtherCount) {
    return ReducerTuple(
        _MyCounterWidgetState(
            otherCount: state.otherCount + 1, count: state.count),
        []);
  }
  return ReducerTuple(state, []);
});

void main() {
  testWidgets('SelectRebuilder widget rebuilds when state changes',
      (WidgetTester tester) async {
    final store = Store(
        initialState: const _MyCounterWidgetState(otherCount: 0, count: 0),
        reducer: _myCounterReducer,
        environment: const _MyCounterWidgetEnvironment());

    int rebuildCount = 0;

    await tester.pumpWidget(
      appWrapWidget(
        SelectRebuilder(
          store: store,
          select: (s) => s.count,
          builder: (context, state, child) {
            rebuildCount += 1;
            return Text(state.toString());
          },
        ),
      ),
    );

    expect(rebuildCount, 1);

    store.viewStore.send(_MyCounterWidgetIncrementOtherCount());
    await tester.pump();

    expect(rebuildCount, 1);

    store.viewStore.send(_MyCounterWidgetIncrementCount());
    await tester.pump();

    expect(rebuildCount, 2);
  });
}
