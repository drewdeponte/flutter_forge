import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ReducerAction<S> = FutureOr<S> Function(Ref, S);
