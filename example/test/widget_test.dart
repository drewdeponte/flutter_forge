import 'package:flutter_forge/flutter_forge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/counter.dart' as counter;
import 'package:flutter/material.dart';

MaterialApp appWrapWidget(Widget widget) {
  return MaterialApp(home: widget);
}

void main() {
  testWidgets('Counter widget increments smoke test',
      (WidgetTester tester) async {
    // Create the widget store
    final store = Store(
        initialState: const counter.State(count: 0),
        reducer: counter.counterReducer,
        environment: counter.Environment());

    // Build our app and trigger a frame.
    await tester.pumpWidget(appWrapWidget(counter.Counter(store: store)));

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

  testWidgets('Counter increments smoke test verifying state via store',
      (WidgetTester tester) async {
    // Create the widget store
    final store = Store(
        initialState: const counter.State(count: 0),
        reducer: counter.counterReducer,
        environment: counter.Environment());

    // Build our app and trigger a frame.
    await tester.pumpWidget(appWrapWidget(counter.Counter(store: store)));

    // Verify that our counter starts at 0.
    expect(store.viewStore.value.count, 0);

    // Tap the 'increment' button and trigger a frame.
    await tester.tap(find.text('increment'));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(store.viewStore.value.count, 1);
  });
}
