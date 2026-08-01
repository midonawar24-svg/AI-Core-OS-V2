/// DatabaseIndexes - كل الـ Indexes - مرتبة حسب الجدول
/// 16 Index احترافي - Enterprise Level

import 'database_tables.dart';
import 'database_columns.dart';

class DatabaseIndexes {
  DatabaseIndexes._();

  // ========== Facts Indexes ==========
  static const String factsKeyIndex = 'CREATE INDEX IF NOT EXISTS idx_facts_key_index ON ${DatabaseTables.facts}(${FactColumns.key})';
  static const String factsTypeIndex = 'CREATE INDEX IF NOT EXISTS idx_facts_type_index ON ${DatabaseTables.facts}(${FactColumns.type})';
  static const String factsTimestampIndex = 'CREATE INDEX IF NOT EXISTS idx_facts_timestamp_index ON ${DatabaseTables.facts}(${FactColumns.timestamp} DESC)';
  static const String factsTypeTimeCompositeIndex = 'CREATE INDEX IF NOT EXISTS idx_facts_type_time_composite ON ${DatabaseTables.facts}(${FactColumns.type}, ${FactColumns.timestamp} DESC)';

  // ========== Conversations Indexes ==========
  static const String conversationsInputIndex = 'CREATE INDEX IF NOT EXISTS idx_conversations_input_index ON ${DatabaseTables.conversations}(${ConversationColumns.input})';
  static const String conversationsTimestampIndex = 'CREATE INDEX IF NOT EXISTS idx_conversations_timestamp_index ON ${DatabaseTables.conversations}(${ConversationColumns.timestamp} DESC)';
  static const String conversationsIntentIndex = 'CREATE INDEX IF NOT EXISTS idx_conversations_intent_index ON ${DatabaseTables.conversations}(${ConversationColumns.intent})';
  static const String conversationsSuccessIndex = 'CREATE INDEX IF NOT EXISTS idx_conversations_success_index ON ${DatabaseTables.conversations}(${ConversationColumns.success}, ${ConversationColumns.timestamp} DESC)';
  static const String conversationsIntentSuccessIndex = 'CREATE INDEX IF NOT EXISTS idx_conversations_intent_success_index ON ${DatabaseTables.conversations}(${ConversationColumns.intent}, ${ConversationColumns.success})';
  static const String conversationsIntentTimeCompositeIndex = 'CREATE INDEX IF NOT EXISTS idx_conversations_intent_time_composite ON ${DatabaseTables.conversations}(${ConversationColumns.intent}, ${ConversationColumns.timestamp} DESC)';

  // ========== Words Indexes ==========
  static const String wordsWordIndex = 'CREATE INDEX IF NOT EXISTS idx_words_word_index ON ${DatabaseTables.words}(${WordColumns.word})';
  static const String wordsFrequencyIndex = 'CREATE INDEX IF NOT EXISTS idx_words_frequency_index ON ${DatabaseTables.words}(${WordColumns.frequency} DESC)';

  // ========== Knowledge Indexes ==========
  static const String knowledgeQuestionIndex = 'CREATE INDEX IF NOT EXISTS idx_knowledge_question_index ON ${DatabaseTables.knowledge}(${KnowledgeColumns.question})';
  static const String knowledgeCategoryIndex = 'CREATE INDEX IF NOT EXISTS idx_knowledge_category_index ON ${DatabaseTables.knowledge}(${KnowledgeColumns.category})';

  // ========== Decisions Indexes ==========
  static const String decisionsIntentIndex = 'CREATE INDEX IF NOT EXISTS idx_decisions_intent_index ON ${DatabaseTables.decisions}(${DecisionColumns.intent})';

  static const List<String> allIndexes = [
    // Facts - 4 indexes
    factsKeyIndex,
    factsTypeIndex,
    factsTimestampIndex,
    factsTypeTimeCompositeIndex,

    // Conversations - 6 indexes
    conversationsInputIndex,
    conversationsTimestampIndex,
    conversationsIntentIndex,
    conversationsSuccessIndex,
    conversationsIntentSuccessIndex,
    conversationsIntentTimeCompositeIndex,

    // Words - 2 indexes
    wordsWordIndex,
    wordsFrequencyIndex,

    // Knowledge - 2 indexes
    knowledgeQuestionIndex,
    knowledgeCategoryIndex,

    // Decisions - 1 index
    decisionsIntentIndex,
  ];
}
