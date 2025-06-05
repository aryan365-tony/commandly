import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'comm_handler.dart';

/// Simple MQTT handler that connects to a broker and publishes control data.
/// Expects:
///   host: e.g. "test.mosquitto.org" or "192.168.1.50"
///   port: integer port (usually 1883)
///   topic: topic string to publish to (e.g. "robot/joystick")
class MqttHandler implements CommHandler {
  final String host;
  final int port;
  final String topic;
  late MqttServerClient _client;

  MqttHandler({
    required this.host,
    required this.port,
    required this.topic,
  });

  @override
  Future<void> connect() async {
    _client = MqttServerClient(host, '');
    _client.port = port;
    _client.logging(on: false);
    _client.keepAlivePeriod = 20;
    _client.onDisconnected = _onDisconnected;
    _client.onConnected = _onConnected;
    _client.onSubscribed = _onSubscribed;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('flutter_client_${DateTime.now().millisecondsSinceEpoch}')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client.connectionMessage = connMess;

    try {
      debugPrint('MQTT: Connecting to $host:$port...');
      await _client.connect();
    } catch (e) {
      debugPrint('MQTT: Connection failed - $e');
      _client.disconnect();
    }

    if (_client.connectionStatus!.state != MqttConnectionState.connected) {
      debugPrint('MQTT: ERROR - status is ${_client.connectionStatus}');
      _client.disconnect();
    } else {
      debugPrint('MQTT: Connected');
    }
  }

  void _onSubscribed(String topic) {
    debugPrint('MQTT: Subscribed to $topic');
  }

  void _onDisconnected() {
    debugPrint('MQTT: Disconnected');
  }

  void _onConnected() {
    debugPrint('MQTT: Connection successful');
  }

  @override
  void sendJoystickData(List<int> data) {
    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      final payload = '${data.join(",")}';
      final builder = MqttClientPayloadBuilder();
      builder.addString(payload);
      _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      debugPrint('MQTT: Published to $topic => $payload');
    } else {
      debugPrint('MQTT: Client not connected, cannot publish.');
    }
  }

  @override
  void disconnect() {
    _client.disconnect();
    debugPrint('MQTT: Client disconnected');
  }
}
