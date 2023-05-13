import 'package:flutter/foundation.dart';
import 'package:flutter_forge/src/utils/selected_value_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

class _SomeState {
  _SomeState({required this.countOne, required this.countTwo});
  final int countOne;
  final int countTwo;
}

void main() {
  group('SelectedValueNotifier', () {
    test('listener only triggered when selected state changes', () async {
      final vn = ValueNotifier(_SomeState(countOne: 0, countTwo: 0));
      final svn = SelectedValueNotifier(vn, (v) => v.countTwo);
      bool listenerCalled = false;
      svn.addListener(() => listenerCalled = true);

      vn.value = _SomeState(countOne: 1, countTwo: 0);

      expect(listenerCalled, false);

      vn.value = _SomeState(countOne: 1, countTwo: 1);

      expect(listenerCalled, true);

      vn.dispose();
      svn.dispose();
    });
  });
}
