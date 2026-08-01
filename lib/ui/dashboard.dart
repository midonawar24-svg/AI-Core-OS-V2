import 'package:flutter/material.dart';
import '../core/ai_core.dart';
import '../voice/tts.dart';
import '../voice/speech.dart';
import 'memory_screen.dart';
import 'settings.dart';
import 'lock_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _aiCore = AICore();
  final _tts = TTSService();
  final _speech = SpeechService();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  String _thinking = 'جاري تهيئة Neural Engine...';
  bool _isProcessing = false;
  bool _isListening = false;
  List<Map<String, String>> _chat = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _aiCore.init();
    await _tts.init();
    setState(() {
      _thinking = '''🧠 AI Core OS V3 - Neural Engine
- Tokenizer: تحويل نص -> توكنز (بدل contains)
- Embeddings: TF-IDF + Cosine Similarity
- Transformer: Self-Attention
- Inference: استنتاج دلالي
- Skills: Plugin System (Name, Age, Time, Memory)
- DI: Dependency Injection
- SQLite + Self Learning

التطور: ${_aiCore.evolutionLevel.toStringAsFixed(1)}%
${_aiCore.evolutionDesc()}
جاهز لـ GGUF/ONNX/TFLite 🚀

جرب: "اسمي محمد" -> Tokenizer يحلل -> Skill يحفظ
''';
    });
  }

  Future<void> _process(String input) async {
    if (input.trim().isEmpty || _isProcessing) return;
    setState(() {
      _isProcessing = true;
      _chat.add({'role': 'user', 'text': input});
      _thinking = 'Neural Engine بيفكر...';
    });

    final result = await _aiCore.process(input);

    if (!mounted) return;
    setState(() {
      _thinking = result['thinking'];
      _chat.add({'role': 'ai', 'text': result['response']});
      _isProcessing = false;
    });

    _tts.speak(result['response']);
    _textController.clear();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  Future<void> _toggleListening() async {
    if (_isProcessing) return;
    if (!_isListening) {
      setState(() => _isListening = true);
      await _speech.start(onResult: (text) { if (mounted) setState(() => _textController.text = text); });
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
      if (_textController.text.isNotEmpty) _process(_textController.text);
    }
  }

  @override
  void dispose() {
    _tts.dispose();
    _speech.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI CORE OS V3 - NEURAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.black.withOpacity(0.4),
        actions: [
          IconButton(icon: const Icon(Icons.memory, color: Colors.cyanAccent, size: 20), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryScreen()))),
          IconButton(icon: const Icon(Icons.settings, size: 18), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
          IconButton(icon: const Icon(Icons.lock_outline, size: 16), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LockScreen()))),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF090A0F), Color(0xFF10121E)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.cyanAccent.withOpacity(0.2))),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text(_aiCore.isInitialized ? _aiCore.evolutionDesc() : 'جاري التحميل...', style: const TextStyle(color: Colors.white70, fontSize: 9))),
                  Text('${_aiCore.evolutionLevel.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 6),
                ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: _aiCore.evolutionLevel / 100, minHeight: 5, backgroundColor: Colors.white12, color: Colors.cyanAccent)),
              ]),
            ),
            const SizedBox(height: 8),
            Container(width: double.infinity, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.2))), child: Text(_thinking, style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 8.5), maxLines: 10, overflow: TextOverflow.ellipsis)),
            const SizedBox(height: 8),
            Expanded(child: Container(decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)), child: ListView.builder(controller: _scrollController, itemCount: _chat.length, itemBuilder: (ctx, i) { final item = _chat[i]; final isUser = item['role'] == 'user'; return Align(alignment: isUser ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8), padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: isUser ? Colors.deepPurpleAccent.withOpacity(0.25) : Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)), child: Text(item['text']!, style: TextStyle(color: isUser ? Colors.white : Colors.white70, fontSize: 12)))); }))),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextField(controller: _textController, enabled: !_isProcessing, onSubmitted: _process, style: const TextStyle(fontSize: 12), decoration: InputDecoration(hintText: _isListening ? 'بسمعك...' : 'اكتب لنوار V3...', hintStyle: const TextStyle(fontSize: 10), filled: true, fillColor: Colors.white.withOpacity(0.08), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)))),
              const SizedBox(width: 6),
              FloatingActionButton.small(onPressed: _isProcessing ? null : () { if (_textController.text.isNotEmpty && !_isListening) _process(_textController.text); else _toggleListening(); }, backgroundColor: _isProcessing ? Colors.grey : (_isListening ? Colors.redAccent : Colors.deepPurpleAccent), child: Icon(_isListening ? Icons.mic : (_textController.text.isNotEmpty ? Icons.send : Icons.mic_none), size: 16)),
            ]),
          ]),
        ),
      ),
    );
  }
}
