import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'store_interface.dart';
import 'reducer_action.dart';
import 'view_store_provider.dart';
import 'view_store.dart';
import 'reducer.dart';
import '../scoped_store.dart';

class Store<S, E, A extends ReducerAction> extends StoreInterface<S, A> {
  Store(
      {required S initialState,
      required Reducer<S, E, A> reducer,
      required E environment})
      : _stateNotifierProvider =
            viewStoreProvider(initialState, reducer, environment);
  final StateNotifierProvider<ViewStore<S, E, A>, S> _stateNotifierProvider;

  @override
  AlwaysAliveProviderListenable<S> get provider {
    return _stateNotifierProvider;
  }

  @override
  ViewStore<S, E, A> viewStore(WidgetRef ref) {
    return ref.read(_stateNotifierProvider.notifier);
  }

  @override
  StoreInterface<CS, CA> scope<CS, CA extends ReducerAction>(
      {required CS Function(S) toChildState,
      required A Function(CA) fromChildAction}) {
    return ScopedStore(
        parentStore: this,
        stateProvider: Provider<CS>((ref) {
          final parentState = ref.watch(_stateNotifierProvider);
          return toChildState(parentState);
        }),
        fromChildAction: fromChildAction);
  }
}
