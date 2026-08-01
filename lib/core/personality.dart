import 'dart:math';
import 'decision.dart';

class Personality {
  static const String name = 'نوار';
  static const String version = 'AI Core OS V2';
  final Random _random = Random();

  String greeting() {
    final list = [
      'أهلاً! أنا نوار، عقلك المستقل - SQLite + أوفلاين 100% 😎',
      'يا هلا! نوار OS v2 - بذاكرة حقيقية بتتذكر اسمك وعمرك',
      'السلامو عليكو! نوار V2 - بدون Gemini، ذكاء خاص بيك 🚀',
    ];
    return list[_random.nextInt(list.length)];
  }

  String thinking(Decision decision, int elapsed, int memorySize) {
    return '''
🧠 AI Core OS V2 - تحليل أوفلاين:
- المدخل: ${decision.rawInput}
- النية: ${decision.intent}
- الأمر: ${decision.command}
- الثقة: ${(decision.confidence * 100).toStringAsFixed(0)}%
- المنطق: ${decision.reasoning}
- الذاكرة: $memorySize محادثة في SQLite
- الكيانات: ${decision.entities}
- الزمن: ${elapsed}ms
- الحالة: أوفلاين 100%
''';
  }
}
