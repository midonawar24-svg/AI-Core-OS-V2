import '../database/database.dart';

/// التعلم - كل مرة تتحدث معه: يزيد قاعدة المعرفة، يتذكر الكلمات الجديدة، يحسن إجاباته بمرور الوقت
class Learning {
  final AppDatabase _db = AppDatabase();

  Future<void> init() async {
    await _db.db;
  }

  /// التعلم من كل محادثة
  Future<void> learnFromInput(String input) async {
    // 1. تذكر الكلمات الجديدة
    final words = input.split(RegExp(r'\s+')).where((w) => w.length > 2).toList();
    for (var word in words) {
      final clean = word.toLowerCase().replaceAll(RegExp(r'[؟!.,،]'), '').trim();
      if (clean.length > 2) {
        final db = await _db.db;
        final existing = await db.query('words', where: 'word = ?', whereArgs: [clean]);
        if (existing.isEmpty) {
          await db.insert('words', {
            'word': clean,
            'frequency': 1,
            'firstSeen': DateTime.now().millisecondsSinceEpoch,
            'lastSeen': DateTime.now().millisecondsSinceEpoch,
          });
        } else {
          final freq = existing.first['frequency'] as int;
          await db.update('words', {
            'frequency': freq + 1,
            'lastSeen': DateTime.now().millisecondsSinceEpoch,
          }, where: 'word = ?', whereArgs: [clean]);
        }
      }
    }
  }

  Future<void> recordSuccess(String skill) async {
    // يمكن تطوير نظام مهارات لاحقاً
  }

  Future<void> recordFailure(String skill) async {}

  Future<Map<String, dynamic>> getStats() async {
    final db = await _db.db;
    final wordsCount = await db.rawQuery('SELECT COUNT(*) as c FROM words');
    final totalFreq = await db.rawQuery('SELECT SUM(frequency) as s FROM words');
    return {
      'totalUniqueWords': wordsCount.first['c'] ?? 0,
      'totalWords': totalFreq.first['s'] ?? 0,
    };
  }
}
