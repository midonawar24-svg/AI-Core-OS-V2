import 'package:flutter/material.dart';
import 'ui/lock_screen.dart';
import 'core/ai_core.dart';

/// AI Core OS V2 Pro - Professional Structure
/// lib/
/// ├── core/ -> ai_core, brain, memory, decision, learning, knowledge, personality
/// ├── database/ -> database.dart, tables.dart
/// ├── models/ -> fact, conversation, message
/// ├── services/ -> storage, permission, logger
/// ├── ui/ -> dashboard, chat_screen, settings, memory_screen
/// ├── voice/ -> speech, tts
/// ├── security/ -> fingerprint, pin
/// └── utils/ -> constants, helpers

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final aiCore = AICore();
  await aiCore.init();
  runApp(const AICoreOSApp());
}

class AICoreOSApp extends StatelessWidget {
  const AICoreOSApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Core OS V2 Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090A0F),
        primaryColor: Colors.deepPurpleAccent,
        useMaterial3: true,
      ),
      home: const LockScreen(),
    );
  }
}
