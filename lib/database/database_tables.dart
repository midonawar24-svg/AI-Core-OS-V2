/// DatabaseTables - تعريف الجداول فقط
/// Version 3.0 - Enterprise - يستخدم Column Classes

import 'database_columns.dart';

class DatabaseTables {
  DatabaseTables._();

  // أسماء الجداول
  static const String conversations = 'conversations';
  static const String facts = 'facts';
  static const String words = 'words';
  static const String decisions = 'decision_logs';
  static const String evolution = 'evolution';
  static const String knowledge = 'knowledge_base';

  // CREATE - يستخدم ثوابت الجداول + الأعمدة
  static const String createConversationsTable = '''
    CREATE TABLE $conversations(
      ${ConversationColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${ConversationColumns.input} TEXT NOT NULL,
      ${ConversationColumns.output} TEXT NOT NULL,
      ${ConversationColumns.intent} TEXT NOT NULL,
      ${ConversationColumns.command} TEXT NOT NULL,
      ${ConversationColumns.confidence} REAL NOT NULL,
      ${ConversationColumns.success} INTEGER NOT NULL,
      ${ConversationColumns.timestamp} INTEGER NOT NULL
    )
  ''';

  static const String createFactsTable = '''
    CREATE TABLE $facts(
      ${FactColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${FactColumns.key} TEXT NOT NULL UNIQUE,
      ${FactColumns.value} TEXT NOT NULL,
      ${FactColumns.type} TEXT NOT NULL,
      ${FactColumns.source} TEXT NOT NULL,
      ${FactColumns.timestamp} INTEGER NOT NULL
    )
  ''';

  static const String createWordsTable = '''
    CREATE TABLE $words(
      ${WordColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${WordColumns.word} TEXT NOT NULL UNIQUE,
      ${WordColumns.frequency} INTEGER NOT NULL,
      ${WordColumns.firstSeen} INTEGER NOT NULL,
      ${WordColumns.lastSeen} INTEGER NOT NULL
    )
  ''';

  static const String createDecisionsTable = '''
    CREATE TABLE $decisions(
      ${DecisionColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DecisionColumns.input} TEXT NOT NULL,
      ${DecisionColumns.intent} TEXT NOT NULL,
      ${DecisionColumns.decision} TEXT NOT NULL,
      ${DecisionColumns.reasoning} TEXT NOT NULL,
      ${DecisionColumns.confidence} REAL NOT NULL,
      ${DecisionColumns.timestamp} INTEGER NOT NULL
    )
  ''';

  static const String createEvolutionTable = '''
    CREATE TABLE $evolution(
      ${EvolutionColumns.id} INTEGER PRIMARY KEY,
      ${EvolutionColumns.level} REAL NOT NULL,
      ${EvolutionColumns.totalConversations} INTEGER NOT NULL,
      ${EvolutionColumns.totalSuccess} INTEGER NOT NULL,
      ${EvolutionColumns.totalFacts} INTEGER NOT NULL,
      ${EvolutionColumns.totalWords} INTEGER NOT NULL,
      ${EvolutionColumns.lastUpdate} INTEGER NOT NULL
    )
  ''';

  static const String createKnowledgeTable = '''
    CREATE TABLE $knowledge(
      ${KnowledgeColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${KnowledgeColumns.question} TEXT NOT NULL UNIQUE,
      ${KnowledgeColumns.answer} TEXT NOT NULL,
      ${KnowledgeColumns.category} TEXT NOT NULL,
      ${KnowledgeColumns.timestamp} INTEGER NOT NULL
    )
  ''';

  static const List<String> allTables = [
    createConversationsTable,
    createFactsTable,
    createWordsTable,
    createDecisionsTable,
    createEvolutionTable,
    createKnowledgeTable,
  ];
}
