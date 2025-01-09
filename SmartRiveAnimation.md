
# Smart Rive Animation Widget for Flutter

## Overview

**SmartRiveAnimation** is a reusable Flutter widget that simplifies integrating Rive animations into your projects. It supports both one-shot animations and state machine-based animations, offering customizable configurations for advanced interaction.

---

## Features

- One-shot animations
- State machine animations
- Easy state input updates (triggers, booleans, numbers)
- Callbacks for animation and state changes
- Fully customizable fit (BoxFit)

---

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

---

## Import the Library

Import the required library in your Dart file:

```dart
import 'package:rive/rive.dart';
import 'smart_rive_animation.dart';
```

---

## GlobalKey for State Machine Animations

A `GlobalKey<SmartRiveAnimationState>` allows you to access the internal state of the `SmartRiveAnimation` widget, which is particularly useful for **State Machine Animations**. While optional, it enables dynamic updates to inputs or state transitions after the widget is built.

### Example: Using GlobalKey

```dart
final GlobalKey<SmartRiveAnimationState> riveKey = GlobalKey<SmartRiveAnimationState>();

SmartRiveAnimation(
  key: riveKey, // Attach the GlobalKey
  animationType: RiveAnimationType.StateMachineAnimation,
  riveFilePath: 'assets/your_animation.riv',
  stateMachineName: 'StateMachineName',
  stateMachineInputs: {
    'TriggerAction': false,
  },
  fit: BoxFit.contain,
  onAnimationComplete: () {
    debugPrint('Animation completed!');
    riveKey.currentState?.handleRiveInput('Idle', true);
  },
);
```

For **One-Shot Animations**, the `GlobalKey` is not required unless you have specific programmatic control needs.

---

## Usage

### One-Shot Animation Example

Trigger simple animations, such as a button press animation or a character's action:

```dart
SmartRiveAnimation(
  animationType: RiveAnimationType.OneshotAnimation,
  riveFilePath: 'assets/button_animation.riv',
  triggerAnimation: 'Press',
  fit: BoxFit.contain,
  onAnimationComplete: () {
    debugPrint('Button animation completed!');
  },
);
```

---

### State Machine Animation Example

Control more complex animations, such as a character's movement or a progress indicator:

```dart
SmartRiveAnimation(
  key: riveKey,
  animationType: RiveAnimationType.StateMachineAnimation,
  riveFilePath: 'assets/character_animation.riv',
  stateMachineName: 'CharacterState',
  stateMachineInputs: {
    'Run': false,
    'Jump': false,
  },
  fit: BoxFit.contain,
  onAnimationComplete: () {
    debugPrint('State Machine Animation completed!');
    riveKey.currentState?.handleRiveInput('Idle', true);
  },
);
```

---

## Updating Inputs Dynamically

Use the `handleRiveInput` method to update inputs dynamically. This method handles triggers, booleans, and numeric inputs.

### Real-Life Scenarios

1. **Gaming Application:**
   - Trigger `Jump` when a user taps the jump button:
     ```dart
     riveKey.currentState?.handleRiveInput('Jump', true);
     ```
   - Toggle `Run` based on user interaction:
     ```dart
     riveKey.currentState?.handleRiveInput('Run', true);
     ```

2. **Progress Indicators:**
   - Update progress dynamically in an educational app:
     ```dart
     riveKey.currentState?.handleRiveInput('Progress', 75.0);
     ```

---

## Parameters

### Common Parameters

| Parameter             | Type                               | Description                                                                 | Required |
|-----------------------|------------------------------------|-----------------------------------------------------------------------------|----------|
| `key`                 | `GlobalKey<SmartRiveAnimationState>?` | GlobalKey for programmatically accessing and interacting with the widget.    | No       |
| `animationType`       | `RiveAnimationType`               | Specifies the type of animation: OneshotAnimation or StateMachineAnimation. | Yes      |
| `riveFilePath`        | `String`                          | Path to the Rive animation file.                                           | Yes      |
| `fit`                 | `BoxFit`                          | Specifies how the animation fits within its bounds.                        | Yes      |

### One-Shot Animation Parameters

| Parameter             | Type               | Description                                 | Required |
|-----------------------|--------------------|---------------------------------------------|----------|
| `triggerAnimation`    | `String?`          | Name of the one-shot animation to trigger. | Yes      |
| `onAnimationComplete` | `VoidCallback?`    | Callback when a one-shot animation completes. | No       |

### State Machine Animation Parameters

| Parameter             | Type                               | Description                                                                 | Required |
|-----------------------|------------------------------------|-----------------------------------------------------------------------------|----------|
| `stateMachineName`    | `String?`                         | Name of the state machine in the Rive file.                                | Yes      |
| `stateMachineInputs`  | `Map<String, dynamic>?`           | Initial values for the state machine inputs (triggers, booleans, numbers). | No       |
| `onInit`              | `void Function(Artboard)?`        | Callback when the Rive artboard is initialized.                            | No       |
| `onInputAction`       | `void Function(String, dynamic)?` | Callback when a state machine input is updated.                            | No       |
| `onStateChange`       | `void Function(String, String)?`  | Callback when the state machine transitions to a new state.                | No       |

---

## License

This project is licensed under the MIT License.
