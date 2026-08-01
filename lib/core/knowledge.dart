import '../database/database.dart';

/// قاعدة المعرفة - Knowledge Base
class Knowledge {
  final AppDatabase _db = AppDatabase();
  final Map<String, String> _builtin = {
    'من انت': 'أنا نوار AI Core OS V2 - عقل مستقل 100% أوفلاين بدون Gemini أو OpenAI، عندي ذاكرة SQLite وبتعلم منك',
    'ما هي قدراتك': 'أتذكر اسمك وعمرك وأي معلومة، بفهم أوامر زي الساعة كام، بتطور مع كل محادثة، كله أوفلاين',
    'كيف تعمل': 'عندي 5 مكونات: ذاكرة، عقل، قرارات، تعلم، معرفة - كله شغال على تليفونك',
    'هل تحتاج انترنت': 'لا، شغال 100% أوفلاين - SQLite على جهازك',
  };

  Future<void> init() async {
    await _db.db;
  }

  Future<String?> search(String query) async {
    final q = query.toLowerCase().trim();
    
    // 1. بحث في المعرفة المدمجة
    for (var e in _builtin.entries) {
      if (q.contains(e.key.toLowerCase()) || e.key.toLowerCase().contains(q)) {
        return e.value;
      }
    }

    // 2. بحث في قاعدة المعرفة المحفوظة
    final result = await _db.searchKnowledge(q);
    if (result != null) return result;

    // 3. بحث في الحقائق
    final fact = await _db.getFact(q);
    return fact;
  }

  Future<void> addKnowledge(String question, String answer) async {
    await _db.saveKnowledge(question, answer);
  }
}
