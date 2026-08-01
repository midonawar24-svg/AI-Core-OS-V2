import 'dart:math';
import 'decision.dart';

class Personality {
  static const String name = 'نوار';
  static const String version = 'AI Core OS V3 - Neural Engine';
  final Random _random = Random();

  String greeting() {
    final list = [
      'أهلاً! أنا نوار V3 - Neural Engine: Tokenizer + Embeddings + Transformer 🚀',
      'يا هلا! نوار V3 - Plugin System + Self Learning + أوفلاين 100% 😎',
      'السلامو عليكو! نوار V3 - عقل حقيقي مش Rule Engine - جاهز للـ GGUF/ONNX',
    ];
    return list[_random.nextInt(list.length)];
  }

  String thinking(Decision decision, int elapsed, int memorySize, Map<String, dynamic> neural) {
    final tokens = neural['tokens'] as List<String>? ?? [];
    return '''
🧠 AI Core OS V3 - Neural Engine:
- المدخل: ${decision.rawInput}
- Tokens: ${tokens.join(', ')} (${tokens.length})
- النية: ${decision.intent}
- Skill: ${decision.skill?.name ?? 'لا يوجد - عام'}
- الثقة: ${(decision.confidence * 100).toStringAsFixed(0)}%
- المنطق: ${decision.reasoning}
- الذاكرة: $memorySize محادثة
- Semantic: ${neural['semanticResults']?.length ?? 0} نتيجة
- الزمن: ${elapsed}ms
- المحرك: Tokenizer + TF-IDF + Attention + Plugins
- الحالة: أوفلاين - جاهز لـ GGUF
''';
  }
}
