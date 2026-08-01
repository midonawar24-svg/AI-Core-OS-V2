import 'skill.dart';
import '../../database/database.dart';

class AgeSkill implements Skill {
  @override
  String get name => 'age_skill';
  @override
  String get description => 'حفظ واسترجاع العمر';
  @override
  List<String> get keywords => ['عمري', 'عندي', 'سنه', 'كام عمري'];
  @override
  double get confidence => 0.9;

  final AppDatabase _db = AppDatabase();

  @override
  Future<bool> canHandle(String input, List<String> tokens) async {
    final lower = input.toLowerCase();
    return (lower.contains('عمري') || lower.contains('عندي')) && lower.contains('سنه') || lower.contains('كام عمري');
  }

  @override
  Future<Map<String, dynamic>> execute(String input, Map<String, dynamic> context) async {
    final lower = input.toLowerCase();
    
    if ((lower.contains('عندي') && lower.contains('سنه')) || lower.contains('عمري') && RegExp(r'\d+').hasMatch(lower)) {
      final age = RegExp(r'(\d+)').firstMatch(lower)?.group(1) ?? '';
      if (age.isNotEmpty) {
        await _db.saveFact('age', age, type: 'personal', source: 'user_told');
        return {
          'success': true,
          'response': 'تمام، عندك $age سنة - حفظتها في ذاكرتي',
          'intent': 'learnAge',
          'entities': {'age': age},
          'confidence': 0.9,
        };
      }
    }
    
    if (lower.contains('كام عمري') || lower.contains('ما عمري')) {
      final age = await _db.getFact('age');
      if (age != null) {
        return {
          'success': true,
          'response': 'عندك $age سنة',
          'intent': 'memoryQuery',
          'confidence': 0.9,
        };
      }
      return {
        'success': false,
        'response': 'لسه معرفش عمرك، قولي "عندي 25 سنة" وهحفظه',
        'intent': 'memoryQuery',
        'confidence': 0.5,
      };
    }
    
    return {'success': false, 'response': '', 'confidence': 0.0};
  }
}
