// lib/services/comm_factory.dart

import 'comm_type.dart';
import 'comm_handler.dart';
import 'http_handler.dart';
import 'mqtt_handler.dart';
import 'websocket_handler.dart';
import 'udp_handler.dart';
import 'ble_handler.dart';
import 'bluetooth_handler.dart'; // classic BT if you still need it

class CommFactory {
  static CommHandler create(
      CommType type, Map<String, String> config) {
    switch (type) {
      case CommType.mqtt:
        return MqttHandler(
          host: config['host']!,
          port: int.parse(config['port']!),
          topic: config['topic']!,
        );

      case CommType.http:
        return HttpHandler(config['endpoint']!);

      case CommType.websocket:
        return WebSocketHandler(config['url']!);

      case CommType.bluetooth:
        return BluetoothHandler(
          deviceId: config['deviceId']!,
          pin: config['pin'] ?? '',
        );

      case CommType.udp:
        return UdpHandler(
          host: config['host']!,
          port: int.parse(config['port']!),
        );

      case CommType.ble:
        return BleHandler(
          deviceId: config['deviceId']!,
          serviceUuid: config['serviceUuid']!,
          charUuid: config['charUuid']!,
        );
    }
  }
}
