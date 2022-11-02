import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';

// State definition
@immutable
class LoadOnInitComponentState {
  const LoadOnInitComponentState({required this.count, required this.name});
  final int count;
  final String name;
}

class LoadOnInitComponentEnvironment {}

// Reducer Action
class LoadOnInitCompnoentAction {
  static ActionTuple<LoadOnInitComponentState, LoadOnInitComponentEnvironment>
      load(LoadOnInitComponentState state) {
    return ActionTuple(
        LoadOnInitComponentState(count: state.count, name: "Loading..."),
        (state, environment) {
      return Future.delayed(const Duration(seconds: 5), () {})
          .then((_) => LoadOnInitCompnoentAction.setName("The Loaded Name"));
    });
  }

  static ReducerAction<LoadOnInitComponentState, LoadOnInitComponentEnvironment>
      setName(String name) {
    return (state) {
      return ActionTuple(
          LoadOnInitComponentState(name: name, count: state.count), null);
    };
  }

  static ActionTuple<LoadOnInitComponentState, LoadOnInitComponentEnvironment>
      increment(LoadOnInitComponentState state) {
    return ActionTuple(
        LoadOnInitComponentState(count: state.count + 1, name: state.name),
        null);
  }
}

// Stateful Widget
class LoadOnInitComponentWidget extends ComponentWidget<
    LoadOnInitComponentState, LoadOnInitComponentEnvironment> {
  LoadOnInitComponentWidget({super.key, required super.store});

  factory LoadOnInitComponentWidget.selfContained() {
    return LoadOnInitComponentWidget(
        store: Store(
            initialState:
                const LoadOnInitComponentState(count: 0, name: "Initial"),
            environment: LoadOnInitComponentEnvironment()));
  }

  @override
  void initState(viewStore) {
    // TODO: figure out why this is needed, figure out if there is a better way to handle this
    // viewStore.send(LoadOnInitCompnoentAction.load);
    //
    // The above will cause an exception if it isn't wrapped in a Future.delayed(Duration.zero like below. I found this Future.delayed thing at the following.
    // https://www.fluttercampus.com/guide/230/setstate-or-markneedsbuild-called-during-build/
    //
    // Maybe this is an acceptable solution and we should just bake it into the ComponentWidget initState proxy so that users don't have to think/worry about it
    //
    // Note: I have tried doing it without the Future.delayed both before and after the super.initState() with no difference, it still blows up.
    Future.delayed(
        Duration.zero, () => viewStore.send(LoadOnInitCompnoentAction.load));
    super.initState(viewStore);
  }

  @override
  Widget build(context, state, viewStore) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load On Init Component'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(children: [
              Text(state.name),
              Text(
                '${state.count}',
                style: Theme.of(context).textTheme.headline4,
              ),
              OutlinedButton(
                  onPressed: () =>
                      viewStore.send(LoadOnInitCompnoentAction.increment),
                  child: const Text("increment"))
            ])
          ],
        ),
      ),
    );
  }
}
