/// AI Core OS V3 - Migrations Layer - 10/10 FINAL LOCKED FOREVER
/// No return - Ready for Decision Engine / Learning Engine / Reasoning

import 'package:sqflite/sqflite.dart';
import 'tables.dart';
import '../services/logger_service.dart';

typedef MigrationHandler = Future<void> Function(Transaction txn);

class DatabaseMigrations {
  DatabaseMigrations._();

  static const int firstMigrationVersion = 3;

  static final Map<int, MigrationHandler> _migrations = Map.unmodifiable({
    firstMigrationVersion: _migrateToV3,
    // 4: _migrateToV4, // Reserved
    // 5: _migrateToV5, // Reserved
  });

  static Future<void> migrate(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Gap detection - يمسك أي فجوة {3,5} أو نسيان v4
    assert(
      () {
        for (int i = firstMigrationVersion; i <= Tables.schemaVersion; i++) {
          if (!_migrations.containsKey(i)) {
            throw StateError(
              'Missing migration v$i - Registry: ${_migrations.keys.toList()} vs schemaVersion: ${Tables.schemaVersion}',
            );
          }
        }
        return true;
      }(),
    );

    LoggerService.info('DB: Migration check $oldVersion -> $newVersion');

    if (oldVersion >= newVersion) {
      LoggerService.info('DB: No migration required');
      return;
    }

    int? currentVersion;
    final migratedVersions = <int>[];

    try {
      await db.transaction((txn) async {
        for (int version = oldVersion + 1; version <= newVersion; version++) {
          final migration = _migrations[version];
          if (migration == null) {
            throw StateError('Missing migration for version $version');
          }
          currentVersion = version;
          await migration(txn);
          migratedVersions.add(version);
        }
      });

      // تفاصيل كل إصدار بعد الـ Commit - لا False Success
      for (final version in migratedVersions) {
        if (version == firstMigrationVersion) {
          LoggerService.success(
            'DB: Migrated to v$version - ${Tables.allIndexes.length} indexes created',
          );
        } else {
          LoggerService.success('DB: Migrated to v$version');
        }
      }

      LoggerService.success(
        'DB: Database upgraded successfully to v$newVersion',
      );
    } catch (e, st) {
      LoggerService.error(
        'DB: Migration $oldVersion -> $currentVersion failed: $e',
        st,
      );
      rethrow;
    }
  }

  static Future<void> _migrateToV3(Transaction txn) async {
    for (final index in Tables.allIndexes) {
      await txn.execute(index);
    }
  }
}
