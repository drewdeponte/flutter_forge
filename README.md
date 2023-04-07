# flutter_forge

Flutter Forge is a library designed to facilitate building state based Flutter
widgets in a modular and composable way so that they can easily be tested,
extracted, replaced, or reconfigured. This also makes it possible to build
state based Flutter components in complete isolation as well as being able to
easily use them in Storybooks. This is normally only possible for dumb widgets.

In doing so it also provides a structured consistent manner of managing state
mutation within a widget, based on uni-directional data flow and [Redux][]. You can
think of it like every component effectively has its own scoped [Redux][] flow.
This aids in making it much harder for developers to make some of the classic
state management errors, e.g. triggering multiple state mutations in a single
action, etc.

Overall the core concepts are largely based on concepts introduced in
[Swift Composable Architecture][]. However, it has been implemented
specifically with Flutter in mind and various differences in composition
strategies.

## Simple Counter Component Walkthrough

When we define components they are defined in terms of a **formal** &
**complete** interface. This is what makes them modular so that they can easily
be tested, extracted, replaced, or reused. In Flutter Forge the `Store` concept
is used to define this formal interface as each Flutter Forge component takes
in a specific concrete type of `Store`. The `Store` type is a generic type that
needs to be concretized by providing concrete types for each of its generic
type parameters, `State`, `Environment`, and `Action`. Let's define these
concrete types below.

### State

The following is the `CounterState` class. It is going to be our concrete
implementation for the generic concept of `State` for our component. It is
equivalent conceptually to the concept of `State` in [Redux][]. Concrete
`State` types **must** be `@immutable` and extend `Equatable` so that the
`Store` can correctly detect state changes by value. In our example below our
`State` type simply consists of a single integer value named `count`.

```dart
@immutable
class CounterState extends Equatable {
  const CounterState({required this.count});

  final int count;

  @override
  List<Object> get props => [count];
}
```

### Environment

Because our interface needs to be **complete** for it to be modular. We have to
facilitate a mechanism of injecting dependencies into our component. This is
where the `Environment` concept comes into play. It is simply a class that
provides any functions or data that we would want to dependency inject into the
component. In our current example we don't need to dependency inject anything.
So it is an empty class named `CounterEnvironment`.

```dart
class CounterEnvironment {}
```

### Actions

Just as in [Redux][] we have the concept of `Action` which is simply a message
that you send from our Widget to the store to trigger state change. To get
better type enforcement within our components we first create an abstract class
named `CounterAction` that we will use as the base class for our other actions,
e.g. `IncrementButtonTapped`.

```dart
abstract class CounterAction implements ReducerAction {}
class IncrementButtonTapped implements CounterAction {}
```

### Reducer

Given that Flutter Forge components require a `Store` instance be passed to
them as the formal interface and `Store` requires it be constructed with a
`Reducer` we need to create a reducer for this component. A reducer is
responsible for interpreting `State` and `Action` and computing and returning a
new `State` as well as optionally `Effects`.

```dart
final counterReducer = Reducer<CounterState, CounterEnvironment, CounterAction>((state, action) {
  if (action is IncrementButtonTapped) {
    return ReducerTuple(CounterState(count: state.count + 1), []);
  } else {
    return ReducerTuple(state, []);
  }
});
```

In the above `counterReducer` we are matching against the
`IncrementButtonTapped` action and producing a new `CounterState` instance with
the `count` property incremented by one. *Note:* We are passing `[]` to the
`ReducerTuple` as we don't want to trigger any `Effects`.

### Widget

Now that we have our formal interface defined by our `State`, `Environment`,
`Action`, and `Reducer` we can use them in our `ComponentWidget`.

```dart
class CounterComponent extends ComponentWidget<CounterState, CounterEnvironment, CounterAction> {
  const CounterComponent({super.key, required super.store});

  @override
  Widget build(context, viewStore) {
    return Column(children: [
      Rebuilder(
          store: store,
          builder: (context, state, child) {
            return Text(
              '${state.count}',
              style: Theme.of(context).textTheme.headline4,
            );
          }),
      OutlinedButton(
          onPressed: () => viewStore.send(IncrementButtonTapped()),
          child: const Text("increment"))
    ]);
  }
}
```

In the above you can see the use of a `Rebuilder` widget. This is provided by
Flutter Forge to facilitate rebuilding a portion of the components subtree
based on the state changing. In the example above we simply wrap the `Text`
widget that is showing the `state.count` property with `Rebuilder` as that is
the only piece of the widget subtree that needs to be rebuilt when state
changes.

### Usage

Now that we have a complete `CounterComponent` what does actual usage of this
component look like? We simply construct the component and pass it a store that
conforms to `CounterState`, `CounterEnvironment`, and `CounterAction` which we
can produce as follows.

```dart
CounterComponent(
	store: Store(
		CounterState(count: 0),
		counterReducer,
		CounterEnvironment()
	)
)
```

## Development

For more details in terms of development and the codebase check out the
`DEVELOPMENT.md`.

## License

`flutter_forge` is Copyright © 2022 UpTech Works, LLC. It is free software, and
may be redistributed under the terms specified in the LICENSE file.

[Redux]: https://dev.to/codebucks/what-is-redux-simply-explained-2ch7
[Swift Composable Architecture]: https://github.com/pointfreeco/swift-composable-architecture 
