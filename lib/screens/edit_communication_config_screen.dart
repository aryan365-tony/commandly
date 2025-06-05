import 'package:flutter/material.dart';
import '../models/control.dart';       // Make sure ControlData is in scope
import '../models/layout.dart';
import '../services/layout_service.dart';

class EditCommunicationConfigScreen extends StatefulWidget {
  final int index;
  final List<ControlData> controlDataList;

  const EditCommunicationConfigScreen({
    super.key,
    required this.index,
    required this.controlDataList,
  });

  @override
  State<EditCommunicationConfigScreen> createState() =>
      _EditCommunicationConfigScreenState();
}

class _EditCommunicationConfigScreenState
    extends State<EditCommunicationConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _layoutName;
  late String _protocol;
  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _topicController;

  @override
  void initState() {
    super.initState();
    final existing = LayoutService.layouts[widget.index];
    _layoutName = existing.name;
    final comm = existing.commConfig;
    _protocol = comm['protocol'] ?? 'WiFi';
    _hostController = TextEditingController(text: comm['host'] ?? '');
    _portController = TextEditingController(text: comm['port'] ?? '');
    _topicController = TextEditingController(text: comm['topic'] ?? '');
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  /// Called by the "Save Changes" button.
  Future<void> _saveEditedLayout() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final commConfig = <String, String>{
      'protocol': _protocol,
      'host': _hostController.text.trim(),
      'port': _portController.text.trim(),
    };
    if (_protocol.toLowerCase() == 'mqtt') {
      commConfig['topic'] = _topicController.text.trim();
    }

    final updatedLayout = LayoutConfig(
      name: _layoutName.trim(),
      controls: widget.controlDataList,
      commConfig: commConfig,
    );

    await LayoutService.updateLayout(widget.index, updatedLayout);

    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Layout – Configure Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _layoutName,
                decoration: const InputDecoration(labelText: 'Layout Name'),
                onSaved: (val) => _layoutName = val ?? _layoutName,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _protocol,
                decoration: const InputDecoration(labelText: 'Protocol'),
                items: <String>['WiFi', 'MQTT', 'BLE']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) {
                  setState(() => _protocol = val!);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hostController,
                decoration: const InputDecoration(labelText: 'Host / Broker'),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _portController,
                decoration: const InputDecoration(labelText: 'Port'),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              if (_protocol.toLowerCase() == 'mqtt') ...[
                TextFormField(
                  controller: _topicController,
                  decoration: const InputDecoration(labelText: 'Topic'),
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEditedLayout,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
