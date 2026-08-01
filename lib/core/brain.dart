import 'memory.dart';
import 'knowledge.dart';
import 'decision.dart';
import '../neural/neural_engine.dart';

/// Brain V3 - يستخدم Neural Engine + Tokenizer بدل contains()
class Brain {
  final Memory memory;
  final Knowledge knowledge;
  final DecisionEngine decisionEngine;
  final NeuralEngine neuralEngine;

  Brain({required this.memory, required this.knowledge, required this.decisionEngine, required this.neuralEngine});

  Future<Map<String, dynamic>> analyze(String input) async {
    final start = DateTime.now();

    // 1. فهم عصبي حقيقي - Tokenizer + Embeddings
    final neuralUnderstanding = await neuralEngine.understand(input);
    final tokens = neuralUnderstanding['tokens'] as List<String>;

    // 2. تحليل النية - باستخدام Skills
    final decision = await decisionEngine.analyze(input, tokens);

    // 3. البحث في الذاكرة
    String? memoryAnswer;
    if (decision.intent == Intent.memoryQuery) {
      final key = decision.entities['fact_key'] as String?;
      if (key != null) memoryAnswer = await memory.getFact(key);
    }

    // 4. بحث دلالي - Semantic Search
    final kbAnswer = await knowledge.search(input);
    final semanticResult = await neuralEngine.answer(input);

    // 5. إنتاج الرد
    String response = decision.response;
    if (response.isEmpty) {
      if (memoryAnswer != null) response = memoryAnswer;
      else if (kbAnswer != null) response = kbAnswer;
      else if (semanticResult != null && (semanticResult['confidence'] as double) > 0.2) {
        response = 'وجدت معلومة مشابهة بثقة ${(semanticResult['confidence'] * 100).toStringAsFixed(0)}%';
      } else {
        response = 'فهمت! "$input" - توكنز: ${tokens.join(', ')} - هحفظها وأتعلم';
      }
    }

    final elapsed = DateTime.now().difference(start).inMilliseconds;

    return {
      'decision': decision,
      'response': response,
      'memoryAnswer': memoryAnswer,
      'kbAnswer': kbAnswer,
      'neural': neuralUnderstanding,
      'semantic': semanticResult,
      'elapsed': elapsed,
      'confidence': decision.confidence,
    };
  }
}
