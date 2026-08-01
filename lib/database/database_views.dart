/// DatabaseViews - Views للمستقبل
/// تريحك بعدين - Enterprise Level

import 'database_tables.dart';
import 'database_columns.dart';

class DatabaseViews {
  DatabaseViews._();

  static const String recentConversationsView = '''
    CREATE VIEW IF NOT EXISTS view_recent_conversations AS
    SELECT *
    FROM ${DatabaseTables.conversations}
    ORDER BY ${ConversationColumns.timestamp} DESC
    LIMIT 100;
  ''';

  static const String successfulConversationsView = '''
    CREATE VIEW IF NOT EXISTS view_successful_conversations AS
    SELECT *
    FROM ${DatabaseTables.conversations}
    WHERE ${ConversationColumns.success} = 1
    ORDER BY ${ConversationColumns.timestamp} DESC;
  ''';

  static const String topWordsView = '''
    CREATE VIEW IF NOT EXISTS view_top_words AS
    SELECT *
    FROM ${DatabaseTables.words}
    ORDER BY ${WordColumns.frequency} DESC
    LIMIT 50;
  ''';

  static const String personalFactsView = '''
    CREATE VIEW IF NOT EXISTS view_personal_facts AS
    SELECT *
    FROM ${DatabaseTables.facts}
    WHERE ${FactColumns.type} = 'personal'
    ORDER BY ${FactColumns.timestamp} DESC;
  ''';

  static const List<String> allViews = [
    recentConversationsView,
    successfulConversationsView,
    topWordsView,
    personalFactsView,
  ];
}
