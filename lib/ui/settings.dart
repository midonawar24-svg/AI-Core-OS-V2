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
      appBar: AppBar(title: const Text('إعدادات AI Core OS V2 Pro')),
      body: _stats == null ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.all(16), children: [
        Card(color: Colors.white.withOpacity(0.05), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('حالة العقل AICore', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
          const SizedBox(height: 8),
          Text('التطور: ${_stats!['evolution'].toStringAsFixed(1)}%'),
          Text('الوصف: ${_stats!['description']}'),
          const Divider(),
          Text('المحادثات: ${_stats!['total']}'),
          Text('الحقائق: ${(_stats!['facts'] as List).length}'),
          Text('الهيكل: core/ + database/ + models/ + services/ + ui/ + voice/ + security/ + utils/'),
        ]))),
        const SizedBox(height: 12),
        Card(color: Colors.white.withOpacity(0.05), child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          const Text('تغيير PIN'),
          TextField(controller: _pinController, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'PIN جديد')),
          const SizedBox(height: 6),
          ElevatedButton(onPressed: () async { await _pinService.save(_pinController.text); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ PIN'))); }, child: const Text('حفظ')),
        ]))),
        const SizedBox(height: 12),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () async { await _aiCore.clearAll(); await _load(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم مسح SQLite'))); }, child: const Text('مسح كل شيء')),
        const SizedBox(height: 20),
        const Text('AI Core OS V2 Pro\n• core/: ai_core, brain, memory, decision, learning, knowledge, personality\n• database/: database.dart, tables.dart\n• models/: fact, conversation, message\n• services/: storage, permission, logger\n• ui/: dashboard, chat_screen, settings, memory_screen\n• voice/, security/, utils/\n• 100% أوفلاين - جاهز لـ Gemma/Qwen/Phi', style: TextStyle(color: Colors.white38, fontSize: 10), textAlign: TextAlign.center),
      ]),
    );
  }
}
