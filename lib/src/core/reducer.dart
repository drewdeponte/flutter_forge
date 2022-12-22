import 'reducer_tuple.dart';
import 'reducer_action.dart';

typedef Reducer<S, E, A extends ReducerAction> = ReducerTuple<S, E, A> Function(
    S state, A action);
