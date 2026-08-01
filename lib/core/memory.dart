import '../database/database.dart';
import '../models/fact.dart';
import '../models/conversation.dart';

class Memory {
  final AppDatabase _db = AppDatabase();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    await _db.db;
    _ready = true;
  }

  Future<void> saveName(String name) async => await _db.saveFact('name', name, type: 'personal', source: 'user_told');
  Future<void> saveAge(String age) async => await _db.saveFact('age', age, type: 'personal', source: 'user_told');
  Future<void> saveFact(String key, String value) async => await _db.saveFact(key, value, type: 'learned', source: 'learned');
  Future<String?> getFact(String key) async => await _db.getFact(key);
  Future<List<Fact>> getAllFacts() async => await _db.getAllFacts();

  Future<void> saveConversation({
    required String input,
    required String output,
    required String intent,
    required String command,
    required double confidence,
    required bool success,
  }) async {
    final conv = Conversation(input: input, output: output, intent: intent, command: command, confidence: confidence, success: success, timestamp: DateTime.now());
    await _db.saveConversation(conv);
  }

  Future<List<Conversation>> getRecent(int limit) async => await _db.getRecent(limit);
  Future<int> count() async => await _db.countConversations();
  Future<List<Conversation>> search(String query) async => await _db.search(query);
  Future<void> clear() async => await _db.clearAll();
}
