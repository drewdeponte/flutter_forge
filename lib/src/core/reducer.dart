import 'reducer_tuple.dart';
import 'reducer_action.dart';

class Reducer<S, E, A extends ReducerAction> {
  Reducer(this.run);
  final ReducerTuple<S, E, A> Function(S state, A action) run;
}
