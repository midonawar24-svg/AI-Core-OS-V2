import '../neural/neural_engine.dart';
import 'skills/skill.dart';
import '../plugins/plugin_manager.dart';

enum Intent {
  chat, greeting, identity, learnName, learnAge, learnFact, memoryQuery, question, command, clearMemory, unknown,
}

enum CommandType { none, openCamera, time, date }

class Decision {
  final Intent intent;
  final CommandType command;
  final double confidence;
  final String reasoning;
  final Map<String, dynamic> entities;
  final String rawInput;
  final String response;
  final Skill? skill;

  Decision({
    required this.intent,
    this.command = CommandType.none,
    required this.confidence,
    required this.reasoning,
    this.entities = const {},
    required this.rawInput,
    this.response = '',
    this.skill,
  });
}

/// Decision Engine V3 - Plugin-based، سهل إضافة مهارات
class DecisionEngine {
  final PluginManager pluginManager;
  final NeuralEngine neuralEngine;

  DecisionEngine({required this.pluginManager, required this.neuralEngine});

  Future<Decision> analyze(String input, List<String> tokens) async {
    // 1. جرب Skills أولاً
    final skillResult = await pluginManager.executeSkill(input, {}, tokens);
    if (skillResult != null && skillResult['success'] == true) {
      return Decision(
        intent: _parseIntent(skillResult['intent']),
        confidence: (skillResult['confidence'] as double?) ?? 0.9,
        reasoning: 'تم التعامل عبر Skill: ${skillResult['intent']} - ${tokens.join(', ')}',
        entities: skillResult['entities'] ?? {},
        rawInput: input,
        response: skillResult['response'] ?? '',
      );
    }

    // 2. تحليل عصبي للنية
    final lower = input.toLowerCase();
    
    if (_has(lower, ['سلام', 'هاي', 'مرحبا'])) {
      return Decision(intent: Intent.greeting, confidence: 0.95, reasoning: 'تحية - Tokenizer: ${tokens.join(', ')}', rawInput: input, response: 'أهلاً! نوار V3 بالمحرك العصبي جاهز 🚀');
    }

    if (_has(lower, ['من انت', 'انت مين'])) {
      return Decision(intent: Intent.identity, confidence: 0.95, reasoning: 'هوية - فهم دلالي', rawInput: input, response: 'أنا نوار AI Core OS V3 - Neural Engine: Tokenizer + Embeddings + Transformer + Inference - أوفلاين 100%');
    }

    if (lower.contains('امسح الذاكره') || lower.contains('احذف الذاكره')) {
      return Decision(intent: Intent.clearMemory, confidence: 0.95, reasoning: 'مسح ذاكرة', rawInput: input, response: 'عايز تمسح الذاكرة؟ قول "امسح فعلاً"');
    }

    if (input.contains('؟') || lower.startsWith('ما ') || lower.startsWith('كيف')) {
      return Decision(intent: Intent.question, confidence: 0.7, reasoning: 'سؤال عام - Semantic Search', rawInput: input, response: '');
    }

    return Decision(intent: Intent.chat, confidence: 0.6, reasoning: 'محادثة عامة - Tokens: ${tokens.length}', rawInput: input, response: '');
  }

  Intent _parseIntent(String? intentStr) {
    switch (intentStr) {
      case 'learnName': return Intent.learnName;
      case 'learnAge': return Intent.learnAge;
      case 'learnFact': return Intent.learnFact;
      case 'memoryQuery': return Intent.memoryQuery;
      case 'command': return Intent.command;
      default: return Intent.chat;
    }
  }

  bool _has(String text, List<String> keys) {
    for (var k in keys) if (text.contains(k)) return true;
    return false;
  }
}
