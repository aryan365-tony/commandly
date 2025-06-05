import 'package:flutter/material.dart';

/// The type of a control: joystick, button, or slider.
enum ControlType { joystick, button, slider }

/// Holds one control’s data: its type, its position on-screen,
/// and its current values (0–255 or 0/1 for button).
///
/// Includes JSON (de)serialization for persistence.
class ControlData {
  final ControlType type;
  final Offset position;
  final List<int> values; // button→[0 or 1], slider→[0..255], joystick→[x, y]

  ControlData({
    required this.type,
    required this.position,
    required this.values,
  });

  /// Convert to a JSON‐compatible map.
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last, // 'joystick'|'button'|'slider'
      'position': {
        'dx': position.dx,
        'dy': position.dy,
      },
      'values': values,
    };
  }

  /// Create a ControlData from a JSON map.
  factory ControlData.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final type = ControlType.values.firstWhere(
      (e) => e.toString().split('.').last == typeStr,
    );
    final posMap = json['position'] as Map<String, dynamic>;
    final dx = (posMap['dx'] as num).toDouble();
    final dy = (posMap['dy'] as num).toDouble();
    final valuesList =
        (json['values'] as List<dynamic>).map((e) => (e as num).toInt()).toList();
    return ControlData(
      type: type,
      position: Offset(dx, dy),
      values: valuesList,
    );
  }
}
