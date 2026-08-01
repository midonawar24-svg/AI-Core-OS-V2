import 'memory.dart';
import 'knowledge.dart';
import 'decision.dart';

/// محلل اللغة - Brain
/// مثال:
/// إذا قلت: "اسمي محمد" -> يفهم أنها معلومة يجب حفظها
/// إذا قلت: "كام اسمي؟" -> يفهم أنك تسأل عن الاسم
class Brain {
  final Memory memory;
  final Knowledge knowledge;
  final DecisionEngine decisionEngine;

  Brain({required this.memory, required this.knowledge, required this.decisionEngine});

  /// تحليل السؤال -> البحث في الذاكرة -> إنتاج رد مبدئي
  Future<Map<String, dynamic>> analyze(String input) async {
    final start = DateTime.now();

    // 1. تحليل السؤال
    final decision = decisionEngine.analyze(input);

    // 2. البحث في الذاكرة - هل أعرف هذه المعلومة؟
    String? memoryAnswer;
    if (decision.intent == Intent.memoryQuery) {
      final key = decision.entities['fact_key'] as String?;
      if (key != null) {
        memoryAnswer = await memory.getFact(key);
      }
    }

    // 3. البحث في قاعدة المعرفة
    final kbAnswer = await knowledge.search(input);

    // 4. إنتاج الرد حسب النية
    String response = '';
    switch (decision.intent) {
      case Intent.learnName:
        final name = decision.entities['name'] as String;
        await memory.saveName(name);
        response = 'أهلاً يا $name! حفظت اسمك في ذاكرتي الدائمة SQLite 🎉';
        break;

      case Intent.learnAge:
        final age = decision.entities['age'] as String;
        await memory.saveAge(age);
        response = 'تمام، عندك $age سنة - حفظتها';
        break;

      case Intent.learnFact:
        final key = decision.entities['fact_key'] as String;
        final value = decision.entities['fact_value'] as String;
        await memory.saveFact(key, value);
        response = 'حفظت معلومة جديدة: $key = $value 🧠';
        break;

      case Intent.memoryQuery:
        if (memoryAnswer != null) {
          if (decision.entities['fact_type'] == 'name') {
            response = 'اسمك $memoryAnswer - فاكره من أول مرة قلتهولي 😎';
          } else if (decision.entities['fact_type'] == 'age') {
            response = 'عندك $memoryAnswer سنة';
          } else {
            response = '$memoryAnswer';
          }
        } else {
          response = 'لسه معرفش ${decision.entities['fact_type'] ?? 'المعلومة دي'}، قولي وعلمني وهحفظها';
        }
        break;

      case Intent.question:
        response = kbAnswer ?? 'سؤال ذكي! لسه بتعلم إجابته - علمني وقول "احفظ ان..."';
        break;

      case Intent.greeting:
        response = 'أهلاً! نوار AI Core OS V2 جاهز - 100% أوفلاين 🚀';
        break;

      case Intent.identity:
        response = 'أنا نوار AI Core OS V2 - عقل مستقل أوفلاين بدون Gemini، عندي ذاكرة SQLite وبتعلم منك';
        break;

      default:
        response = kbAnswer ?? 'فهمت! "$input" - معلومة مهمة هحفظها';
    }

    final elapsed = DateTime.now().difference(start).inMilliseconds;

    return {
      'decision': decision,
      'response': response,
      'memoryAnswer': memoryAnswer,
      'kbAnswer': kbAnswer,
      'elapsed': elapsed,
      'confidence': decision.confidence,
    };
  }
}
