// lib/screens/control_screen.dart

import 'package:flutter/material.dart';
import '../models/layout.dart';
import '../models/control.dart';
import '../services/comm_handler.dart';           // only one interface
import '../services/communication_service.dart';   // for start/stop
import '../services/comm_type.dart';
import '../services/comm_factory.dart';
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
  bool _isConnected = false;
  late final CommHandler _commHandler;

  @override
  void initState() {
    super.initState();
    // Create a GlobalKey for each ControlData
    for (var data in widget.layout.controls) {
      _globalKeys[data] = GlobalKey();
    }
    // Instantiate the handler using the one CommHandler interface
    final typeName = widget.layout.commConfig['type']!;
    final type = CommTypeExtension.fromString(typeName);
    _commHandler = CommFactory.create(type, widget.layout.commConfig);
  }

  @override
  void dispose() {
    if (_isConnected) {
      CommunicationService.stop();
      _commHandler.disconnect();
    }
    super.dispose();
  }

  List<int> _collectAllValues() {
    final values = <int>[];
    for (var data in widget.layout.controls) {
      final key = _globalKeys[data];
      if (key == null) continue;
      final state = key.currentState;
      if (state is LockedButtonState) {
        values.addAll(state.getValues());
      } else if (state is LockedSliderState) {
        values.addAll(state.getValues());
      } else if (state is LockedJoystickState) {
        values.addAll(state.getValues());
      }
    }
    return values;
  }

  Future<void> _toggleConnection() async {
    if (!_isConnected) {
      try {
        await _commHandler.connect();
        CommunicationService.startWithHandler(
          _commHandler,
          _collectAllValues,
          intervalMs: 200,
        );
        setState(() => _isConnected = true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection failed: $e')),
        );
      }
    } else {
      CommunicationService.stop();
      _commHandler.disconnect();
      setState(() => _isConnected = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lockedWidgets = <Widget>[];
    for (var data in widget.layout.controls) {
      final key = _globalKeys[data] as GlobalKey;
      if (data.type == ControlType.button) {
        lockedWidgets.add(
          LockedButton(
            key: key,
            position: data.position,
            initialValue: data.values[0],
          ),
        );
      } else if (data.type == ControlType.slider) {
        final rawVal = data.values[0].toDouble();
        final clamped = (rawVal.clamp(0, 255)) as double;
        lockedWidgets.add(
          LockedSlider(
            key: key,
            position: data.position,
            initialValue: clamped,
          ),
        );
      } else if (data.type == ControlType.joystick) {
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
      floatingActionButton: OutlinedButton(
        onPressed: _toggleConnection,
        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          backgroundColor: _isConnected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          minimumSize: const Size(56, 56),
        ),
        child: Icon(
          _isConnected ? Icons.link_off : Icons.link,
          color: _isConnected
              ? Colors.white
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
