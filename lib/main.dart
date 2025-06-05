import 'package:flutter/material.dart';
import 'screens/start_screen.dart';
import 'services/layout_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LayoutService.init(); // Load persisted layouts from local storage
  runApp(const RemoteApp());
}

class RemoteApp extends StatelessWidget {
  const RemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universal Remote',
      theme: ThemeData.dark(useMaterial3: true),
      home: const StartScreen(),
    );
  }
}
