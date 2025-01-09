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
  bool _isPlaying = false;

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

  void _onRiveInit(Artboard artboard) {
    if (widget.animationType == RiveAnimationType.StateMachineAnimation &&
        widget.stateMachineName != null) {
      _stateMachineController = StateMachineController.fromArtboard(
        artboard,
        widget.stateMachineName!,
        onStateChange: widget.onStateChange,
      );

      if (_stateMachineController != null) {
        artboard.addController(_stateMachineController!);

        // Initialize inputs
        _stateMachineInputs = {};
        widget.stateMachineInputs?.forEach((key, value) {
          final input = _stateMachineController?.findInput(key);
          if (input != null) {
            _stateMachineInputs![key] = input;
            _updateStateMachineInput(input, value);
          }
        });
      }
    }

    widget.onInit?.call(artboard);
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
  void handleRiveInput(String inputName, dynamic value) {
    final input = _stateMachineInputs?[inputName];

    if (input == null) {
      debugPrint('Input $inputName not found!');
      return;
    }

    if (input is SMITrigger) {
      // Fire the trigger if value is true
      if (value == true) {
        input.fire();
        widget.onInputAction?.call(inputName, value);
      } else {
        debugPrint('$inputName is a trigger, and only "true" can activate it.');
      }

    } else if (input is SMIInput<bool>) {
      if (value is bool) {
        input.value = value;
        widget.onInputAction?.call(inputName, value);
      } else {
        debugPrint('Invalid value for boolean input $inputName: $value');
      }
    } else if (input is SMIInput<double>) {
      if (value is double) {
        input.value = value;
        widget.onInputAction?.call(inputName, value);
      } else {
        debugPrint('Invalid value for numeric input $inputName: $value');
      }
    } else {
      debugPrint('Unhandled input type for $inputName');
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

