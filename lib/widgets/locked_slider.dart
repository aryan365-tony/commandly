import 'package:flutter/material.dart';

/// A “locked” slider for the CONTROL screen:
/// • Positioned at a fixed Offset.
/// • User can still slide the thumb to change between 0–255.
/// • Its State class is now `LockedSliderState` (public).
class LockedSlider extends StatefulWidget {
  final Offset position;
  final double initialValue; // 0–255

  const LockedSlider({
    super.key,
    required this.position,
    required this.initialValue,
  });

  @override
  State<LockedSlider> createState() => LockedSliderState();
}

class LockedSliderState extends State<LockedSlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  /// Expose the current slider value as [int].
  List<int> getValues() => [_value.toInt()];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: SizedBox(
        width: 180,
        child: Slider(
          min: 0,
          max: 255,
          value: _value,
          onChanged: (val) => setState(() => _value = val),
        ),
      ),
    );
  }
}
