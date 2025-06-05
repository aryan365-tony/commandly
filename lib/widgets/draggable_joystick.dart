// lib/widgets/draggable_joystick.dart

import 'package:flutter/material.dart';

/// A draggable joystick used in the BUILDER screen.
///
/// • The entire base (a circle labelled “J” with a static knob) can be dragged.
/// • We use `pointerDragAnchorStrategy` so the feedback aligns under the finger,
///   preventing any vertical jump when you release.
/// • The final drop offset is converted to the parent Stack’s local coordinates.
class DraggableJoystick extends StatefulWidget {
  final Offset initialPosition;
  final Offset initialValue; // x,y each in [0..255]

  DraggableJoystick({
    super.key,
    required this.initialPosition,
    this.initialValue = const Offset(128, 128),
  });

  /// For LayoutBuilderScreen to read the final base position.
  Offset get position => _state?._position ?? initialPosition;

  /// For LayoutBuilderScreen to read the saved joystick X/Y.
  Offset get joystickValue {
    final s = _state;
    if (s == null) return const Offset(128, 128);
    final x = s._clamp(initialValue.dx) as double;
    final y = s._clamp(initialValue.dy) as double;
    return Offset(x, y);
  }

  _DraggableJoystickState? _state;

  @override
  State<DraggableJoystick> createState() => _DraggableJoystickState();
}

class _DraggableJoystickState extends State<DraggableJoystick> {
  late Offset _position;

  // Dimensions:
  static const double _baseSize = 100.0;
  static const double _knobSize = 40.0;
  static final double _baseRadius = _baseSize / 2;
  static final double _knobRadius = _knobSize / 2;
  static final double _maxKnobOffset = _baseRadius - _knobRadius;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
    widget._state = this;
  }

  /// Clamp a value into [0..255]
  num _clamp(num v) => v.clamp(0, 255);

  @override
  Widget build(BuildContext context) {
    // Compute knob offset inside base from saved initialValue:
    final rawX = (_clamp(widget.initialValue.dx)) as double;
    final rawY = (_clamp(widget.initialValue.dy)) as double;
    final knobDX = ((rawX - 128) / 127) * _maxKnobOffset;
    final knobDY = ((rawY - 128) / 127) * _maxKnobOffset;

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Draggable(
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: _buildJoystick(knobDX, knobDY),
        childWhenDragging: Container(),
        onDragEnd: (details) {
          // Convert the global drop point into the parent Stack’s coordinates:
          final parentBox = context.findAncestorRenderObjectOfType<RenderBox>();
          if (parentBox == null) return;
          final local = parentBox.globalToLocal(details.offset);

          setState(() {
            // Correct offset to center the joystick at drop point
            _position = Offset(local.dx - _baseRadius, local.dy - _baseRadius);
          });
        },
        child: _buildJoystick(knobDX, knobDY),
      ),
    );
  }

  /// Draw the circular base (“J”) and a static knob at (knobDX,knobDY).
  Widget _buildJoystick(double knobDX, double knobDY) {
    return SizedBox(
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
            child: const Center(
              child: Text(
                'J',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Knob (ball) at the saved initialValue:
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
    );
  }
}
