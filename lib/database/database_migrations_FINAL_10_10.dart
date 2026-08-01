/// AI Core OS V3 - Migrations Layer - Enterprise
/// Production Ready - Versioned Migrations

import 'package:sqflite/sqflite.dart';
import 'tables.dart';
import '../services/logger_service.dart';

class DatabaseMigrations {
  DatabaseMigrations._();

  static Future<void> migrate(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    LoggerService.info(
      'DB: Migration $oldVersion -> $newVersion',
    );

    await db.transaction((txn) async {
      // =========================
      // Version 3
      // =========================
      if (oldVersion < 3) {
        for (final index in Tables.allIndexes) {
          try {
            await txn.execute(index);
          } catch (e) {
            LoggerService.warning(
              'DB: Skipping index: $e',
            );
          }
        }

        LoggerService.success(
          'DB: Migration v3 completed',
        );
      }

      // =========================
      // Version 4
      // =========================
      // if (oldVersion < 4) {
      //   await txn.execute('...');
      // }

      // =========================
      // Version 5
      // =========================
      // if (oldVersion < 5) {
      //   await txn.execute('...');
      // }
    });

    LoggerService.success(
      'DB: Database is up to date (v$newVersion)',
    );
  }
}
