
# RivManager Library - Comprehensive Guide

## Overview

`RivManager` is a Dart library designed to simplify the management of Rive animations and state machines in Flutter applications. This library provides intuitive methods for preloading animations, handling inputs, tracking state changes, and dynamically updating Rive animations.

---

## Features

- **Preload Animations**: Preload multiple Rive files for seamless animation rendering.
- **State Tracking**: Easily track and log state transitions in Rive state machines.
- **Input Handling**: Dynamically trigger and update state machine inputs (e.g., triggers, booleans, numbers).
- **Event Handling**: Attach listeners to state machine events and handle specific triggers dynamically.
- **Current State Retrieval**: Fetch the current state of any state machine.
- **Simplified Widget Integration**: Easily integrate Rive widgets into your Flutter UI.

---

## Setup

### Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  rive: ^latest version
  http: ^0.15.0
  flutter:
    sdk: flutter
```

Run the following command to install dependencies:

```bash
flutter pub get
```

---

## Library Structure

The library revolves around a singleton class `RivManager`. Below are its core components:

### **1. Preloading Animations**

Preloading ensures smooth rendering of animations without delays. Use the following code in your `initState` or during app initialization:

```dart
@override
void initState() {
  super.initState();
  _initializeApp(); // Call this function in your widget's state class
}

Future<void> _initializeApp() async {
  try {
    await RivManager().preloadFiles({
      'login': 'https://rivecloudhost.web.app/login.riv',
    });
  } catch (e) {
    debugPrint('Failed to preload animations: $e');
  }
}
```

- **Where to Define**: Place `_initializeApp` in your widget's `State` class.
- **Explanation**: Preloads the `login` animation from a remote URL for use later.

---

### **2. Loading Animations**

To load a Rive file and register its state machines and inputs:

```dart
await RivManager().load(
  'assets/login.riv',
  alias: 'login',
  onInit: (artboard) {
    debugPrint('Rive artboard initialized: ${artboard.name}');
  },
  onStateChange: (machineName, stateName) {
    debugPrint('State changed: $machineName -> $stateName');
  },
);
```

- **Alias**: A unique identifier for the animation file. Used to reference animations later.
- **onInit**: Callback when the Rive artboard initializes.
- **onStateChange**: Logs state transitions in the state machine.

---

### **3. Updating Inputs**

Update specific inputs in a state machine dynamically.

#### **Boolean Input**

```dart
await RivManager().setBoolean(
  'login',
  'hands_up',
  true,
  onComplete: () {
    debugPrint('Boolean input set successfully.');
  },
);
```

#### **Number Input**

```dart
await RivManager().setNumber(
  'login',
  'progress',
  0.8,
  onComplete: () {
    debugPrint('Number input updated successfully.');
  },
);
```

#### **Trigger Input**

```dart
await RivManager().triggerInput(
  'login',
  'success',
  onComplete: () {
    debugPrint('Trigger executed successfully.');
  },
);
```

---

### **4. Fetching Current State**

Retrieve the current state of a specific or default state machine:

```dart
String currentState = RivManager().getCurrentState('State Machine 1');
debugPrint('Current State: $currentState');
```

- **Explanation**: Logs the current state of `State Machine 1`. If no name is provided, defaults to the first state machine.

---

### **5. Integrating Rive Widgets**

Render the Rive animation in your Flutter widget tree:

```dart
Future<Widget> _buildRiveWidget() async {
  return RivManager().getWidget(alias: 'login');
}

@override
Widget build(BuildContext context) {
  return FutureBuilder<Widget>(
    future: _buildRiveWidget(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }
      return snapshot.data!;
    },
  );
}
```

---

## Example Use Cases

### **Case 1: Login Animation with State Tracking**

```dart
@override
void initState() {
  super.initState();
  FirebaseAuth.instance.authStateChanges().listen((user) {
    setState(() {
      _currentUser = user;
    });
  });
  _initializeApp();
}

Future<void> _initializeApp() async {
  await RivManager().preloadFiles({
    'login': 'https://rivecloudhost.web.app/login.riv',
  });
}
```

### **Case 2: Dynamic State-Based UI Updates**

Use `RivManager().getCurrentState()` to display the current animation state:

```dart
@override
Widget build(BuildContext context) {
  String currentState = RivManager().getCurrentState('login');
  return Text('Current Animation State: $currentState');
}
```

---

## Contribution

Feel free to open issues or submit pull requests for improvements.

---

## License

This project is licensed under the MIT License.
