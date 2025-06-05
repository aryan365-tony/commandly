import 'package:flutter/material.dart';

/// A draggable button used in the BUILDER screen.
/// Now you can pass `initialIsPressed` so it restores that state when editing.
class DraggableButton extends StatefulWidget {
  final Offset initialPosition;
  final bool initialIsPressed;

  DraggableButton({
    super.key,
    required this.initialPosition,
    this.initialIsPressed = false,
  });

  // Expose getters so EditLayoutScreen can read the final position and isPressed:
  bool get isPressed => _state?._isPressed ?? initialIsPressed;
  Offset get position => _state?._position ?? initialPosition;

  _DraggableButtonState? _state;

  @override
  State<DraggableButton> createState() => _DraggableButtonState();
}

class _DraggableButtonState extends State<DraggableButton> {
  late Offset _position;
  late bool _isPressed;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
    _isPressed = widget.initialIsPressed;
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
          child: const Center(child: Text('B', style: TextStyle(color: Colors.white))),
        ),
      ),
    );
  }
}
