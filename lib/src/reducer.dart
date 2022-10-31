import 'reducer_action.dart';
import 'reducer_tuple.dart';

typedef Reducer<S, E> = ReducerTuple<S, E> Function(
    S state, ReducerAction<S, E> action);
