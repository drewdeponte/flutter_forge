import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_forge/flutter_forge.dart';

import 'package:example/counter.dart' as counter;

void main() {
  group('Counter Store', () {
    test('when sent IncrementCounterByOne action it increments the count',
        () async {
      final store = TestStore(
          initialState: const counter.State(count: 0),
          reducer: counter.counterReducer,
          environment: counter.Environment());

      // Send action into the store while collection a list of all the
      // actions and their associated resulting states. This can be more
      // than just the action that you send in as some actions have effects
      // that after being processed send an action back into the store.
      final results = await store.send(counter.IncrementCounterByOne());
      expect(results.length, 1);
      expect(results[0].action is counter.IncrementCounterByOne, true);
      expect(results[0].state, const counter.State(count: 1));
    });
  });
}
