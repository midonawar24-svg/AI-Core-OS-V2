import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'tables.dart';
import '../models/fact.dart';
import '../models/conversation.dart';

/// قاعدة البيانات الرئيسية - SQLite
/// تخزين: المحادثات، المعلومات، الكلمات، القرارات، التطور، المعرفة
class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'ai_core_os_v2_pro.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(Tables.createConversations);
        await db.execute(Tables.createFacts);
        await db.execute(Tables.createWords);
        await db.execute(Tables.createDecisions);
        await db.execute(Tables.createEvolution);
        await db.execute(Tables.createKnowledge);

        // مستوى ابتدائي
        await db.insert(Tables.evolution, {
          'id': 1,
          'level': 50.0,
          'totalConversations': 0,
          'totalSuccess': 0,
          'totalFacts': 0,
          'totalWords': 0,
          'lastUpdate': DateTime.now().millisecondsSinceEpoch,
        });

        // معرفة افتراضية
        await db.insert(Tables.facts, {
          'key': 'system_name',
          'value': 'Nawar AI Core OS V2',
          'type': 'system',
          'source': 'system',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        await db.insert(Tables.knowledge, {
          'question': 'من انت',
          'answer': 'أنا نوار AI Core OS V2 - عقل مستقل 100% أوفلاين بدون Gemini',
          'category': 'identity',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      },
    );
  }

  // Facts - الاسم، العمر، أي معلومة
  Future<void> saveFact(String key, String value, {String type = 'personal', String source = 'user'}) async {
    final database = await db;
    await database.insert(Tables.facts, {
      'key': key.toLowerCase(),
      'value': value,
      'type': type,
      'source': source,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getFact(String key) async {
    final database = await db;
    final maps = await database.query(Tables.facts, where: 'key = ?', whereArgs: [key.toLowerCase()]);
    if (maps.isNotEmpty) return maps.first['value'] as String;
    return null;
  }

  Future<List<Fact>> getAllFacts() async {
    final database = await db;
    final maps = await database.query(Tables.facts, orderBy: 'timestamp DESC');
    return maps.map((m) => Fact.fromMap(m)).toList();
  }

  // Conversations
  Future<int> saveConversation(Conversation conv) async {
    final database = await db;
    return await database.insert(Tables.conversations, conv.toMap());
  }

  Future<List<Conversation>> getRecent(int limit) async {
    final database = await db;
    final maps = await database.query(Tables.conversations, orderBy: 'timestamp DESC', limit: limit);
    return maps.map((m) => Conversation.fromMap(m)).toList();
  }

  Future<int> countConversations() async {
    final database = await db;
    final result = await database.rawQuery('SELECT COUNT(*) as c FROM \${Tables.conversations}');
    return result.first['c'] as int;
  }

  Future<List<Conversation>> search(String query) async {
    final database = await db;
    final maps = await database.query(Tables.conversations, where: 'input LIKE ? OR output LIKE ?', whereArgs: ['%$query%', '%$query%']);
    return maps.map((m) => Conversation.fromMap(m)).toList();
  }

  // Knowledge
  Future<String?> searchKnowledge(String query) async {
    final database = await db;
    final maps = await database.query(Tables.knowledge, where: 'question LIKE ?', whereArgs: ['%$query%'], limit: 1);
    if (maps.isNotEmpty) return maps.first['answer'] as String;
    return null;
  }

  Future<void> saveKnowledge(String question, String answer, {String category = 'general'}) async {
    final database = await db;
    await database.insert(Tables.knowledge, {
      'question': question.toLowerCase(),
      'answer': answer,
      'category': category,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Evolution
  Future<void> updateEvolution(double level, int convs, int success, int facts, int words) async {
    final database = await db;
    await database.update(Tables.evolution, {
      'level': level,
      'totalConversations': convs,
      'totalSuccess': success,
      'totalFacts': facts,
      'totalWords': words,
      'lastUpdate': DateTime.now().millisecondsSinceEpoch,
    }, where: 'id = ?', whereArgs: [1]);
  }

  Future<Map<String, dynamic>?> getEvolution() async {
    final database = await db;
    final maps = await database.query(Tables.evolution, where: 'id = ?', whereArgs: [1]);
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<void> clearAll() async {
    final database = await db;
    await database.delete(Tables.conversations);
    await database.delete(Tables.facts);
    await database.delete(Tables.words);
    await database.delete(Tables.decisions);
    await database.delete(Tables.knowledge);
    await database.update(Tables.evolution, {
      'level': 50.0,
      'totalConversations': 0,
      'totalSuccess': 0,
      'totalFacts': 0,
      'totalWords': 0,
      'lastUpdate': DateTime.now().millisecondsSinceEpoch,
    }, where: 'id = ?', whereArgs: [1]);
  }
}
