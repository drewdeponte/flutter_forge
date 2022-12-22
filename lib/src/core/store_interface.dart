import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'view_store_interface.dart';
import 'reducer_action.dart';

/// Formal Interface for all Store implementations
abstract class StoreInterface<S, A extends ReducerAction> {
  /// get ViewStore - object to manage state changes in a controlled unidirectional flow
  ViewStoreInterface<A> viewStore(WidgetRef ref);

  /// escape hatch out of this framework back to Riverpod land
  AlwaysAliveProviderListenable<S> get provider;

  /// scope a stores state concerns down to a portion of it's state
  StoreInterface<CS, CA> scope<CS, CA extends ReducerAction>(
      {required CS Function(S) toChildState,
      required A Function(CA) fromChildAction});
}
