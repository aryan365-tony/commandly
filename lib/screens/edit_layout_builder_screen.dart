import 'package:flutter/material.dart';
import '../widgets/draggable_button.dart';
import '../widgets/draggable_slider.dart';
import '../widgets/draggable_joystick.dart';
import '../models/control.dart';
import '../models/layout.dart';
import 'edit_communication_config_screen.dart';

/// Part 1 of editing: show the builder area, pre‐populated with saved controls.
/// On “Next →” we collect ControlData and pass to EditCommunicationConfigScreen.
class EditLayoutBuilderScreen extends StatefulWidget {
  final LayoutConfig existingLayout;
  final int index;

  const EditLayoutBuilderScreen({
    super.key,
    required this.existingLayout,
    required this.index,
  });

  @override
  State<EditLayoutBuilderScreen> createState() =>
      _EditLayoutBuilderScreenState();
}

class _EditLayoutBuilderScreenState extends State<EditLayoutBuilderScreen> {
  // Lists of builder widgets, pre‐filled from existingLayout.controls:
  final List<DraggableButton> _buttons = [];
  final List<DraggableSlider> _sliders = [];
  final List<DraggableJoystick> _joysticks = [];

  @override
  void initState() {
    super.initState();
    // Populate builder widgets from ControlData:
    for (var data in widget.existingLayout.controls) {
      switch (data.type) {
        case ControlType.button:
          _buttons.add(DraggableButton(
            initialPosition: data.position,
            initialIsPressed: data.values[0] == 1,
          ));
          break;
        case ControlType.slider:
          _sliders.add(DraggableSlider(
            initialPosition: data.position,
            initialValue: data.values[0].toDouble().clamp(0, 255),
          ));
          break;
        case ControlType.joystick:
          _joysticks.add(DraggableJoystick(
            initialPosition: data.position,
            initialValue: Offset(
              data.values[0].toDouble().clamp(0, 255),
              data.values[1].toDouble().clamp(0, 255),
            ),
          ));
          break;
      }
    }
  }

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
    final allControlData = <ControlData>[];

    // Collect current ControlData from builder widgets:
    for (var btn in _buttons) {
      final pos = btn.position;
      final val = btn.isPressed ? 1 : 0;
      allControlData.add(ControlData(
        type: ControlType.button,
        position: pos,
        values: [val],
      ));
    }
    for (var sld in _sliders) {
      final pos = sld.position;
      final val = sld.value.toInt().clamp(0, 255);
      allControlData.add(ControlData(
        type: ControlType.slider,
        position: pos,
        values: [val],
      ));
    }
    for (var joy in _joysticks) {
      final pos = joy.position;
      final x = joy.joystickValue.dx.toInt().clamp(0, 255);
      final y = joy.joystickValue.dy.toInt().clamp(0, 255);
      allControlData.add(ControlData(
        type: ControlType.joystick,
        position: pos,
        values: [x, y],
      ));
    }

    if (allControlData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one control before proceeding.')),
      );
      return;
    }

    // Push the edit config screen, passing in pre-collected ControlData:
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditCommunicationConfigScreen(
          index: widget.index,
          controlDataList: allControlData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Combine all builder widgets into one Stack:
    final builderWidgets = <Widget>[
      ..._joysticks,
      ..._buttons,
      ..._sliders,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Layout – Arrange Controls')),
      body: Stack(children: builderWidgets),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'edit_joy',
              onPressed: _addJoystick,
              child: const Icon(Icons.gamepad),
              tooltip: 'Add Joystick',
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'edit_btn',
              onPressed: _addButton,
              child: const Icon(Icons.radio_button_checked),
              tooltip: 'Add Button',
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'edit_sld',
              onPressed: _addSlider,
              child: const Icon(Icons.linear_scale),
              tooltip: 'Add Slider',
            ),
            const SizedBox(height: 20),
            FloatingActionButton.extended(
              heroTag: 'edit_next',
              label: const Text('Next →'),
              icon: const Icon(Icons.arrow_forward),
              onPressed: _goToConfig,
              tooltip: 'Configure Details',
            ),
          ],
        ),
      ),
    );
  }
}
