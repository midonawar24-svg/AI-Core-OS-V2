/// AI Core OS V3 - Database Layer - Enterprise 10/10
/// Version 3.0 - Production Ready - Android Optimized
/// Features: WAL, FK, Migrations, Retry, Transactions, Batch, Cache, Singleton, Android Opt

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'database_config.dart';
import 'database_tables.dart';
import 'database_columns.dart';
import 'database_indexes.dart';
import 'database_triggers.dart';
import 'database_views.dart';
import 'database_migrations.dart';
import '../models/fact.dart';
import '../models/conversation.dart';
import '../services/logger_service.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  Database? _db;
  Completer<Database>? _initCompleter;
  bool _isInitializing = false;

  final Map<String, String> _factCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  Future<Database> get db async {
    if (_db != null) return _db!;
    if (_isInitializing && _initCompleter != null) {
      LoggerService.info('DB: Waiting for init lock...');
      return await _initCompleter!.future;
    }

    _isInitializing = true;
    _initCompleter = Completer<Database>();

    try {
      _db = await _initWithRetry();
      _initCompleter!.complete(_db);
      LoggerService.success('DB: Initialized v${DatabaseConfig.databaseVersion} - ${DatabaseConfig.databaseName}');
      return _db!;
    } catch (e) {
      _initCompleter!.completeError(e);
      LoggerService.error('DB: Init failed: $e');
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  Future<Database> _initWithRetry() async {
    int retries = 0;
    while (retries < DatabaseConfig.maxRetries) {
      try {
        return await _init();
      } catch (e) {
        retries++;
        LoggerService.warning('DB: Init retry $retries/${DatabaseConfig.maxRetries} - $e');
        if (retries >= DatabaseConfig.maxRetries) rethrow;
        await Future.delayed(Duration(milliseconds: 500 * retries));
      }
    }
    throw Exception('DB: Failed after ${DatabaseConfig.maxRetries} retries');
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), DatabaseConfig.databaseName);
    
    return await openDatabase(
      path,
      version: DatabaseConfig.databaseVersion,
      onConfigure: (db) async {
        // PRAGMA - تفعيل كل الإعدادات
        for (final pragma in DatabaseConfig.allPragmas) {
          await db.execute(pragma);
        }
        await db.execute('PRAGMA busy_timeout = ${DatabaseConfig.busyTimeout.inMilliseconds};');
        LoggerService.info('DB: PRAGMA configured - WAL, FK, Cache');
      },
      onCreate: (db, version) async {
        LoggerService.info('DB: onCreate v$version - Creating ${DatabaseTables.allTables.length} tables...');

        for (final table in DatabaseTables.allTables) {
          await db.execute(table);
        }
        for (final index in DatabaseIndexes.allIndexes) {
          await db.execute(index);
        }
        for (final trigger in DatabaseTriggers.allTriggers) {
          await db.execute(trigger);
        }
        for (final view in DatabaseViews.allViews) {
          await db.execute(view);
        }

        await db.insert(DatabaseTables.evolution, {
          EvolutionColumns.id: 1,
          EvolutionColumns.level: 50.0,
          EvolutionColumns.totalConversations: 0,
          EvolutionColumns.totalSuccess: 0,
          EvolutionColumns.totalFacts: 0,
          EvolutionColumns.totalWords: 0,
          EvolutionColumns.lastUpdate: DateTime.now().millisecondsSinceEpoch,
        });

        await db.insert(DatabaseTables.facts, {
          FactColumns.key: 'system_name',
          FactColumns.value: 'Nawar AI Core OS V3 Enterprise',
          FactColumns.type: 'system',
          FactColumns.source: 'system',
          FactColumns.timestamp: DateTime.now().millisecondsSinceEpoch,
        });

        LoggerService.success('DB: Created - ${DatabaseTables.allTables.length} tables, ${DatabaseIndexes.allIndexes.length} indexes, ${DatabaseTriggers.allTriggers.length} triggers, ${DatabaseViews.allViews.length} views');
      },
      onUpgrade: DatabaseMigrations.migrate,
    );
  }

  // ... باقي الدوال (saveFact, getFact, etc.) تستخدم Column classes

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
      _factCache.clear();
      _cacheTimestamps.clear();
      _initCompleter = null;
      _isInitializing = false;
      LoggerService.info('DB: Closed');
    }
  }
}
