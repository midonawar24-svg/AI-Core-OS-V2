/// محرك اتخاذ القرار
/// هو الذي يقرر: هل يبحث في الذاكرة؟ هل يجيب مباشرة؟ هل يتعلم معلومة جديدة؟ هل يطلب توضيحاً؟

enum Intent {
  chat,
  greeting,
  identity,
  learnName,      // اسمي محمد
  learnAge,       // عندي 25 سنة
  learnFact,      // احفظ اني بحب البرمجة
  memoryQuery,    // كام اسمي؟
  question,
  command,
  clearMemory,
  unknown,
}

enum CommandType {
  none,
  openCamera,
  time,
  date,
}

class Decision {
  final Intent intent;
  final CommandType command;
  final double confidence;
  final String reasoning;
  final Map<String, dynamic> entities;
  final String rawInput;

  Decision({
    required this.intent,
    this.command = CommandType.none,
    required this.confidence,
    required this.reasoning,
    this.entities = const {},
    required this.rawInput,
  });
}

class DecisionEngine {
  Decision analyze(String input) {
    final text = input.toLowerCase().trim();
    final raw = input;

    // تحية
    if (_has(text, ['سلام', 'هاي', 'هلا', 'مرحبا', 'أهلا'])) {
      return Decision(intent: Intent.greeting, confidence: 0.95, reasoning: 'تحية - يجب الرد بتحية', rawInput: raw);
    }

    // هوية
    if (_has(text, ['من انت', 'انت مين', 'اسمك ايه'])) {
      return Decision(intent: Intent.identity, confidence: 0.95, reasoning: 'سؤال عن هوية النظام - إجابة مباشرة', rawInput: raw);
    }

    // تعلم الاسم: "اسمي محمد" - معلومة يجب حفظها
    if (text.contains('اسمي') && !text.contains('ما') && !text.contains('ايه') && !text.contains('كام')) {
      final name = _extractName(text);
      if (name.isNotEmpty) {
        return Decision(
          intent: Intent.learnName,
          confidence: 0.95,
          reasoning: 'المستخدم يعلم النظام اسمه: $name -> يجب حفظه في الذاكرة الدائمة',
          entities: {'name': name, 'fact_key': 'name', 'fact_value': name, 'fact_type': 'name'},
          rawInput: raw,
        );
      }
    }

    // تعلم العمر: "عندي 25 سنة"
    if ((text.contains('عندي') && text.contains('سنة')) || text.contains('عمري')) {
      final age = _extractAge(text);
      if (age.isNotEmpty) {
        return Decision(
          intent: Intent.learnAge,
          confidence: 0.9,
          reasoning: 'تعلم العمر: $age - حفظ في الذاكرة',
          entities: {'age': age, 'fact_key': 'age', 'fact_value': age, 'fact_type': 'age'},
          rawInput: raw,
        );
      }
    }

    // سؤال عن الاسم: "كام اسمي؟" - يفهم أنك تسأل عن الاسم
    if (_has(text, ['ما اسمي', 'كام اسمي', 'ايه اسمي', 'تعرف اسمي'])) {
      return Decision(
        intent: Intent.memoryQuery,
        confidence: 0.95,
        reasoning: 'سؤال عن الاسم - يجب البحث في الذاكرة SQLite',
        entities: {'fact_key': 'name', 'fact_type': 'name'},
        rawInput: raw,
      );
    }

    // سؤال عن العمر: "كام عمري؟"
    if (_has(text, ['كام عمري', 'ما عمري', 'كم عمري'])) {
      return Decision(
        intent: Intent.memoryQuery,
        confidence: 0.9,
        reasoning: 'سؤال عن العمر - بحث في الذاكرة',
        entities: {'fact_key': 'age', 'fact_type': 'age'},
        rawInput: raw,
      );
    }

    // تعلم حقيقة: "احفظ اني..."
    if (_has(text, ['احفظ ان', 'تذكر ان', 'اعرف ان'])) {
      final fact = _extractFact(text);
      return Decision(
        intent: Intent.learnFact,
        confidence: 0.9,
        reasoning: 'المستخدم يريد تعليم النظام حقيقة جديدة: $fact - يجب حفظها',
        entities: {'fact_key': 'custom_${DateTime.now().millisecondsSinceEpoch}', 'fact_value': fact, 'fact_type': 'custom'},
        rawInput: raw,
      );
    }

    // أوامر
    if (_has(text, ['افتح الكاميرا', 'شغل الكاميرا'])) {
      return Decision(intent: Intent.command, command: CommandType.openCamera, confidence: 0.95, reasoning: 'أمر تنفيذي: فتح الكاميرا', rawInput: raw);
    }
    if (_has(text, ['الساعة كام', 'كم الساعة'])) {
      return Decision(intent: Intent.command, command: CommandType.time, confidence: 0.9, reasoning: 'سؤال عن الوقت - إجابة مباشرة من النظام', rawInput: raw);
    }

    // مسح الذاكرة
    if (_has(text, ['امسح الذاكرة', 'احذف الذاكرة'])) {
      return Decision(intent: Intent.clearMemory, confidence: 0.95, reasoning: 'طلب مسح الذاكرة - يحتاج تأكيد', rawInput: raw);
    }

    // سؤال عام
    if (text.contains('؟') || text.startsWith('ما ') || text.startsWith('كيف') || text.startsWith('ليه')) {
      return Decision(intent: Intent.question, confidence: 0.7, reasoning: 'سؤال عام - بحث في قاعدة المعرفة', rawInput: raw);
    }

    return Decision(intent: Intent.chat, confidence: 0.6, reasoning: 'محادثة عامة - رد طبيعي مع حفظ في الذاكرة', rawInput: raw);
  }

  bool _has(String text, List<String> keys) {
    for (var k in keys) if (text.contains(k)) return true;
    return false;
  }

  String _extractName(String text) {
    final parts = text.split('اسمي');
    if (parts.length > 1) return parts.last.trim().split(RegExp(r'[؟!.,]')).first.trim();
    return '';
  }

  String _extractAge(String text) {
    final m = RegExp(r'(\d+)').firstMatch(text);
    return m?.group(1) ?? '';
  }

  String _extractFact(String text) {
    for (var p in ['احفظ ان', 'تذكر ان', 'اعرف ان']) {
      if (text.contains(p)) return text.split(p).last.trim();
    }
    return text;
  }
}
