import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// Enum to define the type of Rive animation
enum RiveAnimationType {
  OneshotAnimation,
  StateMachineAnimation,
}

/// A reusable widget for Rive animations.
class SmartRiveAnimation extends StatefulWidget {
  final RiveAnimationType animationType;
  final String riveFilePath;
  final List<String>? animations; // Make it optional
  final BoxFit fit;
  final String? triggerAnimation; // For OneshotAnimation
  final String? stateMachineName; // For StateMachineAnimation
  final Map<String, dynamic>? stateMachineInputs; // Inputs for StateMachine
  final Map<String, String>? textUpdates; // For TextValueRun update
  final void Function(Artboard)? onInit;
  final void Function(String inputName, dynamic value)? onInputAction; // Callback for input actions
  final void Function(String stateMachineName, String stateName)? onStateChange; // State change callback
  final VoidCallback? onAnimationComplete; // Callback for animation completion

  const SmartRiveAnimation({
    super.key,
    required this.animationType,
    required this.riveFilePath,
    this.animations = const [], // Default to an empty list if not provided
    required this.fit,
    this.triggerAnimation,
    this.stateMachineName,
    this.stateMachineInputs,
    this.textUpdates,
    this.onInit,
    this.onInputAction,
    this.onStateChange,
    this.onAnimationComplete,
  });

  @override
  SmartRiveAnimationState createState() => SmartRiveAnimationState();
}

