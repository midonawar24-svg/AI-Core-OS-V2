/// جداول قاعدة البيانات - SQLite
/// المرحلة 2: ذاكرة حقيقية بدل SharedPreferences

class Tables {
  static const String conversations = 'conversations';
  static const String facts = 'facts';
  static const String words = 'words';
  static const String decisions = 'decision_logs';
  static const String evolution = 'evolution';
  static const String knowledge = 'knowledge_base';

  static String createConversations = '''
    CREATE TABLE \${Tables.conversations}(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      input TEXT NOT NULL,
      output TEXT NOT NULL,
      intent TEXT NOT NULL,
      command TEXT NOT NULL,
      confidence REAL NOT NULL,
      success INTEGER NOT NULL,
      timestamp INTEGER NOT NULL
    )
  ''';

  static String createFacts = '''
    CREATE TABLE \${Tables.facts}(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      key TEXT NOT NULL UNIQUE,
      value TEXT NOT NULL,
      type TEXT NOT NULL,
      source TEXT NOT NULL,
      timestamp INTEGER NOT NULL
    )
  ''';

  static String createWords = '''
    CREATE TABLE \${Tables.words}(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      word TEXT NOT NULL UNIQUE,
      frequency INTEGER NOT NULL,
      firstSeen INTEGER NOT NULL,
      lastSeen INTEGER NOT NULL
    )
  ''';

  static String createDecisions = '''
    CREATE TABLE \${Tables.decisions}(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      input TEXT NOT NULL,
      intent TEXT NOT NULL,
      decision TEXT NOT NULL,
      reasoning TEXT NOT NULL,
      confidence REAL NOT NULL,
      timestamp INTEGER NOT NULL
    )
  ''';

  static String createEvolution = '''
    CREATE TABLE \${Tables.evolution}(
      id INTEGER PRIMARY KEY,
      level REAL NOT NULL,
      totalConversations INTEGER NOT NULL,
      totalSuccess INTEGER NOT NULL,
      totalFacts INTEGER NOT NULL,
      totalWords INTEGER NOT NULL,
      lastUpdate INTEGER NOT NULL
    )
  ''';

  static String createKnowledge = '''
    CREATE TABLE \${Tables.knowledge}(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      question TEXT NOT NULL UNIQUE,
      answer TEXT NOT NULL,
      category TEXT NOT NULL,
      timestamp INTEGER NOT NULL
    )
  ''';
}
