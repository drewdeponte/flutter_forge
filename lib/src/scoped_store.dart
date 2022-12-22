import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/store_interface.dart';
import 'core/reducer_action.dart';
import 'core/view_store_interface.dart';
import 'scoped_view_store.dart';

class ScopedStore<S, E, A extends ReducerAction, PS, PE,
    PA extends ReducerAction> extends StoreInterface<S, A> {
  final StoreInterface<PS, PA> parentStore;
  final Provider<S> stateProvider;
  final PA Function(A) fromChildAction;

  ScopedStore(
      {required this.parentStore,
      required this.stateProvider,
      required this.fromChildAction});

  @override
  AlwaysAliveProviderListenable<S> get provider {
    return stateProvider;
  }

  @override
  ViewStoreInterface<A> viewStore(WidgetRef ref) {
    return ScopedViewStore(parentStore.viewStore(ref), fromChildAction);
  }

  @override
  StoreInterface<CS, CA> scope<CS, CA extends ReducerAction>(
      {required CS Function(S) toChildState,
      required A Function(CA) fromChildAction}) {
    return ScopedStore(
        parentStore: this,
        stateProvider: Provider<CS>((ref) {
          final parentState = ref.watch(stateProvider);
          return toChildState(parentState);
        }),
        fromChildAction: fromChildAction);
  }
}
