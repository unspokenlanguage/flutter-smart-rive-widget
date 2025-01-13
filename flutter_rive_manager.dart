import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; // For rootBundle

/// Converts Uint8List to ByteData

ByteData uint8ListToByteData(Uint8List uint8list) {
  return ByteData.view(uint8list.buffer);
}


class RivManager {
  static final RivManager _instance = RivManager._internal();
  final Map<String, Riv> _loadedRives = {}; // Preloaded Rive files
  final Map<String, String> _currentStates = {}; // Track current state
  String? _defaultFile;

  factory RivManager() => _instance;

  RivManager._internal();

  /// Get the current state of a machine
  String getCurrentState([String? machineName]) {
    if (machineName == null) {
      if (_currentStates.isEmpty) {
        return 'Unknown';
      }
      // Default to the first state machine registered
      machineName = _currentStates.keys.first;
    }
    return _currentStates[machineName] ?? 'Unknown';
  }
  /// Clear inputs for a specific alias to free up memory.
  void clearInputs(String alias) {
    _registeredInputs.removeWhere((key, value) => key.startsWith(alias));
    debugPrint('Cleared inputs for alias: $alias');
  }
  /// Preload multiple Rive files at once
  Future<void> preloadFiles(Map<String, String> riveFiles) async {
    for (final entry in riveFiles.entries) {
      final alias = entry.key;
      final source = entry.value;

      if (_loadedRives.containsKey(alias)) {
        debugPrint('Rive file with alias "$alias" is already preloaded.');
        continue;
      }

      try {
        debugPrint('Preloading Rive file with alias: $alias, source: $source');
        await load(source, alias: alias);
        debugPrint('Rive file "$alias" preloaded successfully.');
      } catch (e) {
        debugPrint('Failed to preload Rive file: $alias. Error: $e');
      }
    }
  }
  Future<void> load(
      dynamic source, {
        String? alias,
        BoxFit fit = BoxFit.contain,
        void Function(Artboard)? onInit,
        void Function(String stateMachineName, String stateName)? onStateChange, // Callback for state changes
        void Function(RiveEvent event)? onEvent,
        VoidCallback? onAnimationComplete,
      }) async {
    alias ??= source.toString();
    if (_loadedRives.containsKey(alias)) {
      debugPrint('Rive file "$alias" already loaded.');
      return;
    }

    try {
      debugPrint('Initializing Rive runtime...');
      await RiveFile.initialize(); // Ensure Rive runtime is initialized
      debugPrint('Success initialization Rive runtime...');
      debugPrint('Loading Rive file from: $source');
      late RiveFile riveFile;

      if (source is String && Uri.tryParse(source)?.isAbsolute == true) {
        final response = await http.get(Uri.parse(source));
        if (response.statusCode == 200) {
          final byteData = ByteData.view(response.bodyBytes.buffer);
          riveFile = RiveFile.import(byteData);
        } else {
          throw Exception('Failed to fetch Rive file from URL: $source');
        }
      } else if (source is String) {
        final data = await rootBundle.load(source);
        riveFile = RiveFile.import(data);
      } else if (source is ByteData) {
        riveFile = RiveFile.import(source);
      } else {
        throw Exception('Unsupported source type: $source');
      }

      final artboard = riveFile.mainArtboard;
      debugPrint('Loaded Rive file: $source with main artboard: ${artboard.name}');

      final riv = Riv._(artboard, fit);
      _loadedRives[alias] = riv;

      onInit?.call(artboard);

      for (final stateMachine in artboard.stateMachines) {
        debugPrint('Initializing state machine: ${stateMachine.name}');
        final controller = StateMachineController.fromArtboard(
          artboard,
          stateMachine.name,
          onStateChange: _onStateChange, // Attach the callback
        );

        if (controller != null) {
          artboard.addController(controller);
          riv._stateMachines[stateMachine.name] = controller;

          debugPrint('State machine "${stateMachine.name}" added to _stateMachines.');
          registerStateMachineInputs(stateMachine.name, controller, alias);

          // Optional: Attach additional event listeners if needed
          controller.addEventListener((RiveEvent event) {
            debugPrint('Event Received from "${stateMachine.name}":');
            debugPrint('Event Name: ${event.name}');
            debugPrint('Event Type: ${event.runtimeType}');

            if (event is RiveGeneralEvent) {
              debugPrint('Properties: ${event.properties}');
            }

            if (event is RiveOpenURLEvent) {
              debugPrint('Open URL: ${event.url}');
            }

            onEvent?.call(event); // Pass event back to the caller
          });

          debugPrint('Event listener attached to State Machine "${stateMachine.name}".');
        } else {
          debugPrint('State machine "${stateMachine.name}" could not be initialized.');
        }
      }



      _defaultFile ??= alias;
      debugPrint('Rive file "$alias" loaded successfully.');
    } catch (e) {
      debugPrint('Failed to load Rive file: $source. Error: $e');
      throw Exception('Failed to load Rive file: $source. Error: $e');
    }



  }

