// ignore_for_file: unused_import

import 'package:flutter/material.dart';

/// Every handler must implement these three methods.
abstract class CommHandler {
  /// Establish any connection (e.g. open socket, pair BT, etc.).
  Future<void> connect();

  /// Send the joystick data (or button/slider data) as a raw list of ints.
  /// For a joystick: [x, y]; for a slider: [value]; for a button: [0 or 1].
  void sendJoystickData(List<int> data);

  /// Cleanly close the connection if needed.
  void disconnect();
}
