import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'comm_handler.dart';

/// Sends joystick data to a REST endpoint via HTTP POST.
/// Expects `endpoint` to be a valid URL (e.g. "http://192.168.1.100:5000/joystick").
class HttpHandler implements CommHandler {
  final String endpoint;

  HttpHandler(this.endpoint);

  @override
  Future<void> connect() async {
    // No persistent connection needed for HTTP.
    debugPrint('HTTP: no connect needed.');
  }

  @override
  void sendJoystickData(List<int> data) async {
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        body: {
          'x': data[0].toString(),
          'y': data.length > 1 ? data[1].toString() : '0',
        },
      );
      if (response.statusCode != 200) {
        debugPrint('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('HTTP exception: $e');
    }
  }

  @override
  void disconnect() {
    // Nothing to close for HTTP.
    debugPrint('HTTP: no disconnect needed.');
  }
}