  final Map<String, SMIInput> _registeredInputs = {};

  void _onStateChange(String stateMachineName, String stateName) {
    debugPrint('State Changed in "$stateMachineName": $stateName');
    _currentStates[stateMachineName] = stateName; // Update the current state
  }

  void registerStateMachineInputs(
      String stateMachineName,
      StateMachineController controller,
      String alias,
      ) {
    debugPrint('Registering inputs for state machine: $stateMachineName');


    for (final input in controller.inputs) {
      final inputKey = '${alias}_${stateMachineName}_${input.name}';

      _registeredInputs[inputKey] = input;
      if (input is SMIBool) {
        debugPrint('Registered Boolean input "$inputKey" with initial value: ${input.value}');
      } else if (input is SMITrigger) {
        debugPrint('Registered Trigger input "$inputKey"');
      } else if (input is SMINumber) {
        debugPrint('Registered Number input "$inputKey" with initial value: ${input.value}');
      } else {
        debugPrint('Registered unknown input type for "$inputKey"');
      }
      //debugPrint('Function: registerStateMachineInputs() -> Registered input "$inputKey" with initial value: ${input.value}');
    }
    debugPrint('All inputs registered for state machine: $stateMachineName');
  }


  /// Fetch or dynamically load a Rive file by alias
  Future<Riv> _getRive(String alias, String? filePath) async {
    if (_loadedRives.containsKey(alias)) {
      debugPrint('Fetching preloaded Rive file with alias: $alias');
      return _loadedRives[alias]!;
    }
    if (filePath != null) {
      debugPrint('Rive file with alias "$alias" not preloaded. Loading dynamically from: $filePath');
      await load(filePath, alias: alias);
      return _loadedRives[alias]!;
    }
    throw Exception('Rive file "$alias" not loaded.');
  }


  /// Get a widget for rendering the Rive animation
  Future<Widget> getWidget({
    required String alias,
    BoxFit? fit,
    Alignment alignment = Alignment.center, // Default alignment
  }) async {
    // Check if the alias is preloaded
    if (!_loadedRives.containsKey(alias)) {
      throw Exception('Rive file with alias "$alias" not preloaded. Please preload the file first.');
    }

    final riv = _loadedRives[alias]!;
    debugPrint('Rendering Rive widget for alias: $alias');
    return Rive(
      artboard: riv._artboard,
      fit: fit ?? riv.fit,
      alignment: alignment, // Pass alignment here
    );
  }


