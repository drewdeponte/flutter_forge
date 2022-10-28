import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_forge/flutter_forge.dart';

// State definition
@immutable
class LoadOnInitComponentState {
  const LoadOnInitComponentState({required this.count});
  final int count;
}

// Reducer Action
class LoadOnInitCompnoentAction {
  static LoadOnInitComponentState load(Ref ref, LoadOnInitComponentState state) {
    return const LoadOnInitComponentState(count: 500);
  }

  static LoadOnInitComponentState increment(Ref ref, LoadOnInitComponentState state) {
    return LoadOnInitComponentState(count: state.count + 1);
  }
}

// Stateful Widget
class LoadOnInitComponentWidget extends ComponentStatefulWidget<LoadOnInitComponentState> {
  LoadOnInitComponentWidget ({super.key, required super.store});

  @override
  // ignore: no_logic_in_create_state
  LoadOnInitComponentWidgetState createState() => LoadOnInitComponentWidgetState(store: store);
}

class LoadOnInitComponentWidgetState extends ComponentStatefulWidgetState<LoadOnInitComponentState, LoadOnInitComponentWidget> {
  LoadOnInitComponentWidgetState({required super.store});
  @override
  void initState() {
    super.initState();
    // "ref" can be used in all life-cycles of a StatefulWidget.
    store.viewStore(ref).send(LoadOnInitCompnoentAction.load);
  }

  @override
  Widget buildView(context, ref, state, viewStore) {
    return Column(children: [
      Text('${state.count}', style: Theme.of(context).textTheme.headline4,),
      OutlinedButton(
        onPressed: () => viewStore.send(LoadOnInitCompnoentAction.increment),
        child: const Text("increment"))
    ]);
  }
}
