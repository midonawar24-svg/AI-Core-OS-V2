import 'package:flutter/material.dart';
import '../core/ai_core.dart';
import '../security/pin.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _aiCore = AICore();
  final _pinService = PinService();
  final _pinController = TextEditingController();
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await _aiCore.getStats();
    if (mounted) setState(() => _stats = s);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('V3 Settings - Neural Engine')),
      body: _stats == null ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.all(16), children: [
        Card(color: Colors.white.withOpacity(0.05), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('AI Core OS V3', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
          Text('التطور: ${_stats!['evolution'].toStringAsFixed(1)}%'),
          Text('الوصف: ${_stats!['description']}'),
          const Divider(),
          Text('المحادثات: ${_stats!['total']}'),
          Text('الحقائق: ${(_stats!['facts'] as List).length}'),
          Text('Neural Docs: ${_stats!['neural']['documents']}'),
          Text('Skills: ${_stats!['skills']}'),
        ]))),
        const SizedBox(height: 12),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () async { await _aiCore.clearAll(); await _load(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم المسح'))); }, child: const Text('مسح كل شيء')),
        const SizedBox(height: 20),
        const Text('V3 Improvements:\n• Tokenizer بدل contains()\n• Embeddings TF-IDF + Cosine\n• Transformer Attention\n• Inference Engine\n• Plugin System - Skills\n• DI بدل Singleton\n• Self Learning\n• جاهز لـ GGUF/ONNX/TFLite', style: TextStyle(color: Colors.white38, fontSize: 10), textAlign: TextAlign.center),
      ]),
    );
  }
}
