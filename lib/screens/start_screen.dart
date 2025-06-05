// lib/screens/start_screen.dart

// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import '../services/layout_service.dart';
import 'layout_builder_screen.dart';
import 'control_screen.dart';
import 'edit_layout_builder_screen.dart';
import '../models/layout.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    final layouts = LayoutService.layouts;

    return Scaffold(
      appBar: AppBar(title: const Text('Universal Remote')),
      body: layouts.isEmpty
          ? const Center(child: Text('No layouts yet.\nTap + to create one.', textAlign: TextAlign.center))
          : ListView.builder(
              itemCount: layouts.length,
              itemBuilder: (context, i) {
                final layout = layouts[i];
                final protocol = layout.commConfig['protocol'] ?? '';
                final host = layout.commConfig['host'] ?? '';
                final port = layout.commConfig['port'] ?? '';
                final topic = layout.commConfig['topic'];
                final isMqtt = protocol.toLowerCase() == 'mqtt';

                final subtitleLines = <String>[
                  'Protocol: $protocol',
                  'Host: $host:$port',
                  if (isMqtt && (topic?.isNotEmpty ?? false)) 'Topic: $topic',
                ].join('\n');

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(layout.name),
                    subtitle: Text(subtitleLines),
                    isThreeLine: isMqtt,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ControlScreen(layout: layout)),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // EDIT (pencil) button:
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit Layout',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditLayoutBuilderScreen(
                                  existingLayout: layout,
                                  index: i,
                                ),
                              ),
                            ).then((_) {
                              setState(() {});
                            });
                          },
                        ),
                        // DELETE (trash) button:
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Delete Layout',
                          onPressed: () async {
                            // CORRECT: call the Future‐returning service method
                            await LayoutService.removeLayout(i);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LayoutBuilderScreen()),
          ).then((_) {
            setState(() {});
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
