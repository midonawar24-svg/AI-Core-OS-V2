/// DatabaseConfig - ثوابت PRAGMA + إعدادات قاعدة البيانات
/// Version 3.0 - Enterprise Ready - Android Optimized

class DatabaseConfig {
  DatabaseConfig._();

  // اسم وإصدار قاعدة البيانات
  static const String databaseName = 'ai_core_os_v3_enterprise.db';
  static const int databaseVersion = 2; // 1 -> 2 بسبب إضافة Indexes + Triggers + Views

  // PRAGMA - ثوابت بدل String متكرر
  static const String enableForeignKeys = 'PRAGMA foreign_keys = ON;';
  static const String enableWalMode = 'PRAGMA journal_mode = WAL;';
  static const String syncNormal = 'PRAGMA synchronous = NORMAL;';
  static const String tempStoreMemory = 'PRAGMA temp_store = MEMORY;';
  static const String cacheSize = 'PRAGMA cache_size = 10000;'; // 10MB cache
  static const String mmapSize = 'PRAGMA mmap_size = 268435456;'; // 256MB mmap

  // كل الـ PRAGMA في List - سهل التفعيل
  static const List<String> allPragmas = [
    enableForeignKeys,
    enableWalMode,
    syncNormal,
    tempStoreMemory,
    cacheSize,
    mmapSize,
  ];

  // Timeout و Retry
  static const Duration busyTimeout = Duration(seconds: 5);
  static const int maxRetries = 3;
}
