import 'skill.dart';

class TimeSkill implements Skill {
  @override
  String get name => 'time_skill';
  @override
  String get description => 'الوقت والتاريخ';
  @override
  List<String> get keywords => ['الساعه', 'الوقت', 'التاريخ', 'النهارده'];
  @override
  double get confidence => 0.95;

  @override
  Future<bool> canHandle(String input, List<String> tokens) async {
    final lower = input.toLowerCase();
    return lower.contains('الساعه') || lower.contains('كم الساعه') || lower.contains('الوقت') || lower.contains('التاريخ') || lower.contains('النهارده ايه');
  }

  @override
  Future<Map<String, dynamic>> execute(String input, Map<String, dynamic> context) async {
    final lower = input.toLowerCase();
    final now = DateTime.now();
    
    if (lower.contains('الساعه') || lower.contains('الوقت')) {
      return {
        'success': true,
        'response': 'الساعة دلوقتي ${now.hour}:${now.minute.toString().padLeft(2, '0')} ⏰ - أوفلاين 100%',
        'intent': 'command',
        'command': 'time',
        'confidence': 0.95,
      };
    }
    
    if (lower.contains('التاريخ') || lower.contains('النهارده')) {
      return {
        'success': true,
        'response': 'النهاردة ${now.day}/${now.month}/${now.year} 📅',
        'intent': 'command',
        'command': 'date',
        'confidence': 0.95,
      };
    }
    
    return {'success': false, 'response': '', 'confidence': 0.0};
  }
}
