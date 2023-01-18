import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'store_interface.dart';
import 'state_management/reducer_action.dart';
import 'state_management/view_store_provider.dart';
import 'state_management/view_store.dart';
import 'state_management/reducer.dart';
import 'scoped_store.dart';

externalProvider<S, SS, E, A extends ReducerAction>(
    NotifierProvider<ViewStore<S, E, A>, S> storeProvider,
    AlwaysAliveProviderListenable<SS> provider,
    S Function(S, SS) toState) {
  return Provider<S>((ref) {
    final storeState = ref.watch(storeProvider);
    final externalProviderState = ref.watch(provider);
    return toState(storeState, externalProviderState);
  });
}

class ExternalProviderConnector<S, SS> {
  final AlwaysAliveProviderListenable<SS> provider;
  final S Function(S, SS) fromExtState;

  ExternalProviderConnector(
      {required this.provider, required this.fromExtState});
}

class Store<S, E, A extends ReducerAction, SS> extends StoreInterface<S, A> {
  Store(
      {required S initialState,
      required Reducer<S, E, A> reducer,
      required E environment,
      ExternalProviderConnector<S, SS>? extProviderConnector})
      : _notifierProvider =
            viewStoreProvider(initialState, reducer, environment) {
    if (extProviderConnector == null) {
      _provider = _notifierProvider;
    } else {
      _provider = externalProvider(_notifierProvider,
          extProviderConnector.provider, extProviderConnector.fromExtState);
    }
  }
  final NotifierProvider<ViewStore<S, E, A>, S> _notifierProvider;
  late final AlwaysAliveProviderListenable<S> _provider;

  @override
  AlwaysAliveProviderListenable<S> get provider {
    return _provider;
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
