import 'package:flutter/material.dart';
import '../core/ai_core.dart';
import '../models/fact.dart';
import '../models/conversation.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});
  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final _aiCore = AICore();
  List<Fact> _facts = [];
  List<Conversation> _recent = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await _aiCore.getStats();
    setState(() {
      _facts = stats['facts'] as List<Fact>;
      _recent = stats['recent'] as List<Conversation>;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ذاكرة نوار - SQLite - Tables')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.all(12), children: [
        Card(color: Colors.white.withOpacity(0.05), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('الحقائق المحفوظة (database/tables.dart -> facts)', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          ..._facts.map((f) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.deepPurpleAccent.withOpacity(0.3), borderRadius: BorderRadius.circular(4)), child: Text(f.key, style: const TextStyle(fontSize: 9))), const SizedBox(width: 6), Expanded(child: Text(f.value, style: const TextStyle(fontSize: 11))), Text(f.type, style: const TextStyle(fontSize: 7, color: Colors.white38))]))),
          if (_facts.isEmpty) const Text('لا توجد حقائق - قل "اسمي محمد"', style: TextStyle(color: Colors.white38, fontSize: 10)),
        ]))),
        const SizedBox(height: 12),
        Card(color: Colors.white.withOpacity(0.05), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('آخر المحادثات (conversations table)', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          ..._recent.reversed.map((c) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('أنت: ${c.input}', style: const TextStyle(fontSize: 10, color: Colors.white70)),
            Text('نوار: ${c.output}', style: const TextStyle(fontSize: 10, color: Colors.cyanAccent)),
            Text('${c.intent.split('.').last} • ${(c.confidence * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 7, color: Colors.white30)),
            const Divider(height: 10, color: Colors.white10),
          ]))),
        ]))),
      ]),
    );
  }
}
