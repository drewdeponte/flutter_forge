# Development

## Codebase

The code base is split into two main sections

- **lib** - the flutter_forge library
- **example** - the example that flutter application that uses flutter_forge

Within the library the code base is organized as follows.

- **src/core** - the core of the library, everything needed to be used
	- **state_management** - the core types facilitating modular, composable, controlled state management
	- **widgets** - the core Widgets design to facilitate making modular, composable widgets using the core state management
- **src/convenience** - higher level widgets & types that facilitate doing things in more convenient ways, e.g. async data loading
- **src/utils** - generic utilities we use within the library, e.g. `SelectedValueNotifier`
