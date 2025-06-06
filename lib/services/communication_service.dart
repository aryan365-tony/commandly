// lib/services/communication_service.dart

import 'dart:async';
import 'comm_handler.dart'; // ← Import the real CommHandler interface

/// CommunicationService is responsible for driving the periodic send loop.
/// We hold a reference to the currently active handler, and a Timer.
class CommunicationService {
  static CommHandler? _activeHandler;
  static Timer? _timer;

  /// Starts a periodic loop that, every [intervalMs] milliseconds, calls
  /// `handler.sendJoystickData(readValues())`.
  ///
  /// You must first call handler.connect() (which is done by ControlScreen below).
  static void startWithHandler(
    CommHandler handler,
    List<int> Function() readValues, {
    int intervalMs = 200,
  }) {
    _activeHandler = handler;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      final data = readValues();
      _activeHandler?.sendJoystickData(data);
    });
  }

  /// Stops the periodic send loop (if any). Does NOT disconnect the handler;
  /// you must call handler.disconnect() separately.
  static void stop() {
    _timer?.cancel();
    _timer = null;
    _activeHandler = null;
  }
}
