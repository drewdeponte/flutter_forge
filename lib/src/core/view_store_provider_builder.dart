import 'view_store_provider.dart';
import 'reducer_action.dart';

typedef ViewStoreProviderBuilder<S, E, A extends ReducerAction>
    = ViewStoreProvider<S, E, A> Function(S, E);
