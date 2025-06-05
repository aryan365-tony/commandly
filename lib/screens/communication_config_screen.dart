import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/control.dart';
import '../models/layout.dart';
import '../services/layout_service.dart';
import '../services/comm_type.dart';

class CommunicationConfigScreen extends StatefulWidget {
  final List<ControlData> controlDataList;

  const CommunicationConfigScreen({super.key, required this.controlDataList});

  @override
  State<CommunicationConfigScreen> createState() =>
      _CommunicationConfigScreenState();
}

class _CommunicationConfigScreenState extends State<CommunicationConfigScreen> {
  final _formKey = GlobalKey<FormState>();

  // Selected protocol
  CommType? _selectedCommType = CommType.mqtt;

  // Common fields
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();

  // HTTP / WebSocket
  final TextEditingController _endpointController = TextEditingController();

  // Classic Bluetooth
  final TextEditingController _btDeviceController = TextEditingController();
  final TextEditingController _btPinController = TextEditingController();

  // BLE-specific
  final TextEditingController _bleDeviceController = TextEditingController();
  final TextEditingController _bleServiceController = TextEditingController();
  final TextEditingController _bleCharController = TextEditingController();

  // BLE scanning state
  bool _isScanning = false;
  final Map<DeviceIdentifier, ScanResult> _scanResults = {};

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _topicController.dispose();
    _endpointController.dispose();
    _btDeviceController.dispose();
    _btPinController.dispose();
    _bleDeviceController.dispose();
    _bleServiceController.dispose();
    _bleCharController.dispose();
    _stopBleScan();
    super.dispose();
  }

  Future<void> _startBleScan() async {
    if (_isScanning) return;
    setState(() {
      _scanResults.clear();
      _isScanning = true;
    });
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    FlutterBluePlus.scanResults.listen((results) {
      for (var result in results) {
        setState(() {
          _scanResults[result.device.remoteId] = result;
        });
      }
    });
    // After the timeout, stopScan will be called automatically
    FlutterBluePlus.isScanning.listen((scanning) {
      if (!scanning) {
        setState(() {
          _isScanning = false;
        });
      }
    });
  }

  void _stopBleScan() {
    if (_isScanning) {
      FlutterBluePlus.stopScan();
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _saveConfig() async {
    if (_formKey.currentState == null) return;
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final commConfig = <String, String>{
      'type': _selectedCommType!.toString().split('.').last,
    };

    switch (_selectedCommType!) {
      case CommType.mqtt:
        commConfig['host'] = _hostController.text.trim();
        commConfig['port'] = _portController.text.trim();
        commConfig['topic'] = _topicController.text.trim();
        break;

      case CommType.http:
        commConfig['endpoint'] = _endpointController.text.trim();
        break;

      case CommType.websocket:
        commConfig['url'] = _endpointController.text.trim();
        break;

      case CommType.bluetooth:
        commConfig['deviceId'] = _btDeviceController.text.trim();
        commConfig['pin'] = _btPinController.text.trim();
        break;

      case CommType.udp:
        commConfig['host'] = _hostController.text.trim();
        commConfig['port'] = _portController.text.trim();
        break;

      case CommType.ble:
        commConfig['deviceId'] = _bleDeviceController.text.trim();
        commConfig['serviceUuid'] = _bleServiceController.text.trim();
        commConfig['charUuid'] = _bleCharController.text.trim();
        break;
    }

    final layout = LayoutConfig(
      name: 'Unnamed', // Or ask for a name earlier in the flow
      controls: widget.controlDataList,
      commConfig: commConfig,
    );

    await LayoutService.addLayout(layout);

    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Communication Configuration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 1) Protocol Dropdown
              DropdownButtonFormField<CommType>(
                value: _selectedCommType,
                decoration: const InputDecoration(labelText: 'Protocol'),
                items: CommType.values
                    .map((ct) => DropdownMenuItem(
                          value: ct,
                          child: Text(ct.displayName),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() => _selectedCommType = val);
                  // If switching away from BLE, stop any ongoing scan
                  if (val != CommType.ble) {
                    _stopBleScan();
                  }
                },
                validator: (val) =>
                    val == null ? 'Select a communication type' : null,
              ),

              const SizedBox(height: 16),

              // 2) Conditional Fields:

              // ---- MQTT ----
              if (_selectedCommType == CommType.mqtt) ...[
                TextFormField(
                  controller: _hostController,
                  decoration: const InputDecoration(labelText: 'MQTT Host'),
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _portController,
                  decoration: const InputDecoration(labelText: 'MQTT Port'),
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _topicController,
                  decoration: const InputDecoration(labelText: 'MQTT Topic'),
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
              ],

              // ---- HTTP ----
              if (_selectedCommType == CommType.http) ...[
                TextFormField(
                  controller: _endpointController,
                  decoration:
                      const InputDecoration(labelText: 'HTTP Endpoint URL'),
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
              ],

              // ---- WebSocket ----
              if (_selectedCommType == CommType.websocket) ...[
                TextFormField(
                  controller: _endpointController,
                  decoration:
                      const InputDecoration(labelText: 'WebSocket URL'),
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
              ],

              // ---- Classic Bluetooth ----
              if (_selectedCommType == CommType.bluetooth) ...[
                TextFormField(
                  controller: _btDeviceController,
                  decoration:
                      const InputDecoration(labelText: 'BT Device ID (MAC)'),
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _btPinController,
                  decoration: const InputDecoration(labelText: 'PIN (optional)'),
                ),
              ],

              // ---- BLE ----
              if (_selectedCommType == CommType.ble) ...[
                // A) Scan button & status
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.bluetooth_searching),
                      label: Text(_isScanning ? 'Scanning...' : 'Scan for BLE'),
                      onPressed:
                          _isScanning ? null : () => _startBleScan(),
                    ),
                    const SizedBox(width: 16),
                    if (_isScanning) const CircularProgressIndicator(),
                  ],
                ),
                const SizedBox(height: 12),

                // B) List of discovered BLE devices
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: _scanResults.isEmpty
                      ? const Center(
                          child: Text(
                            'No devices found.\nTap "Scan for BLE" to search.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView(
                          children: _scanResults.values.map((r) {
                            final name =
                                (r.device.platformName.isNotEmpty) ? r.device.platformName : '(Unknown)';
                            final id = r.device.remoteId.str;
                            return ListTile(
                              title: Text(name),
                              subtitle: Text(id),
                              onTap: () {
                                // Populate the BLE Device ID field and stop scanning
                                _bleDeviceController.text = id;
                                _stopBleScan();
                              },
                            );
                          }).toList(),
                        ),
                ),

                const SizedBox(height: 12),

                // C) BLE Device ID (populated from list or typed manually)
                TextFormField(
                  controller: _bleDeviceController,
                  decoration: const InputDecoration(labelText: 'BLE Device ID'),
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // D) Service UUID
                TextFormField(
                  controller: _bleServiceController,
                  decoration: const InputDecoration(
                      labelText: 'BLE Service UUID (128-bit)'),
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // E) Characteristic UUID
                TextFormField(
                  controller: _bleCharController,
                  decoration: const InputDecoration(
                      labelText: 'BLE Characteristic UUID (128-bit)'),
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
              ],

              // ---- UDP ----
              if (_selectedCommType == CommType.udp) ...[
                TextFormField(
                  controller: _hostController,
                  decoration: const InputDecoration(labelText: 'UDP Host/IP'),
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _portController,
                  decoration: const InputDecoration(labelText: 'UDP Port'),
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 24),

              // 3) Save Button
              ElevatedButton(
                onPressed: _saveConfig,
                child: const Text('Save Configuration'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
