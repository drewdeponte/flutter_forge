import 'dart:async';
import 'reducer_action.dart';

typedef EffectTask<S, E> = FutureOr<ReducerAction<S, E>?> Function(
    E environment);
