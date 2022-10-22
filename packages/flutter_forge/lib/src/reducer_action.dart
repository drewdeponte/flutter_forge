import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ReducerAction<State> = FutureOr<State> Function(Ref, State);
