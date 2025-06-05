// ignore_for_file: library_prefixes

import 'dart:math' as Math;

import 'package:flutter/material.dart';

/// A “locked” joystick for the CONTROL screen:
/// • The base is fixed at `widget.position`.
/// • The knob can be dragged within the base to change x,y (0–255).
/// • On release, the knob springs back to center (value [128,128]).
class LockedJoystick extends StatefulWidget {
  final Offset position;
  final Offset initialValue; // dx & dy (0–255)

  const LockedJoystick({
    super.key,
    required this.position,
    required this.initialValue,
  });

  @override
  State<LockedJoystick> createState() => LockedJoystickState();
}

class LockedJoystickState extends State<LockedJoystick> {
  // Current joystick value in [0..255], centered at 128.
  late Offset _joystickValue;

  // Base and knob sizes must match the builder for consistency:
  static const double _baseSize = 100;
  static const double _knobSize = 40;
  static final double _baseRadius = _baseSize / 2;
  static final double _knobRadius = _knobSize / 2;
  static final double _maxKnobOffset = _baseRadius - _knobRadius;

  @override
  void initState() {
    super.initState();
    _joystickValue = widget.initialValue;
  }

  /// Exposed to ControlScreen for collecting current values.
  List<int> getValues() => [
        _joystickValue.dx.toInt().clamp(0, 255),
        _joystickValue.dy.toInt().clamp(0, 255),
      ];

  /// Convert a local (x,y) inside the base into a new joystickValue [0..255].
  void _updateJoystickFromLocal(Offset localOffset) {
    final center = Offset(_baseRadius, _baseRadius);
    final delta = localOffset - center;
    final dist = delta.distance;
    final angle = delta.direction;
    final clampedDist = dist.clamp(0, _maxKnobOffset);
    final clampedDx = clampedDist * Math.cos(angle);
    final clampedDy = clampedDist * Math.sin(angle);
    final normX = (clampedDx / _maxKnobOffset) * 127 + 128;
    final normY = (clampedDy / _maxKnobOffset) * 127 + 128;
    setState(() {
      _joystickValue = Offset(normX.clamp(0, 255), normY.clamp(0, 255));
    });
  }

  void _resetKnob() {
    setState(() {
      _joystickValue = const Offset(128, 128);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Compute knobDX / knobDY to position the knob inside base:
    final rawX = _joystickValue.dx;
    final rawY = _joystickValue.dy;
    final knobDX =
        ((rawX - 128) / 127) * _maxKnobOffset; // ∈ [-_maxKnobOffset, +_maxKnobOffset]
    final knobDY =
        ((rawY - 128) / 127) * _maxKnobOffset; // ∈ [-_maxKnobOffset, +_maxKnobOffset]

    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: GestureDetector(
        onPanStart: (details) {
          final local = details.localPosition;
          _updateJoystickFromLocal(local);
        },
        onPanUpdate: (details) {
          final local = details.localPosition;
          _updateJoystickFromLocal(local);
        },
        onPanEnd: (_) => _resetKnob(),
        child: SizedBox(
          width: _baseSize,
          height: _baseSize,
          child: Stack(
            children: [
              // Base circle
              Container(
                width: _baseSize,
                height: _baseSize,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              // Knob circle
              Positioned(
                left: _baseRadius - _knobRadius + knobDX,
                top: _baseRadius - _knobRadius + knobDY,
                child: Container(
                  width: _knobSize,
                  height: _knobSize,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
