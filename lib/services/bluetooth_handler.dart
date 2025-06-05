import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'comm_handler.dart';

/// Connects to a paired classic‐Bluetooth device by address,
/// then sends joystick data as ASCII "128,64\n".
///
/// Expects:
///  - deviceId: MAC address string like "00:11:22:33:44:55"
///  - pin: if your device requires PIN, otherwise empty string.
class BluetoothHandler implements CommHandler {
  final String deviceId;
  final String pin;
  BluetoothConnection? _connection;

  BluetoothHandler({
    required this.deviceId,
    this.pin = '',
  });

  @override
  Future<void> connect() async {
    try {
      // If PIN is needed, you must have already paired the device in Settings.
      // Pin cant be sent programmatically in Android > 6 without user action.
      _connection = await BluetoothConnection.toAddress(deviceId);
      debugPrint('Bluetooth: Connected to $deviceId');
    } catch (e) {
      debugPrint('Bluetooth: Cannot connect, exception: $e');
    }
  }

  @override
  void sendJoystickData(List<int> data) {
    if (_connection == null) {
      debugPrint('Bluetooth: No active connection');
      return;
    }
    final payload = '${data.join(",")}\n';
    try {
      _connection!.output.add(utf8.encode(payload));
      debugPrint('Bluetooth: Sent => $payload');
    } catch (e) {
      debugPrint('Bluetooth: Send error $e');
    }
  }

  @override
  void disconnect() {
    try {
      _connection?.close();
      debugPrint('Bluetooth: Disconnected');
    } catch (e) {
      debugPrint('Bluetooth: Disconnect error $e');
    }
  }
}
