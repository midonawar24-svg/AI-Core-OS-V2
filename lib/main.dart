import 'package:flutter/material.dart';
import 'ui/lock_screen.dart';
import 'core/ai_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final aiCore = AICore();
  await aiCore.init();
  runApp(const AICoreOSV3App());
}

class AICoreOSV3App extends StatelessWidget {
  const AICoreOSV3App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Core OS V3',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF090A0F), primaryColor: Colors.deepPurpleAccent, useMaterial3: true),
      home: const LockScreen(),
    );
  }
}
