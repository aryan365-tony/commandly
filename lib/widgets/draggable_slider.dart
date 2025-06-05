import 'package:flutter/material.dart';

/// A draggable slider used in the BUILDER screen.
/// Now you can pass `initialValue` (0–255) so it restores when editing.
class DraggableSlider extends StatefulWidget {
  final Offset initialPosition;
  final double initialValue; // 0–255

  DraggableSlider({
    super.key,
    required this.initialPosition,
    this.initialValue = 0,
  });

  double get value => _state?._value ?? initialValue;
  Offset get position => _state?._position ?? initialPosition;

  _DraggableSliderState? _state;

  @override
  State<DraggableSlider> createState() => _DraggableSliderState();
}

class _DraggableSliderState extends State<DraggableSlider> {
  late Offset _position;
  late double _value;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
    _value = widget.initialValue.clamp(0, 255);
    widget._state = this;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() => _position += details.delta);
        },
        child: SizedBox(
          width: 180,
          child: Slider(
            min: 0,
            max: 255,
            value: _value,
            onChanged: (val) => setState(() => _value = val),
          ),
        ),
      ),
    );
  }
}
