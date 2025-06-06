// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import '../widgets/draggable_button.dart';
import '../widgets/draggable_slider.dart';
import '../widgets/draggable_joystick.dart';
import '../models/control.dart';
import '../models/layout.dart';
import '../services/layout_service.dart';
import 'communication_config_screen.dart';

/// Step 1: Builder Screen – user adds/drags controls.
/// Step 2: On “Next →”, we collect each widget’s final position and value
///         into a List<ControlData>, then move to CommunicationConfigScreen.
class LayoutBuilderScreen extends StatefulWidget {
  const LayoutBuilderScreen({super.key});

  @override
  State<LayoutBuilderScreen> createState() => _LayoutBuilderScreenState();
}

class _LayoutBuilderScreenState extends State<LayoutBuilderScreen> {
  final List<DraggableButton> _buttons = [];
  final List<DraggableSlider> _sliders = [];
  final List<DraggableJoystick> _joysticks = [];

  void _addButton() {
    final btn = DraggableButton(initialPosition: const Offset(100, 100));
    setState(() => _buttons.add(btn));
  }

  void _addSlider() {
    final sld = DraggableSlider(initialPosition: const Offset(100, 240));
    setState(() => _sliders.add(sld));
  }

  void _addJoystick() {
    final joy = DraggableJoystick(initialPosition: const Offset(100, 380));
    setState(() => _joysticks.add(joy));
  }

  void _goToConfig() {
    final allControls = <ControlData>[];

    // For each button, read its type, position, and pressed state (0 or 1)
    for (var btn in _buttons) {
      final pos = btn.position;
      final val = btn.isPressed ? 1 : 0;
      allControls.add(ControlData(
        type: ControlType.button,
        position: pos,
        values: [val],
      ));
    }

    // For each slider, read its position and 0–255 value
    for (var sld in _sliders) {
      final pos = sld.position;
      final val = sld.value.toInt().clamp(0, 255);
      allControls.add(ControlData(
        type: ControlType.slider,
        position: pos,
        values: [val],
      ));
    }

    // For each joystick, read its position and [x, y] (each 0–255)
    for (var joy in _joysticks) {
      final pos = joy.position;
      final x = joy.joystickValue.dx.toInt().clamp(0, 255);
      final y = joy.joystickValue.dy.toInt().clamp(0, 255);
      allControls.add(ControlData(
        type: ControlType.joystick,
        position: pos,
        values: [x, y],
      ));
    }

    if (allControls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one control before proceeding.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommunicationConfigScreen(controlDataList: allControls),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // We show all three kinds of controls in one Stack to allow layering:
    final allWidgets = <Widget>[
      ..._joysticks,
      ..._buttons,
      ..._sliders,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Design Layout')),
      body: Stack(children: allWidgets),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32), // 👈 change this value
                ),
              heroTag: 'joy_btn',
              onPressed: _addJoystick,
              child: const Icon(Icons.gamepad),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32), // 👈 change this value
                ),
              heroTag: 'btn_btn',
              onPressed: _addButton,
              child: const Icon(Icons.radio_button_checked),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32), // 👈 change this value
                ),
              heroTag: 'sld_btn',
              onPressed: _addSlider,
              child: const Icon(Icons.linear_scale),
            ),
            const SizedBox(height: 20),
            FloatingActionButton.extended(
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32), // 👈 change this value
                ),
              heroTag: 'next_btn',
              label: const Text('Next'),
              icon: const Icon(Icons.arrow_forward),
              onPressed: _goToConfig,
            ),
          ],
        ),
      ),
    );
  }
}
