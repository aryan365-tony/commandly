// lib/screens/control_screen.dart

import 'package:flutter/material.dart';
import '../models/layout.dart';
import '../models/control.dart';
import '../services/communication_service.dart';
import '../services/comm_type.dart';
import '../widgets/locked_button.dart';
import '../widgets/locked_slider.dart';
import '../widgets/locked_joystick.dart';

class ControlScreen extends StatefulWidget {
  final LayoutConfig layout;

  const ControlScreen({super.key, required this.layout});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final Map<ControlData, GlobalKey> _globalKeys = {};

  /// Gathers values from all locked widgets: 
  /// • Button → [0] or [1] 
  /// • Slider → [value] 
  /// • Joystick → [x, y]
  List<int> _collectAllValues() {
    final all = <int>[];
    for (var data in widget.layout.controls) {
      final key = _globalKeys[data];
      if (key == null) continue;
      final state = key.currentState;
      if (state is LockedButtonState) {
        all.addAll(state.getValues());
      } else if (state is LockedSliderState) {
        all.addAll(state.getValues());
      } else if (state is LockedJoystickState) {
        all.addAll(state.getValues());
      }
    }
    return all;
  }

  @override
  void initState() {
    super.initState();
    // Create a GlobalKey for each ControlData so we can read its state later:
    for (var data in widget.layout.controls) {
      _globalKeys[data] = GlobalKey();
    }

    // Determine which protocol to use based on saved commConfig['type']:
    final typeName = widget.layout.commConfig['type']!;
    final type = CommTypeExtension.fromString(typeName);

    // Start sending joystick data every 200ms (for example):
    CommunicationService.start(
      type,
      widget.layout.commConfig,
      _collectAllValues,
    );
  }

  @override
  void dispose() {
    CommunicationService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lockedWidgets = <Widget>[];

    for (var data in widget.layout.controls) {
      final key = _globalKeys[data]!;

      if (data.type == ControlType.button) {
        lockedWidgets.add(
          LockedButton(
            key: key,
            position: data.position,
            initialValue: data.values[0],
          ),
        );
      } else if (data.type == ControlType.slider) {
        // Fix: clamp(...) returns num, so cast to double
        final rawSliderValue = data.values[0].toDouble();
        final clampedSlider = (rawSliderValue.clamp(0, 255)) as double;

        lockedWidgets.add(
          LockedSlider(
            key: key,
            position: data.position,
            initialValue: clampedSlider,
          ),
        );
      } else if (data.type == ControlType.joystick) {
        // Fix: clamp(...) returns num, so cast to double
        final rawX = data.values[0].toDouble();
        final rawY = data.values[1].toDouble();
        final clampedX = (rawX.clamp(0, 255)) as double;
        final clampedY = (rawY.clamp(0, 255)) as double;

        lockedWidgets.add(
          LockedJoystick(
            key: key,
            position: data.position,
            initialValue: Offset(clampedX, clampedY),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.layout.name)),
      body: Stack(children: lockedWidgets),
    );
  }
}
