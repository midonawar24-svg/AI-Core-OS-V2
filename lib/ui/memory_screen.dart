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
      appBar: AppBar(title: const Text('V3 - الذاكرة + Neural')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.all(12), children: [
        Card(color: Colors.white.withOpacity(0.05), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('الحقائق (facts table) + Skills', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          ..._facts.map((f) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.deepPurpleAccent.withOpacity(0.3), borderRadius: BorderRadius.circular(4)), child: Text(f.key, style: const TextStyle(fontSize: 9))), const SizedBox(width: 6), Expanded(child: Text(f.value, style: const TextStyle(fontSize: 11)))]))),
        ]))),
        const SizedBox(height: 12),
        Card(color: Colors.white.withOpacity(0.05), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Neural Engine Stats', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          FutureBuilder(future: _aiCore.getStats(), builder: (ctx, snap) { if (!snap.hasData) return const Text('...'); final data = snap.data!; final neural = data['neural'] as Map; return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Docs: ${neural['documents']}'), Text('Skills: ${data['skills']}'), Text('Threshold: ${neural['threshold']}')]); }),
        ]))),
      ]),
    );
  }
}
