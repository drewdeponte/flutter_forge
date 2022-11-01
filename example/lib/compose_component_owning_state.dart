import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';

import 'counter.dart';

class ComposeComponentOwningStateEnvironment {}

class ComposeComponentOwningStateState {
  ComposeComponentOwningStateState(this.name);
  String name;
}

class ComposeComponentOwningStateAction {
  static ActionTuple<ComposeComponentOwningStateState,
          ComposeComponentOwningStateEnvironment>
      appendYourMom(ComposeComponentOwningStateState state) {
    return ActionTuple(
        ComposeComponentOwningStateState("${state.name} your mom"), null);
  }
}

class ComposeComponentOwningState extends ComponentWidget<
    ComposeComponentOwningStateState, ComposeComponentOwningStateEnvironment> {
  ComposeComponentOwningState({super.key, required super.store});

  @override
  Widget build(context, state, viewStore) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose Component Owning State'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(state.name),
            Counter.selfContained(),
            TextButton(
                onPressed: () => viewStore
                    .send(ComposeComponentOwningStateAction.appendYourMom),
                child: const Text("parent append your mom to name"))
          ],
        ),
      ),
    );
  }
}
