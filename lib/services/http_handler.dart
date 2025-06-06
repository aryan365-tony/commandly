import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'comm_handler.dart';

/// Sends joystick data to a REST endpoint via HTTP POST as JSON.
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
      final jsonBody = jsonEncode({
        'x': data.isNotEmpty ? data[0] : 0,
        'y': data.length > 1 ? data[1] : 0,
      });

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonBody,
      );

      if (response.statusCode != 200) {
        debugPrint('HTTP error: ${response.statusCode}');
      } else {
        debugPrint('HTTP success: ${response.statusCode}');
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
