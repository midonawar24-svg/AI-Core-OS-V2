/// DatabaseMigrations - نظام Migration احترافي
/// يسهل أي تحديث بعدين - Enterprise Level

import 'package:sqflite/sqflite.dart';
import 'database_tables.dart';
import 'database_indexes.dart';
import 'database_triggers.dart';
import 'database_views.dart';
import '../services/logger_service.dart';

class DatabaseMigrations {
  DatabaseMigrations._();

  static Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    LoggerService.warning('DB Migration: v$oldVersion -> v$newVersion');

    if (oldVersion < 2) {
      await _migrateToV2(db);
    }

    if (oldVersion < 3) {
      await _migrateToV3(db);
    }

    LoggerService.success('DB Migration: Completed to v$newVersion');
  }

  static Future<void> _migrateToV2(Database db) async {
    LoggerService.info('DB Migration: Migrating to v2 - Adding new indexes + triggers + views');

    // إضافة Indexes جديدة
    for (final index in DatabaseIndexes.allIndexes) {
      try {
        await db.execute(index);
      } catch (e) {
        LoggerService.warning('Migration v2 - Index skipped: $e');
      }
    }

    // إضافة Triggers
    for (final trigger in DatabaseTriggers.allTriggers) {
      try {
        await db.execute(trigger);
      } catch (e) {
        LoggerService.warning('Migration v2 - Trigger skipped: $e');
      }
    }

    // إضافة Views
    for (final view in DatabaseViews.allViews) {
      try {
        await db.execute(view);
      } catch (e) {
        LoggerService.warning('Migration v2 - View skipped: $e');
      }
    }

    // إضافة عمود embedding للبحث الدلالي المستقبلي
    try {
      await db.execute('ALTER TABLE ${DatabaseTables.facts} ADD COLUMN embedding TEXT');
      LoggerService.info('Migration v2 - Added embedding column');
    } catch (e) {
      LoggerService.warning('Migration v2 - embedding column skipped: $e');
    }

    LoggerService.success('Migration v2 completed');
  }

  static Future<void> _migrateToV3(Database db) async {
    LoggerService.info('DB Migration: Migrating to v3 - Future enhancements');
    // مكان للتحديثات المستقبلية
    LoggerService.success('Migration v3 completed');
  }
}
