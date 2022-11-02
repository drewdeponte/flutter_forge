# flutter_forge

This is a project to build a framework to truely address state management and
building state based apps in a robust and composable manner. This will allow
components which are any segment of the app to be developed in pure isolation
and then composed together like lego blocks.

This makes developing components easier as it allows you to focus on strictly
on the needs of the component without mixing in the additional concern of
integrating. Then as a secondary step when you want to integrate your component
you then have to worry about that concern but only within a very defined scope.

This framework should also standardize how data binding is done so that it
happens in a uni-directional architecture saving us from a huge category of
errors that would be occuring.

## What it addresses?

Right now it addresses developing and composing fully isolated components by
formalizing the following:

- how you access dependencies (through a formally defined `Environment`)
- how you define state (through a formally defined `State`)
- how you define state mutations (through formally defined `Actions`)
- how you define side effects (through formally defined `Effects`)
- how you define a component widget (through formally defined `ComponentWidget`)
- how you wire your component widget interactivity up to make state changes or
  side effects (through formally defined `Store` & `ViewStore`)
- how you compose widgets together in their natural hierarchy (through formally defined `Scoping`)