class SmartRiveAnimationState extends State<SmartRiveAnimation> {
  RiveAnimationController? _controller;
  StateMachineController? _stateMachineController;
  Map<String, SMIInput>? _stateMachineInputs = {};
  Map<String, TextValueRun>? _textFields = {}; // Map for TextValueRun components
  bool _isPlaying = false;
  bool _isInitialized = false; // Prevent repeated initialization

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    if (widget.animationType == RiveAnimationType.OneshotAnimation &&
        widget.triggerAnimation != null) {
      _controller = OneShotAnimation(
        widget.triggerAnimation!,
        autoplay: false,
        onStart: () {
          setState(() => _isPlaying = true);
        },
        onStop: () {
          setState(() => _isPlaying = false);
          widget.onAnimationComplete?.call();
        },
      );
    } else {
      _controller = null;
    }
  }

  /// Method to list all state machine inputs
  List<String> getStateMachineInputs() {
    if (_stateMachineController != null) {
      return _stateMachineController!.inputs.map((input) => input.name).toList();
    } else {
      debugPrint('State Machine Controller not initialized.');
      return [];
    }
  }

  void _onRiveInit(Artboard artboard) {
    if (_isInitialized) return; // Prevent repeated initialization
    _isInitialized = true;

    debugPrint('Rive initialized with artboard: ${artboard.name}');
    _initializeTextFields(artboard);

    // List all available timeline animations
    final animations = artboard.animations.map((a) => a.name).toList();
    if (animations.isNotEmpty) {
      debugPrint('Available Timeline Animations: ${animations.join(', ')}');
    } else {
      debugPrint('No animations found in the Rive file.');
    }

    if (widget.animationType == RiveAnimationType.StateMachineAnimation &&
        widget.stateMachineName != null) {
      _stateMachineController = StateMachineController.fromArtboard(
        artboard,
        widget.stateMachineName!,
        onStateChange: widget.onStateChange,
      );

      if (_stateMachineController != null) {
        artboard.addController(_stateMachineController!);

        // Automatically register all available inputs
        _stateMachineInputs = {};
        for (final input in _stateMachineController!.inputs) {
          _stateMachineInputs![input.name] = input;
          debugPrint('Input registered: ${input.name}');
        }

        // Log all available inputs for clarity
        if (_stateMachineInputs!.isNotEmpty) {
          debugPrint('All Inputs: ${_stateMachineInputs!.keys.join(', ')}');
        } else {
          debugPrint('No inputs found in the state machine.');
        }
      } else {
        debugPrint('State Machine Controller not found!');
      }
    }

    widget.onInit?.call(artboard);
  }


  void _initializeTextFields(Artboard artboard) {
    widget.textUpdates?.forEach((key, value) {
      final textField = artboard.component<TextValueRun>(key);
      if (textField != null) {
        _textFields![key] = textField;
        textField.text = value; // Set initial text
      } else {
        debugPrint('Text field "$key" not found in the Rive file.');
      }
    });
  }




  void _updateStateMachineInput(SMIInput input, dynamic value) {
    if (input is SMITrigger && value == true) {
      input.fire();
      widget.onInputAction?.call(input.name, value);
    } else if (input is SMIInput<bool>) {
      input.value = value as bool;
      widget.onInputAction?.call(input.name, value);
    } else if (input is SMIInput<double>) {
      input.value = value as double;
      widget.onInputAction?.call(input.name, value);
    }
  }

  /// New method to handle all input types
  /// Method to handle all input types dynamically
  void handleRiveInput(String inputName, dynamic value) {
    final input = _stateMachineInputs?[inputName];

    if (input == null) {
      debugPrint('Input "$inputName" not found! Available inputs: ${_stateMachineInputs?.keys.join(', ')}');
      return;
    }

    if (input is SMITrigger) {
      // Fire the trigger only if the value is `true`
      if (value == true) {
        input.fire();
        debugPrint('Trigger "$inputName" activated.');
        widget.onInputAction?.call(inputName, value);
      } else {
        debugPrint('Invalid value for trigger "$inputName": Only "true" can activate it.');
      }
    } else if (input is SMIInput<bool>) {
      // Update boolean input
      if (value is bool) {
        input.value = value;
        debugPrint('Boolean input "$inputName" set to $value.');
        widget.onInputAction?.call(inputName, value);
      } else {
        debugPrint('Invalid value for boolean input "$inputName": Expected a boolean but got $value.');
      }
    } else if (input is SMIInput<double>) {
      // Update numeric input
      if (value is double) {
        input.value = value;
        debugPrint('Numeric input "$inputName" set to $value.');
        widget.onInputAction?.call(inputName, value);
      } else {
        debugPrint('Invalid value for numeric input "$inputName": Expected a double but got $value.');
      }
    } else {
      // Handle unsupported input types
      debugPrint('Unhandled input type for "$inputName". Type: ${input.runtimeType}');
    }
  }

  /// Update text fields dynamically
  void updateText(String key, String value) {
    final textField = _textFields?[key];
    if (textField != null) {
      setState(() {
        textField.text = value;

        // Mark the artboard for redraw
        if (textField.artboard is RuntimeArtboard) {
          (textField.artboard as RuntimeArtboard).markNeedsAdvance();
          debugPrint('Artboard marked for redraw.');
        }
      });
      debugPrint('Text field "$key" updated with value: "$value".');
    } else {
      debugPrint('Text field "$key" not found in the Rive file.');
    }
  }



  @override
  void didUpdateWidget(covariant SmartRiveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update state machine inputs if they have changed
    if (widget.stateMachineInputs != oldWidget.stateMachineInputs) {

      widget.stateMachineInputs?.forEach((key, value) {
        final input = _stateMachineInputs?[key];
        if (input != null) {
          _updateStateMachineInput(input, value);
        }
      });
    }
    // Update state machine inputs if they have changed
    if (widget.stateMachineInputs != oldWidget.stateMachineInputs) {

      widget.stateMachineInputs?.forEach((key, value) {
        final input = _stateMachineInputs?[key];
        if (input != null) {
          _updateStateMachineInput(input, value);
        }
      });
    }
    // Update text fields if they have changed
    if (widget.textUpdates != oldWidget.textUpdates) {
      widget.textUpdates?.forEach((key, value) {
        updateText(key, value);
      });
    }
  }


  @override
  void dispose() {
    _controller = null;
    _stateMachineController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.animationType == RiveAnimationType.OneshotAnimation
          ? () {
        if (!_isPlaying) {
          _controller?.isActive = true;
        }
      }
          : null,
      child: RiveAnimation.asset(
        widget.riveFilePath,
        animations: widget.animationType == RiveAnimationType.OneshotAnimation
            ? (widget.animations ?? [])
            : [],
        fit: widget.fit,
        controllers: _controller != null ? [_controller!] : [],
        onInit: _onRiveInit,
      ),
    );
  }
}

