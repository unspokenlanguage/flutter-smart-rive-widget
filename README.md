
# Smart Rive Animation Widget for Flutter

## Overview

**SmartRiveAnimation** is a reusable Flutter widget that simplifies integrating Rive animations into your projects. It supports both one-shot animations and state machine-based animations, offering customizable configurations for advanced interaction.

## Features

- One-shot animations
- State machine animations
- Easy state input updates (triggers, booleans, numbers)
- Callbacks for animation and state changes
- Fully customizable fit (BoxFit)

## Installation

Add the following dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  rive: ^latest_version
```

Run the command below to fetch the dependencies:

```bash
flutter pub get
```

## Import the Library

Import the required library in your Dart file:

```dart
import 'package:rive/rive.dart';
import 'smart_rive_animation.dart';
```

## Usage

### Basic Example

Below is an example of using the SmartRiveAnimation widget for a state machine animation:

```dart
SmartRiveAnimation(
  animationType: RiveAnimationType.StateMachineAnimation,
  riveFilePath: 'assets/your_animation.riv',
  stateMachineName: 'StateMachineName',
  stateMachineInputs: {
    'number_input1': 0.0, 
    'number_input2': 0.0,
    'boolean_input3': true,
    'trigger_input4': false,
    'trigger_input5': false,
  },
  fit: BoxFit.contain,
  onInit: (artboard) {
    debugPrint('Rive initialized with artboard: ${artboard.name}');
  },
  onInputAction: (inputName, value) {
    debugPrint('Input $inputName updated to $value');
  },
  onStateChange: (stateMachineName, stateName) {
    debugPrint('State changed in $stateMachineName to $stateName');
  },
  onAnimationComplete: () {
    debugPrint('Animation completed!');
  },
)
```

## Updating Inputs

You can update inputs dynamically using the `updateRiveInput` method. This method automatically handles the input type (trigger, boolean, or number).


### updateRiveInput - Example Updating Inputs:

```dart
Column(
  children: [
    ElevatedButton(
      onPressed: () => updateRiveInput('number_input1', 42.0, stateMachineInputs),
      child: Text('Set Number Input 1 to 42'),
    ),
    ElevatedButton(
      onPressed: () => updateRiveInput('number_input2', 99.0, stateMachineInputs),
      child: Text('Set Number Input 2 to 99'),
    ),
    ElevatedButton(
      onPressed: () => updateRiveInput('boolean_input3', true, stateMachineInputs),
      child: Text('Toggle Boolean Input 3'),
    ),
    ElevatedButton(
      onPressed: () => updateRiveInput('trigger_input4', true, stateMachineInputs),
      child: Text('Activate Trigger Input 4'),
    ),
    ElevatedButton(
      onPressed: () => updateRiveInput('trigger_input5', true, stateMachineInputs),
      child: Text('Activate Trigger Input 5'),
    ),
  ],
)
```

## Parameters

| Parameter             | Type                               | Description                                                                 | Required |
|-----------------------|------------------------------------|-----------------------------------------------------------------------------|----------|
| `animationType`       | `RiveAnimationType`               | Specifies the type of animation: OneshotAnimation or StateMachineAnimation. | Yes      |
| `riveFilePath`        | `String`                          | Path to the Rive animation file.                                           | Yes      |
| `animations`          | `List<String>`                    | List of animations to be played.                                           | Yes      |
| `fit`                 | `BoxFit`                          | Specifies how the animation fits within its bounds.                        | Yes      |
| `triggerAnimation`    | `String?`                         | Name of the one-shot animation to trigger.                                 | No       |
| `stateMachineName`    | `String?`                         | Name of the state machine in the Rive file.                                | No       |
| `stateMachineInputs`  | `Map<String, dynamic>?`           | Initial values for the state machine inputs (triggers, booleans, numbers). | No       |
| `onInit`              | `void Function(Artboard)?`        | Callback when the Rive artboard is initialized.                            | No       |
| `onInputAction`       | `void Function(String, dynamic)?` | Callback when a state machine input is updated.                            | No       |
| `onStateChange`       | `void Function(String, String)?`  | Callback when the state machine transitions to a new state.                | No       |
| `onAnimationComplete` | `VoidCallback?`                   | Callback when a one-shot animation completes.                              | No       |

## License

This project is licensed under the MIT License.
