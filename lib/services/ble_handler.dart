// lib/services/ble_handler.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'comm_handler.dart';

/// BLE Handler for sending joystick data over a known service/characteristic.
/// Expects the following in the config map:
///   - 'deviceId'    : The BLE device’s ID (on Android, the MAC address string)
///   - 'serviceUuid' : The 128-bit service UUID string
///   - 'charUuid'    : The 128-bit characteristic UUID string to write to
///
/// Usage:
///   final handler = BleHandler(
///     deviceId: 'AA:BB:CC:DD:EE:FF',
///     serviceUuid: '12345678-1234-5678-1234-56789abcdef0',
///     charUuid: '87654321-4321-8765-4321-0fedcba98765',
///   );
///   await handler.connect();
///   handler.sendJoystickData([128, 64]);
///   handler.disconnect();
class BleHandler implements CommHandler {
  final String deviceId;    // e.g. "AA:BB:CC:DD:EE:FF"
  final Guid serviceUuid;   // e.g. Guid("12345678-1234-5678-1234-56789abcdef0")
  final Guid charUuid;      // e.g. Guid("87654321-4321-8765-4321-0fedcba98765")

  BluetoothDevice? _device;
  BluetoothCharacteristic? _characteristic;
  bool _isConnected = false;

  BleHandler({
    required this.deviceId,
    required String serviceUuid,
    required String charUuid,
  })  : serviceUuid = Guid(serviceUuid),
        charUuid = Guid(charUuid);

  @override
  Future<void> connect() async {

    // 1) Scan for up to 5 seconds to find the device by ID
    _device = null;
    _characteristic = null;
    _isConnected = false;

    debugPrint('BLE: Scanning for device $deviceId...');
    try {
      // Stop any previous scan
      await FlutterBluePlus.stopScan();

      // Start a new scan for 5 seconds, optionally filtering by service UUID
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 5),
        withServices: [serviceUuid],
      );

      // Flatten scanResults (Stream<List<ScanResult>>) into individual ScanResult events
      ScanResult? foundResult;
      try {
        foundResult = await FlutterBluePlus.scanResults
            .expand((list) => list)
            .firstWhere(
              (r) => r.device.remoteId.str.toLowerCase() == deviceId.toLowerCase(),
              orElse: () => throw Exception('Not found'),
            );
      } catch (_) {
        foundResult = null;
      }

      // Stop scanning once we've found the device (or timed out)
      await FlutterBluePlus.stopScan();

      if (foundResult != null) {
        _device = foundResult.device;
        debugPrint('BLE: Found device $deviceId via scan.');
      } else {
        throw Exception('BLE: Device $deviceId not found after scanning.');
      }
    } catch (e) {
      debugPrint('BLE: Scan error: $e');
      rethrow;
    }

    // 2) Connect to the device
    try {
      debugPrint('BLE: Connecting to $deviceId...');
      await _device!.connect(
        timeout: const Duration(seconds: 10),
        autoConnect: false,
      );
      _isConnected = true;
      debugPrint('BLE: Connected to $deviceId');
    } catch (e) {
      debugPrint('BLE: Connection error: $e');
      rethrow;
    }

    // 3) Discover services & characteristics
    List<BluetoothService> services = [];
    try {
      services = await _device!.discoverServices();
    } catch (e) {
      debugPrint('BLE: Service discovery error: $e');
      rethrow;
    }

    // 4) Find the target characteristic under the matching service
    for (var svc in services) {
      if (svc.uuid == serviceUuid) {
        for (var char in svc.characteristics) {
          if (char.uuid == charUuid) {
            _characteristic = char;
            break;
          }
        }
        if (_characteristic != null) break;
      }
    }

    if (_characteristic == null) {
      throw Exception(
        'BLE: Characteristic $charUuid not found under service $serviceUuid');
    }

    debugPrint('BLE: Service & characteristic ready.');
  }

  @override
  void sendJoystickData(List<int> data) {
    if (!_isConnected || _characteristic == null) {
      debugPrint('BLE: Not connected or characteristic missing.');
      return;
    }
    try {
      // Convert List<int> ([x, y]) into Uint8List
      final bytes = Uint8List.fromList(data);
      // Write without response for minimal latency
      _characteristic!.write(bytes, withoutResponse: true);
      debugPrint('BLE: Wrote data => ${data.join(",")}');
    } catch (e) {
      debugPrint('BLE: Write error: $e');
    }
  }

  @override
  void disconnect() {
    if (_device != null && _isConnected) {
      _device!.disconnect();
      _isConnected = false;
      debugPrint('BLE: Disconnected from $deviceId');
    }
  }
}
