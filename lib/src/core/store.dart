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
      : _notifierProvider =
            viewStoreProvider(initialState, reducer, environment);
  final NotifierProvider<ViewStore<S, E, A>, S> _notifierProvider;

  @override
  AlwaysAliveProviderListenable<S> get provider {
    return _notifierProvider;
  }

  @override
  ViewStore<S, E, A> viewStore(WidgetRef ref) {
    return ref.read(_notifierProvider.notifier);
  }

  @override
  StoreInterface<CS, CA> scope<CS, CA extends ReducerAction>(
      {required CS Function(S) toChildState,
      required A Function(CA) fromChildAction}) {
    return ScopedStore(
        parentStore: this,
        stateProvider: Provider<CS>((ref) {
          final parentState = ref.watch(_notifierProvider);
          return toChildState(parentState);
        }),
        fromChildAction: fromChildAction);
  }
}
