import '../database/database.dart';
import '../models/fact.dart';
import '../models/conversation.dart';

/// الذاكرة - مسؤولة عن تخزين المعلومات واسترجاعها بدون إنترنت
/// في البداية ستدعم: حفظ الاسم، العمر، أي معلومة يتعلمها، واسترجاعها لاحقاً
class Memory {
  final AppDatabase _db = AppDatabase();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    await _db.db;
    _ready = true;
  }

  // حفظ الاسم
  Future<void> saveName(String name) async {
    await _db.saveFact('name', name, type: 'personal', source: 'user_told');
  }

  // حفظ العمر
  Future<void> saveAge(String age) async {
    await _db.saveFact('age', age, type: 'personal', source: 'user_told');
  }

  // حفظ أي معلومة يتعلمها
  Future<void> saveFact(String key, String value) async {
    await _db.saveFact(key, value, type: 'learned', source: 'learned');
  }

  // استرجاع الاسم
  Future<String?> getName() async => await _db.getFact('name');
  
  // استرجاع العمر
  Future<String?> getAge() async => await _db.getFact('age');

  // استرجاع أي معلومة
  Future<String?> getFact(String key) async => await _db.getFact(key);

  Future<List<Fact>> getAllFacts() async => await _db.getAllFacts();

  // حفظ محادثة
  Future<void> saveConversation({
    required String input,
    required String output,
    required String intent,
    required String command,
    required double confidence,
    required bool success,
  }) async {
    final conv = Conversation(
      input: input,
      output: output,
      intent: intent,
      command: command,
      confidence: confidence,
      success: success,
      timestamp: DateTime.now(),
    );
    await _db.saveConversation(conv);
  }

  Future<List<Conversation>> getRecent(int limit) async => await _db.getRecent(limit);
  Future<int> count() async => await _db.countConversations();
  Future<List<Conversation>> search(String query) async => await _db.search(query);

  Future<void> clear() async => await _db.clearAll();
}
