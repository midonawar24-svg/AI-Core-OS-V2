import 'memory.dart';
import 'knowledge.dart';
import 'decision.dart';
import 'learning.dart';
import 'brain.dart';
import 'personality.dart';
import '../database/database.dart';
import '../neural/neural_engine.dart';
import '../plugins/plugin_manager.dart';
import 'skills/name_skill.dart';
import 'skills/age_skill.dart';
import 'skills/time_skill.dart';
import 'skills/memory_skill.dart';
import '../services/di_service.dart';

/// AI Core OS V3 - مع DI + Neural Engine + Plugin System
class AICore {
  static final AICore _instance = AICore._internal();
  factory AICore() => _instance;
  AICore._internal();

  late Memory memory;
  late Knowledge knowledge;
  late DecisionEngine decisionEngine;
  late Learning learning;
  late Brain brain;
  late Personality personality;
  late AppDatabase database;
  late NeuralEngine neuralEngine;
  late PluginManager pluginManager;

  bool _initialized = false;
  double _evolution = 50.0;

  double get evolutionLevel => _evolution;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;

    // DI Setup
    di.registerSingleton<AppDatabase>(AppDatabase());
    di.registerSingleton<NeuralEngine>(NeuralEngine());
    di.registerSingleton<PluginManager>(PluginManager());

    database = di.get<AppDatabase>();
    neuralEngine = di.get<NeuralEngine>();
    pluginManager = di.get<PluginManager>();

    // Register Skills - Plugin System
    pluginManager.registerSkill(NameSkill());
    pluginManager.registerSkill(AgeSkill());
    pluginManager.registerSkill(TimeSkill());
    pluginManager.registerSkill(MemorySkill());

    // Init Neural Engine with builtin knowledge
    await neuralEngine.init(knowledgeBase: [
      {'id': 'identity', 'question': 'من انت', 'answer': 'نوار V3 Neural Engine'},
      {'id': 'capabilities', 'question': 'قدراتك', 'answer': 'Tokenizer + Embeddings + Transformer + Skills'},
    ]);

    memory = Memory();
    knowledge = Knowledge(neuralEngine: neuralEngine);
    decisionEngine = DecisionEngine(pluginManager: pluginManager, neuralEngine: neuralEngine);
    learning = Learning(neuralEngine: neuralEngine);
    personality = Personality();

    await database.db;
    await memory.init();
    await knowledge.init();
    await learning.init();

    brain = Brain(memory: memory, knowledge: knowledge, decisionEngine: decisionEngine, neuralEngine: neuralEngine);

    await _calcEvolution();
    _initialized = true;
  }

  Future<void> _calcEvolution() async {
    final convCount = await memory.count();
    final facts = await memory.getAllFacts();
    final neuralStats = neuralEngine.getStats();
    double level = 50.0 + (convCount * 0.5) + (facts.length * 3.0) + (neuralStats['documents'] as int) * 0.5;
    _evolution = level.clamp(0, 100);
    await database.updateEvolution(_evolution, convCount, convCount, facts.length, 0);
  }

  Future<Map<String, dynamic>> process(String input) async {
    if (!_initialized) await init();

    final analysis = await brain.analyze(input);
    final decision = analysis['decision'] as Decision;
    String response = analysis['response'] as String;

    if (decision.intent == Intent.clearMemory && !input.contains('فعلاً')) {
      response = 'عايز تمسح ${await memory.count()} محادثة؟ قول "امسح فعلاً"';
    } else if (decision.intent == Intent.clearMemory && input.contains('فعلاً')) {
      await clearAll();
      response = 'تم المسح - نوار V3 بدأ من الصفر';
    }

    await memory.saveConversation(input: input, output: response, intent: decision.intent.toString(), command: decision.command.toString(), confidence: analysis['confidence'], success: true);
    await learning.learnFromInput(input);
    await _calcEvolution();

    final thinking = personality.thinking(decision, analysis['elapsed'], await memory.count(), analysis['neural'] ?? {});

    return {'thinking': thinking, 'response': response, 'decision': decision, 'evolution': _evolution, 'neural': analysis['neural']};
  }

  Future<void> clearAll() async {
    await database.clearAll();
    neuralEngine.clear();
    _evolution = 50.0;
  }

  String evolutionDesc() {
    if (_evolution < 60) return 'V3 بداية - Neural Engine + Tokenizer + Skills 🌱';
    if (_evolution < 75) return 'V3 تطور - Embeddings + Semantic Search 🧠';
    if (_evolution < 85) return 'V3 ذكاء - Transformer Attention + Self Eval 🚀';
    if (_evolution < 95) return 'V3 متقدم - جاهز لـ GGUF/ONNX 💎';
    return 'V3 وعي كامل - مستعد للموديل المحلي 👑';
  }

  Future<Map<String, dynamic>> getStats() async {
    final evo = await database.getEvolution();
    final facts = await memory.getAllFacts();
    final recent = await memory.getRecent(5);
    return {'evolution': _evolution, 'description': evolutionDesc(), 'evolutionData': evo, 'facts': facts, 'recent': recent, 'total': await memory.count(), 'neural': neuralEngine.getStats(), 'skills': pluginManager.count};
  }
}
