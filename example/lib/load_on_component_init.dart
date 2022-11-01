import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';

// State definition
@immutable
class LoadOnInitComponentState {
  const LoadOnInitComponentState({required this.count});
  final int count;
}

class LoadOnInitComponentEnvironment {}

// Reducer Action
class LoadOnInitCompnoentAction {
  static ActionTuple<LoadOnInitComponentState, LoadOnInitComponentEnvironment>
      load(LoadOnInitComponentState state) {
    return ActionTuple(const LoadOnInitComponentState(count: 500), null);
  }

  static ActionTuple<LoadOnInitComponentState, LoadOnInitComponentEnvironment>
      increment(LoadOnInitComponentState state) {
    return ActionTuple(LoadOnInitComponentState(count: state.count + 1), null);
  }
}

// Stateful Widget
class LoadOnInitComponentWidget extends ComponentWidget<
    LoadOnInitComponentState, LoadOnInitComponentEnvironment> {
  LoadOnInitComponentWidget({super.key, required super.store});

  factory LoadOnInitComponentWidget.selfContained() {
    return LoadOnInitComponentWidget(
        store: Store(
            initialState: const LoadOnInitComponentState(count: 0),
            environment: LoadOnInitComponentEnvironment()));
  }

  @override
  void initState(viewStore) {
    viewStore.send(LoadOnInitCompnoentAction.load);
    super.initState(viewStore);
  }

  @override
  Widget build(context, state, viewStore) {
    return Column(children: [
      Text(
        '${state.count}',
        style: Theme.of(context).textTheme.headline4,
      ),
      OutlinedButton(
          onPressed: () => viewStore.send(LoadOnInitCompnoentAction.increment),
          child: const Text("increment"))
    ]);
  }
}
