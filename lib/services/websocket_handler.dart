import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'comm_handler.dart';

/// Sends joystick data as a comma‐separated string (e.g. "128,64") over WS.
/// Expects `url` to be a valid WebSocket URL (e.g. "ws://192.168.1.50:8080").
class WebSocketHandler implements CommHandler {
  final String url;
  late WebSocketChannel _channel;

  WebSocketHandler(this.url);

  @override
  Future<void> connect() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      debugPrint('WebSocket: Connected to $url');
    } catch (e) {
      debugPrint('WebSocket: Connection error $e');
    }
  }

  @override
  void sendJoystickData(List<int> data) {
    final payload = data.join(',');
    try {
      _channel.sink.add(payload);
      debugPrint('WebSocket: Sent => $payload');
    } catch (e) {
      debugPrint('WebSocket: Send error $e');
    }
  }

  @override
  void disconnect() {
    _channel.sink.close(status.normalClosure);
    debugPrint('WebSocket: Closed');
  }
}
