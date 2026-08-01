import 'skill.dart';
import '../../database/database.dart';

class MemorySkill implements Skill {
  @override
  String get name => 'memory_skill';
  @override
  String get description => 'حفظ واسترجاع معلومات عامة';
  @override
  List<String> get keywords => ['احفظ', 'تذكر', 'اعرف'];
  @override
  double get confidence => 0.85;

  final AppDatabase _db = AppDatabase();

  @override
  Future<bool> canHandle(String input, List<String> tokens) async {
    final lower = input.toLowerCase();
    return lower.contains('احفظ ان') || lower.contains('تذكر ان') || lower.contains('اعرف ان') || lower.contains('احفظ معلومه');
  }

  @override
  Future<Map<String, dynamic>> execute(String input, Map<String, dynamic> context) async {
    final lower = input.toLowerCase();
    String fact = '';
    
    for (var prefix in ['احفظ ان', 'تذكر ان', 'اعرف ان', 'احفظ معلومه']) {
      if (lower.contains(prefix)) {
        fact = input.split(RegExp(prefix, caseSensitive: false)).last.trim();
        break;
      }
    }
    
    if (fact.isNotEmpty) {
      final key = 'custom_${DateTime.now().millisecondsSinceEpoch}';
      await _db.saveFact(key, fact, type: 'learned', source: 'user_told');
      return {
        'success': true,
        'response': 'حفظت معلومة جديدة: "$fact" 🧠 - هفضل فاكرها',
        'intent': 'learnFact',
        'entities': {'fact': fact},
        'confidence': 0.85,
      };
    }
    
    return {'success': false, 'response': '', 'confidence': 0.0};
  }
}
