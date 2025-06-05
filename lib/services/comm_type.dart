enum CommType {
  mqtt,
  http,
  websocket,
  bluetooth,
  udp,

  // Add BLE here:
  ble,
}

/// Extension to get a human-readable name from the enum.
extension CommTypeExtension on CommType {
  String get displayName {
    switch (this) {
      case CommType.mqtt:
        return 'MQTT';
      case CommType.http:
        return 'HTTP (REST)';
      case CommType.websocket:
        return 'WebSocket';
      case CommType.bluetooth:
        return 'Bluetooth (Classic)';
      case CommType.udp:
        return 'UDP';
      case CommType.ble:
        return 'Bluetooth Low Energy (BLE)';
    }
  }

  /// Parse from a string (the enum’s `toString().split('.').last`).
  static CommType fromString(String s) {
    return CommType.values.firstWhere(
      (e) => e.toString().split('.').last == s,
      orElse: () => CommType.http,
    );
  }
}
