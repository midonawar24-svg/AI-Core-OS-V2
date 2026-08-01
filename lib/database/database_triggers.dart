/// DatabaseTriggers - Triggers للذكاء التلقائي
/// SQLite سريع جداً مع الـ Trigger - Enterprise

import 'database_tables.dart';
import 'database_columns.dart';

class DatabaseTriggers {
  DatabaseTriggers._();

  static const String updateWordTimestampTrigger = '''
    CREATE TRIGGER IF NOT EXISTS trigger_update_word_timestamp
    AFTER UPDATE ON ${DatabaseTables.words}
    BEGIN
      UPDATE ${DatabaseTables.words}
      SET ${WordColumns.lastSeen} = strftime('%s', 'now') * 1000
      WHERE ${WordColumns.id} = NEW.${WordColumns.id};
    END;
  ''';

  static const String incrementWordFrequencyTrigger = '''
    CREATE TRIGGER IF NOT EXISTS trigger_increment_word_frequency
    AFTER UPDATE OF ${WordColumns.frequency} ON ${DatabaseTables.words}
    BEGIN
      UPDATE ${DatabaseTables.words}
      SET ${WordColumns.lastSeen} = strftime('%s', 'now') * 1000
      WHERE ${WordColumns.id} = NEW.${WordColumns.id};
    END;
  ''';

  static const String logFactChangeTrigger = '''
    CREATE TRIGGER IF NOT EXISTS trigger_log_fact_change
    AFTER UPDATE ON ${DatabaseTables.facts}
    BEGIN
      UPDATE ${DatabaseTables.facts}
      SET ${FactColumns.timestamp} = strftime('%s', 'now') * 1000
      WHERE ${FactColumns.id} = NEW.${FactColumns.id};
    END;
  ''';

  static const List<String> allTriggers = [
    updateWordTimestampTrigger,
    incrementWordFrequencyTrigger,
    logFactChangeTrigger,
  ];
}
