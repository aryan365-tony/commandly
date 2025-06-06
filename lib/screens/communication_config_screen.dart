// lib/screens/communication_config_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/control.dart';
import '../models/layout.dart';
import '../services/layout_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
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

  // Layout name
  final TextEditingController _nameController = TextEditingController();

  // Selected protocol
  CommType? _selectedCommType = CommType.mqtt;

  // Common controllers (MQTT, HTTP, UDP, etc.)
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _endpointController = TextEditingController();

  // BLE: stored values behind the scenes
  String? _bleDeviceId;
  String? _bleServiceUuid;
  String? _bleCharUuid;

  // BLE scanning state
  bool _isScanning = false;
  final Map<DeviceIdentifier, ScanResult> _scanResults = {};

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _topicController.dispose();
    _endpointController.dispose();
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

      case CommType.udp:
        commConfig['host'] = _hostController.text.trim();
        commConfig['port'] = _portController.text.trim();
        break;

      case CommType.ble:
        if (_bleDeviceId == null ||
            _bleServiceUuid == null ||
            _bleCharUuid == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please pick a BLE device first')),
          );
          return;
        }
        commConfig['deviceId'] = _bleDeviceId!;
        commConfig['serviceUuid'] = _bleServiceUuid!;
        commConfig['charUuid'] = _bleCharUuid!;
        break;
    }

    final layout = LayoutConfig(
      name: _nameController.text.trim(),
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
      appBar: AppBar(title: const Text('New Control Layout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 0) Layout Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Layout Name',
                  hintText: 'Enter a name for this layout',
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // 1) Protocol Dropdown
              DropdownButtonFormField2<CommType>(
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Protocol',
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 16),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  filled: true,
                  fillColor: Colors.black,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue, width: 1.5),
                  ),
                  elevation: 4,
                  offset: const Offset(0, -4), // optional: adjust dropdown position
                ),
                buttonStyleData: const ButtonStyleData(
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 0),
                ),
                iconStyleData: const IconStyleData(
                  iconEnabledColor: Colors.white,
                ),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                items: CommType.values
                    .map((ct) => DropdownMenuItem(
                          value: ct,
                          child: Text(
                            ct.displayName,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ))
                    .toList(),
                value: _selectedCommType,
                onChanged: (val) {
                  setState(() => _selectedCommType = val);
                  if (val != CommType.ble) _stopBleScan();
                },
                validator: (val) => val == null ? 'Select a communication type' : null,
              ),                   
                            
              const SizedBox(height: 16),


              // --- MQTT ---
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
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Required';
                    if (int.tryParse(val.trim()) == null) return 'Must be a number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _topicController,
                  decoration: const InputDecoration(labelText: 'MQTT Topic'),
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
              ],

              // --- HTTP ---
              if (_selectedCommType == CommType.http) ...[
                TextFormField(
                  controller: _endpointController,
                  decoration:
                      const InputDecoration(labelText: 'HTTP Endpoint URL'),
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
              ],

              // --- WebSocket ---
              if (_selectedCommType == CommType.websocket) ...[
                TextFormField(
                  controller: _endpointController,
                  decoration:
                      const InputDecoration(labelText: 'WebSocket URL'),
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
              ],

              // --- UDP ---
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
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Required';
                    if (int.tryParse(val.trim()) == null) return 'Must be a number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
              ],

              // --- BLE ---
              if (_selectedCommType == CommType.ble) ...[
                // A) Scan button & indicator
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.bluetooth_searching),
                      label: Text(_isScanning ? 'Scanning...' : 'Scan for BLE'),
                      onPressed: _isScanning ? null : _startBleScan,
                    ),
                    const SizedBox(width: 16),
                    if (_isScanning) const CircularProgressIndicator(),
                  ],
                ),
                const SizedBox(height: 12),

                // B) Show list if no device chosen, else summary
                if (_bleDeviceId == null) ...[
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
                              final name = r.device.name.isNotEmpty
                                  ? r.device.name
                                  : '(Unknown)';
                              final id = r.device.remoteId.id;
                              return ListTile(
                                title: Text(name),
                                subtitle: Text(id),
                                onTap: () async {
                                  _bleDeviceId = id;
                                  try {
                                    await r.device.connect(
                                      timeout: const Duration(seconds: 5),
                                    );
                                    final services =
                                        await r.device.discoverServices();
                                    for (var svc in services) {
                                      for (var char in svc.characteristics) {
                                        if (char.properties.write) {
                                          _bleServiceUuid = svc.uuid.toString();
                                          _bleCharUuid = char.uuid.toString();
                                          break;
                                        }
                                      }
                                      if (_bleServiceUuid != null) break;
                                    }
                                    await r.device.disconnect();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('BLE discovery failed: $e')),
                                    );
                                  }
                                  _stopBleScan();
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Configured BLE Device:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Device ID: $_bleDeviceId'),
                          if (_bleServiceUuid != null)
                            Text('Service UUID: $_bleServiceUuid'),
                          if (_bleCharUuid != null)
                            Text('Characteristic UUID: $_bleCharUuid'),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Pick a Different Device'),
                            onPressed: () {
                              _bleDeviceId = null;
                              _bleServiceUuid = null;
                              _bleCharUuid = null;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],

              const SizedBox(height: 24),
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
