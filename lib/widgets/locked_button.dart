import 'package:flutter/material.dart';

/// A “locked” button for the CONTROL screen:
/// • Positioned at a fixed Offset.
/// • Tapping toggles between 0 and 1 internally.
/// • Its State class is now named `LockedButtonState` (public) so other files can do `is LockedButtonState`.
class LockedButton extends StatefulWidget {
  final Offset position;
  final int initialValue; // 0 or 1

  const LockedButton({
    super.key,
    required this.position,
    required this.initialValue,
  });

  @override
  State<LockedButton> createState() => LockedButtonState();
}

class LockedButtonState extends State<LockedButton> {
  late bool _isPressed;

  @override
  void initState() {
    super.initState();
    _isPressed = widget.initialValue == 1;
  }

  /// Expose the current pressed state as a list of ints [0] or [1].
  List<int> getValues() => [_isPressed ? 1 : 0];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _isPressed ? Colors.red : Colors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white),
          ),
          child: const Center(
            child: Text('B', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