  /// Get a widget for rendering the Rive animation with FutureBuilder
  Widget getWidgetAsync({
    required String alias,
    BoxFit? fit,
    Alignment alignment = Alignment.center, // Default alignment
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    debugPrint('Attempting to render widget asynchronously for alias: $alias');

    return FutureBuilder<Widget>(
      future: getWidget(alias: alias, fit: fit, alignment: alignment),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint('Loading Rive file for alias: $alias');
          return placeholder ?? const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          debugPrint('Error rendering Rive file for alias: $alias - ${snapshot.error}');
          return errorWidget ??
              Center(
                child: Text('Error rendering Rive file: ${snapshot.error}'),
              );
        }
        return snapshot.data!;
      },
    );
  }

  Future<void> _loadFileIfNotLoaded(String alias, String filePath) async {
    if (!_loadedRives.containsKey(alias)) {
      debugPrint('Rive file "$alias" not loaded. Initiating load.');
      await load(filePath, alias: alias);
    } else {
      debugPrint('Rive file "$alias" already loaded.');
    }
  }
  void _handleRiveEvent(RiveEvent event) {
    debugPrint('Event Received -> Name: ${event.name}, Type: ${event.runtimeType}');
    if (event is RiveGeneralEvent) {
      debugPrint('Properties: ${event.properties}');
    }
    if (event is RiveOpenURLEvent) {
      debugPrint('Open URL: ${event.url}');
      // Add your URL-handling logic here
    }
  }

  /// Trigger a state machine input
  Future<void> trigger(
      String alias,
      String inputName,
      dynamic value, {
        String? machineName,
        VoidCallback? onComplete,
      }) async {
    if (alias.isEmpty || inputName.isEmpty) {
      throw Exception('Alias and input name must not be empty.');
    }

    // Infer the machineName if not provided
    machineName ??= _registeredInputs.keys
        .firstWhere(
            (key) => key.startsWith('${alias}_') && key.endsWith('_$inputName'),
        orElse: () => '')
        .split('_')[1]; // Extract the state machine name from the key

    if (machineName.isEmpty) {
      throw Exception(
          'State machine name could not be inferred for alias "$alias" and input "$inputName".');
    }

    final inputKey = '${alias}_${machineName}_$inputName';
    debugPrint('Generated InputKey: $inputKey');
    debugPrint('Available keys in _registeredInputs: ${_registeredInputs.keys.join(', ')}');

    final input = _registeredInputs[inputKey];

    if (input == null) {
      throw Exception(
          'Input "$inputName" not registered for alias "$alias" and state machine "$machineName".');
    }

    if (input is SMIBool && value is bool) {
      input.value = value;
    } else if (input is SMINumber && value is num) {
      input.value = value.toDouble();
    } else if (input is SMITrigger) {
      input.fire();
    } else {
      throw Exception('Invalid input type for "$inputName".');
    }

    debugPrint('Successfully triggered input "$inputName" for alias "$alias".');
    onComplete?.call();
  }

  void trackStateChanges(String alias, String machineName) {
    final stateMachineController = _loadedRives[alias]?._stateMachines[machineName];

    if (stateMachineController != null) {
      stateMachineController.addEventListener((RiveEvent event) {
        debugPrint('Rive Event Received:');
        debugPrint('Event Name: ${event.name}');
        debugPrint('Event Type: ${event.runtimeType}');

        if (event is RiveGeneralEvent) {
          debugPrint('Properties: ${event.properties}');
        }

        if (event is RiveOpenURLEvent) {
          debugPrint('Open URL: ${event.url}');
        }
      });

      debugPrint('Event listener attached to State Machine "$machineName".');
    } else {
      debugPrint('State Machine "$machineName" not found for alias "$alias".');
    }
  }

  Future<void> setBoolean(
      String alias,
      String inputName,
      bool value, {
        String? machineName,
        VoidCallback? onComplete, // Optional callback for specific input completion
      }) async {
    // Infer machineName if not provided
    machineName ??= _registeredInputs.keys
        .firstWhere(
            (key) => key.startsWith('${alias}_') && key.endsWith('_$inputName'),
        orElse: () => '')
        .split('_')[1];

    if (machineName.isEmpty) {
      throw Exception(
          'State machine name could not be inferred for alias "$alias" and input "$inputName".');
    }

    final inputKey = '${alias}_${machineName}_$inputName';
    final input = _registeredInputs[inputKey];

    if (input is SMIBool) {
      input.value = value;

      final stateMachineController = _loadedRives[alias]?._stateMachines[machineName];

      if (stateMachineController != null) {
        // Attach an event listener to track this input's completion (optional)
        stateMachineController.addEventListener((RiveEvent event) {
          debugPrint('Received Event: Name: ${event.name}, Type: ${event.runtimeType}');

          // Optionally, handle specific events or log state changes
          if (event.name == inputName) {
            debugPrint('Boolean input "${event.name}" set to $value successfully.');
            onComplete?.call();
          }
        });

        debugPrint('Event listener attached to State Machine "$machineName".');
      }

      debugPrint('Set boolean input "$inputName" to $value for alias "$alias".');
    } else {
      throw Exception('Input "$inputName" is not a boolean input.');
    }
  }


  Future<void> setNumber(
      String alias,
      String inputName,
      double value, {
        String? machineName,
        VoidCallback? onComplete, // Optional callback for specific input completion
      }) async {
    // Infer machineName if not provided
    machineName ??= _registeredInputs.keys
        .firstWhere(
            (key) => key.startsWith('${alias}_') && key.endsWith('_$inputName'),
        orElse: () => '')
        .split('_')[1];

    if (machineName.isEmpty) {
      throw Exception(
          'State machine name could not be inferred for alias "$alias" and input "$inputName".');
    }

    final inputKey = '${alias}_${machineName}_$inputName';
    final input = _registeredInputs[inputKey];

    if (input is SMINumber) {
      input.value = value;

      final stateMachineController = _loadedRives[alias]?._stateMachines[machineName];

      if (stateMachineController != null) {
        // Attach an event listener to track this input's completion (optional)
        stateMachineController.addEventListener((RiveEvent event) {
          debugPrint('Received Event: Name: ${event.name}, Type: ${event.runtimeType}');

          // Optionally, handle specific events or log state changes
          if (event.name == inputName) {
            debugPrint('Number input "${event.name}" updated to $value successfully.');
            onComplete?.call();
          }
        });

        debugPrint('Event listener attached to State Machine "$machineName".');
      }

      debugPrint('Set number input "$inputName" to $value for alias "$alias".');
    } else {
      throw Exception('Input "$inputName" is not a number input.');
    }
  }


  Future<void> triggerInput(
      String alias,
      String inputName, {
        String? machineName,
        VoidCallback? onComplete, // Optional callback for specific input completion
      }) async {
    machineName ??= _registeredInputs.keys
        .firstWhere(
            (key) => key.startsWith('${alias}_') && key.endsWith('_$inputName'),
        orElse: () => '')
        .split('_')[1];

    if (machineName.isEmpty) {
      throw Exception(
          'State machine name could not be inferred for alias "$alias" and input "$inputName".');
    }

    final inputKey = '${alias}_${machineName}_$inputName';
    final input = _registeredInputs[inputKey];

    if (input is SMITrigger) {
      final stateMachineController = _loadedRives[alias]?._stateMachines[machineName];

      if (stateMachineController != null) {
        // Attach an event listener to track this input's completion (optional)
        stateMachineController.addEventListener((RiveEvent event) {
          debugPrint('Received Event: Name: ${event.name}, Type: ${event.runtimeType}');

          // Handle specific event, if needed
          if (event.name == inputName) {
            debugPrint('Trigger "${event.name}" executed successfully.');
            onComplete?.call();
          }
        });

        debugPrint('Event listener attached to State Machine "$machineName".');
      }

      // Fire the trigger input
      input.fire();
      debugPrint('Triggered input "$inputName" for alias "$alias".');
    } else {
      throw Exception('Input "$inputName" is not a trigger input.');
    }
  }






  /// Update text in the Rive animation
  /// Update text in the Rive animation
  Future<void> updateText(
      String alias,
      String textRunName,
      String value, {
        String? filePath,
      }) async {
    debugPrint('Updating text "$textRunName" on alias "$alias" with value "$value"');

    // Fetch the Rive file from the alias
    final riv = await _getRive(alias, filePath);

    // Access the artboard directly
    final textField = riv._artboard.component<TextValueRun>(textRunName);
    if (textField != null) {
      debugPrint('Updating text run "$textRunName" with value "$value".');
      textField.text = value; // Update the text
    } else {
      debugPrint('Error: Text run "$textRunName" not found.');
      throw Exception('Text run "$textRunName" not found.');
    }
  }

}

class Riv {
  final Artboard _artboard;
  final BoxFit fit;
  final Map<String, SimpleAnimation> _animations = {};
  final Map<String, StateMachineController> _stateMachines = {}; // Holds state machine controllers

  Riv._(this._artboard, this.fit);
}