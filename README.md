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

Run:

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

Use the `updateRiveInput` method to update inputs dynamically. This method automatically handles the input type (trigger, boolean, or number).

### `updateRiveInput` Function:

```dart
void updateRiveInput(String inputName, dynamic value, Map<String, SMIInput> inputs) {
  final input = inputs[inputName];

  if (input == null) {
    debugPrint('Input $inputName not found!');
    return;
  }

  if (input is SMITrigger && value == true) {
    input.fire();
    debugPrint('Trigger $inputName fired!');
  } else if (input is SMIInput<bool>) {
    input.value = value as bool;
    debugPrint('Boolean $inputName set to $value');
  } else if (input is SMIInput<double>) {
    input.value = value as double;
    debugPrint('Numeric $inputName set to $value');
  } else {
    debugPrint('Unhandled input type for $inputName');
  }
}
```

### Example updating inputs:

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
      onPressed: () => updateRiveInput('boolean_input3', true), stateMachineInputs),
      child: Text('Toggle Boolean Input 3'),
    ),
    ElevatedButton(
      onPressed: () => updateRiveInput('trigger_input4', false, stateMachineInputs),
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



☕ Love supporting creative minds? Your coffee fuels my creativity and code! 😊  

[![Buy Me a Coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=kutlaydede&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff)](https://buymeacoffee.com/kutlaydede)

