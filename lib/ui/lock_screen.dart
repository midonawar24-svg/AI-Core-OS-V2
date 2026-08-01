import 'package:flutter/material.dart';
import '../security/pin.dart';
import '../security/fingerprint.dart';
import 'dashboard.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _pinController = TextEditingController();
  final _pinService = PinService();
  final _fingerService = FingerprintService();
  String _error = '';
  bool _canBio = false;

  @override
  void initState() {
    super.initState();
    _checkBio();
  }

  Future<void> _checkBio() async {
    final can = await _fingerService.canCheck();
    if (mounted) setState(() => _canBio = can);
  }

  Future<void> _checkPin() async {
    final ok = await _pinService.verify(_pinController.text);
    if (ok) {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Dashboard()));
    } else {
      setState(() => _error = 'PIN غير صحيح');
    }
  }

  Future<void> _bio() async {
    final ok = await _fingerService.auth();
    if (ok && mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Dashboard()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF090A0F), Color(0xFF181B26), Color(0xFF221A3A)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.cyanAccent.withOpacity(0.1), border: Border.all(color: Colors.cyanAccent.withOpacity(0.3))), child: const Icon(Icons.psychology, size: 80, color: Colors.cyanAccent)),
          const SizedBox(height: 24),
          const Text('AI CORE OS', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 3, color: Colors.white)),
          const Text('V3 - NEURAL ENGINE', style: TextStyle(color: Colors.cyanAccent, fontSize: 12, letterSpacing: 2)),
          const SizedBox(height: 6),
          const Text('Tokenizer + Embeddings + Transformer + Skills', style: TextStyle(color: Colors.white38, fontSize: 9)),
          const SizedBox(height: 48),
          TextField(controller: _pinController, obscureText: true, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, letterSpacing: 10, fontWeight: FontWeight.bold), decoration: InputDecoration(hintText: '• • • •', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), filled: true, fillColor: Colors.white.withOpacity(0.08)), onSubmitted: (_) => _checkPin()),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 54, child: ElevatedButton(onPressed: _checkPin, style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('دخول النظام', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)))),
          const SizedBox(height: 24),
          if (_canBio) InkWell(onTap: _bio, child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.cyanAccent)), child: const Icon(Icons.fingerprint, size: 48, color: Colors.cyanAccent))),
          if (_error.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 16), child: Text(_error, style: const TextStyle(color: Colors.redAccent))),
        ]))),
      ),
    );
  }
}
