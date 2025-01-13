
# RivManager Library

RivManager is a comprehensive Flutter library for managing and interacting with Rive animations, including state machines, inputs, and events. This library provides a streamlined way to integrate Rive animations into your Flutter projects while offering detailed tracking and control capabilities.

## Features

- **Preloading Rive Files**: Preload Rive files for efficient runtime usage.
- **State Machine Management**: Register, track, and update state machines with ease.
- **Input Management**: Handle various input types, including triggers, booleans, and numbers.
- **State Change Tracking**: Track state changes within state machines and trigger corresponding actions.
- **Event Management**: Listen and react to Rive events seamlessly.
- **Text Updates**: Dynamically update text within Rive animations.

## Getting Started

### Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  rive: ^latest_version
  http: ^latest_version
  flutter:
    sdk: flutter
```

### Import the Library

```dart
import 'path_to_riv_manager.dart';
```

## Definitions

### Alias

An alias is a unique identifier for a Rive file. It allows multiple files to be managed simultaneously without confusion.

- **Purpose**: Helps in distinguishing between different Rive files.
- **Usage**: Use a meaningful alias, such as `"login_screen"`, to represent the Rive file loaded for the login screen.

### State Machines

State machines control the behavior of animations based on inputs and states. Each state machine is identified by its name.

- **Registration**: Automatically handled during the loading of a Rive file.
- **Current State**: Use `getCurrentState()` to fetch the current state of a state machine.

### Inputs

Inputs modify the behavior of animations within state machines. Supported types:
- **Boolean (`SMIBool`)**: Enables or disables a specific animation.
- **Number (`SMINumber`)**: Controls numeric parameters in animations.
- **Trigger (`SMITrigger`)**: Executes an animation action.

### Events

Events track actions triggered within state machines, such as entering or exiting a state.

## Usage

### Preloading Rive Files

```dart
await RivManager().preloadFiles({
  'login': 'assets/login_animation.riv',
  'dashboard': 'assets/dashboard_animation.riv',
});
```

### Rendering a Widget

```dart
Widget riveWidget = await RivManager().getWidget(alias: 'login');
```

### Triggering Inputs

#### Boolean Input

```dart
await RivManager().setBoolean('login', 'isLoading', true);
```

#### Number Input

```dart
await RivManager().setNumber('dashboard', 'progress', 75.0);
```

#### Trigger Input

```dart
await RivManager().triggerInput('login', 'success');
```

### Fetching Current State

```dart
String currentState = RivManager().getCurrentState('State Machine 1');
```

### Updating Text

```dart
await RivManager().updateText('dashboard', 'textLabel', 'Loading Complete');
```

### Tracking State Changes

State changes are logged automatically. Implement custom actions in `_onStateChange`.

## Example Code

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await RivManager().preloadFiles({
    'login': 'assets/login_animation.riv',
  });

  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Rive Example')),
      body: FutureBuilder<Widget>(
        future: RivManager().getWidget(alias: 'login'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading Rive animation'));
          } else {
            return snapshot.data!;
          }
        },
      ),
    ),
  ));
}
```

## Best Practices

1. **Meaningful Aliases**: Use descriptive aliases for Rive files.
2. **Preloading**: Preload frequently used animations to reduce runtime delays.
3. **State Tracking**: Utilize `getCurrentState()` for dynamic UI updates.
4. **Event Handling**: Attach event listeners for custom actions.

## Contributions

Contributions are welcome! Open issues or submit pull requests for enhancements.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
