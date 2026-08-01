import 'skill.dart';
import '../../database/database.dart';

class NameSkill implements Skill {
  @override
  String get name => 'name_skill';
  @override
  String get description => 'حفظ واسترجاع الاسم';
  @override
  List<String> get keywords => ['اسمي', 'اسمك', 'ما اسمي', 'كام اسمي'];
  @override
  double get confidence => 0.95;

  final AppDatabase _db = AppDatabase();

  @override
  Future<bool> canHandle(String input, List<String> tokens) async {
    final lower = input.toLowerCase();
    return lower.contains('اسمي') || lower.contains('ما اسمي') || lower.contains('كام اسمي') || lower.contains('ايه اسمي');
  }

  @override
  Future<Map<String, dynamic>> execute(String input, Map<String, dynamic> context) async {
    final lower = input.toLowerCase();
    
    // تعلم الاسم
    if (lower.contains('اسمي') && !lower.contains('ما') && !lower.contains('كام') && !lower.contains('ايه')) {
      final name = _extractName(input);
      if (name.isNotEmpty) {
        await _db.saveFact('name', name, type: 'personal', source: 'user_told');
        return {
          'success': true,
          'response': 'أهلاً يا $name! حفظت اسمك في ذاكرتي الدائمة SQLite 🎉',
          'intent': 'learnName',
          'entities': {'name': name},
          'confidence': 0.95,
        };
      }
    }
    
    // استرجاع الاسم
    if (lower.contains('ما اسمي') || lower.contains('كام اسمي') || lower.contains('ايه اسمي')) {
      final name = await _db.getFact('name');
      if (name != null) {
        return {
          'success': true,
          'response': 'اسمك $name - فاكره من أول مرة قلتهولي 😎',
          'intent': 'memoryQuery',
          'confidence': 0.95,
        };
      } else {
        return {
          'success': false,
          'response': 'لسه معرفش اسمك، قولي "اسمي ..." وهحفظه فوراً',
          'intent': 'memoryQuery',
          'confidence': 0.5,
        };
      }
    }
    
    return {'success': false, 'response': '', 'confidence': 0.0};
  }

  String _extractName(String text) {
    if (text.contains('اسمي')) {
      return text.split('اسمي').last.trim().split(RegExp(r'[؟!.,]')).first.trim();
    }
    return '';
  }
}
