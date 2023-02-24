import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_forge/flutter_forge.dart';

import 'package:example/load_on_component_init.dart' as load_on_component_init;

void main() {
  group('Load On Component Init Store', () {
    test('when sent Load action loads the name', () async {
      final store = TestStore(
          initialState:
              const load_on_component_init.State(name: "bob", count: 0),
          reducer: load_on_component_init.loadOnComponentInitReducer,
          environment:
              load_on_component_init.Environment(getName: () => 'FooName'));

      final results = await store.send(load_on_component_init.Load());

      // Verify that two actions were received with their associated state
      expect(results.length, 2);

      // Verify that the first action received was the Load action
      expect(results[0].action is load_on_component_init.Load, true);
      // Verify that the first action resulted in the expected State
      expect(results[0].state,
          const load_on_component_init.State(name: 'Loading...', count: 0));

      // Verify that the second action received was the SetName action
      expect(results[1].action is load_on_component_init.SetName, true);
      // Verify that the second action resulted in the expected State
      expect(results[1].state,
          const load_on_component_init.State(name: 'FooName', count: 0));
    });
  });
}
