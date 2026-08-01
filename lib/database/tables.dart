/// AI Core OS V3 - Database Layer
/// Version 3.0 - Production Ready - 10/10 FINAL CLOSED
/// Android Optimized - Production Ready

class Tables {
  Tables._();

  static const String databaseName = 'ai_core_os_v3_production.db';
  static const int schemaVersion = 3;

  static const String conversations = 'conversations';
  static const String facts = 'facts';
  static const String words = 'words';
  static const String decisions = 'decision_logs';
  static const String evolution = 'evolution';
  static const String knowledge = 'knowledge_base';

  static const String createConversations = '''
    CREATE TABLE $conversations(
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

  static const String createFacts = '''
    CREATE TABLE $facts(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      key TEXT NOT NULL UNIQUE,
      value TEXT NOT NULL,
      type TEXT NOT NULL,
      source TEXT NOT NULL,
      timestamp INTEGER NOT NULL
    )
  ''';

  static const String createWords = '''
    CREATE TABLE $words(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      word TEXT NOT NULL UNIQUE,
      frequency INTEGER NOT NULL,
      firstSeen INTEGER NOT NULL,
      lastSeen INTEGER NOT NULL
    )
  ''';

  static const String createDecisions = '''
    CREATE TABLE $decisions(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      input TEXT NOT NULL,
      intent TEXT NOT NULL,
      decision TEXT NOT NULL,
      reasoning TEXT NOT NULL,
      confidence REAL NOT NULL,
      timestamp INTEGER NOT NULL
    )
  ''';

  static const String createEvolution = '''
    CREATE TABLE $evolution(
      id INTEGER PRIMARY KEY,
      level REAL NOT NULL,
      totalConversations INTEGER NOT NULL,
      totalSuccess INTEGER NOT NULL,
      totalFacts INTEGER NOT NULL,
      totalWords INTEGER NOT NULL,
      lastUpdate INTEGER NOT NULL
    )
  ''';

  static const String createKnowledge = '''
    CREATE TABLE $knowledge(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      question TEXT NOT NULL UNIQUE,
      answer TEXT NOT NULL,
      category TEXT NOT NULL,
      timestamp INTEGER NOT NULL
    )
  ''';

  static const List<String> allTables = [
    createConversations,
    createFacts,
    createWords,
    createDecisions,
    createEvolution,
    createKnowledge,
  ];

  // ========== Facts Indexes - 4 ==========
  static const String idxFactKey = 'CREATE INDEX IF NOT EXISTS idx_fact_key ON $facts(key)';
  static const String idxFactType = 'CREATE INDEX IF NOT EXISTS idx_fact_type ON $facts(type)';
  static const String idxFactTimestamp = 'CREATE INDEX IF NOT EXISTS idx_fact_timestamp ON $facts(timestamp DESC)';
  static const String idxFactTypeTime = 'CREATE INDEX IF NOT EXISTS idx_fact_type_time ON $facts(type, timestamp DESC)';

  // ========== Conversations Indexes - 6 ==========
  static const String idxConvInput = 'CREATE INDEX IF NOT EXISTS idx_conv_input ON $conversations(input)';
  static const String idxConvTimestamp = 'CREATE INDEX IF NOT EXISTS idx_conv_timestamp ON $conversations(timestamp DESC)';
  static const String idxConvIntent = 'CREATE INDEX IF NOT EXISTS idx_conv_intent ON $conversations(intent)';
  static const String idxConvSuccess = 'CREATE INDEX IF NOT EXISTS idx_conv_success ON $conversations(success, timestamp DESC)';
  static const String idxConvIntentTime = 'CREATE INDEX IF NOT EXISTS idx_conv_intent_time ON $conversations(intent, timestamp DESC)';
  static const String idxConvCommand = 'CREATE INDEX IF NOT EXISTS idx_conv_command ON $conversations(command)';

  // ========== Words Indexes - 3 ==========
  static const String idxWordsWord = 'CREATE INDEX IF NOT EXISTS idx_words_word ON $words(word)';
  static const String idxWordsFreq = 'CREATE INDEX IF NOT EXISTS idx_words_freq ON $words(frequency DESC)';
  static const String idxWordsLastSeen = 'CREATE INDEX IF NOT EXISTS idx_words_last_seen ON $words(lastSeen DESC)';

  // ========== Knowledge Indexes - 3 ==========
  static const String idxKnowledgeQuestion = 'CREATE INDEX IF NOT EXISTS idx_knowledge_q ON $knowledge(question)';
  static const String idxKnowledgeCategory = 'CREATE INDEX IF NOT EXISTS idx_knowledge_cat ON $knowledge(category)';
  static const String idxKnowledgeCategoryTime = 'CREATE INDEX IF NOT EXISTS idx_knowledge_category_time ON $knowledge(category, timestamp DESC)';

  // ========== Decisions Indexes - 3 ==========
  static const String idxDecisionsIntent = 'CREATE INDEX IF NOT EXISTS idx_decisions_intent ON $decisions(intent)';
  static const String idxDecisionTimestamp = 'CREATE INDEX IF NOT EXISTS idx_decision_timestamp ON $decisions(timestamp DESC)';
  static const String idxDecisionInput = 'CREATE INDEX IF NOT EXISTS idx_decision_input ON $decisions(input)';

  // Production Indexes
  // Total: 19
  // Facts: 4
  // Conversations: 6
  // Words: 3
  // Knowledge: 3
  // Decisions: 3
  static const List<String> allIndexes = [
    // Facts
    idxFactKey,
    idxFactType,
    idxFactTimestamp,
    idxFactTypeTime,

    // Conversations
    idxConvInput,
    idxConvTimestamp,
    idxConvIntent,
    idxConvSuccess,
    idxConvIntentTime,
    idxConvCommand,

    // Words
    idxWordsWord,
    idxWordsFreq,
    idxWordsLastSeen,

    // Knowledge
    idxKnowledgeQuestion,
    idxKnowledgeCategory,
    idxKnowledgeCategoryTime,

    // Decisions
    idxDecisionsIntent,
    idxDecisionTimestamp,
    idxDecisionInput,
  ];
}
