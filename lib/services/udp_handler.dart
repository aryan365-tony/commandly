import 'dart:io';
import 'package:flutter/material.dart';
import 'comm_handler.dart';

/// Broadcasts joystick data over UDP to a specified host:port.
/// Expects host = IP (e.g. "192.168.1.50"), port = e.g. 8888.
class UdpHandler implements CommHandler {
  final String host;
  final int port;
  RawDatagramSocket? _socket;
  InternetAddress? _address;

  UdpHandler({required this.host, required this.port});

  @override
  Future<void> connect() async {
    try {
      _address = InternetAddress(host);
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      debugPrint('UDP: Bound to anyIPv4, ready to send to $host:$port');
    } catch (e) {
      debugPrint('UDP: Bind error $e');
    }
  }

  @override
  void sendJoystickData(List<int> data) {
    if (_socket == null || _address == null) {
      debugPrint('UDP: Socket not ready');
      return;
    }
    final payloadString = data.join(',');
    final payloadBytes = payloadString.codeUnits;
    try {
      _socket!.send(payloadBytes, _address!, port);
      debugPrint('UDP: Sent to $host:$port => $payloadString');
    } catch (e) {
      debugPrint('UDP: Send error $e');
    }
  }

  @override
  void disconnect() {
    _socket?.close();
    debugPrint('UDP: Socket closed');
  }
}
