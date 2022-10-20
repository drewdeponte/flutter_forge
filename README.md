# flutter_riverpod_composable_arch

This is a project to build a framework to truely address state management and
building state based apps in a robust and composable manner. This will allow
components which are any segment of the app to be developed in pure isolation
and then composed together like lego blocks.

This makes developing components easier as it allows you to focus on strictly
on the needs of the component without mixing in the additional concern of
integrating. Then as a secondary step when you want you integrate your
component you then have to worry about that concern but only within a very
defined scope.

This framework should also standardize how data binding is done so that it
happens in a uni-directional architecture saving us from a huge category of
errors that would be occuring.

## Examples

When I think about frameworks I think about them supporting various scenarios.
The following are the various scenarios that I think this framework should
address.

- [x] compose a component such that it fully owns its own state
	- [x] compose a component such that component actions are initiated internally and are handled internally
	- [x] compose a component such that the parent component can send actions to the child components store
- [x] compose a component such that it gets all of its state from its parent component
	- [x] compose a component such that component actions are initiated internally and are handled in the parent component
- [ ] compose a component such that it gets some of its state from its parent component but also owns some of its owns state
- [ ] compose a component such that component actions are only initiated internally and handled internally and external actions are blocked/ignored
- [ ] compose a component such that component actions are initiated in the parent and are handled in the child component
- [ ] compose a component's state & state store with a state & state store that addresses generic loading. This is ideally figuring out how to wrap `AsyncValue<T>` and `FutureProvider` from Riverpod in a way that is composable.
