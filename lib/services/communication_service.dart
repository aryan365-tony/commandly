// ignore_for_file: unused_field

import 'dart:async';
import '../services/comm_type.dart';
import 'comm_factory.dart';
import 'comm_handler.dart';

class CommunicationService {
  static CommType? _type;
  static CommHandler? _handler;
  static Timer? _timer;

  /// Call this when entering “live” mode for a saved layout.
  static Future<void> start(
      CommType type,
      Map<String, String> commConfig,
      List<int> Function() getDataCallback,
      ) async {
    _type = type;
    _handler = CommFactory.create(type, commConfig);
    await _handler!.connect();

    // Send every 200ms (adjust as needed):
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      final data = getDataCallback();
      _handler!.sendJoystickData(data);
    });
  }

  /// Call this when exiting “live” mode (dispose screen).
  static void stop() {
    _timer?.cancel();
    _handler?.disconnect();
    _handler = null;
    _type = null;
  }
}
