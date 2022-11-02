import 'dart:async';
import 'reducer_action.dart';

typedef EffectTask<S, E> = Future<ReducerAction<S, E>?> Function(
    S state, E environment);
