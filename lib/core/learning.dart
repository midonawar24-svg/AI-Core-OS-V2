import '../database/database.dart';
import '../neural/neural_engine.dart';

class Learning {
  final AppDatabase _db = AppDatabase();
  final NeuralEngine _neuralEngine;

  Learning({required NeuralEngine neuralEngine}) : _neuralEngine = neuralEngine;

  Future<void> init() async => await _db.db;

  Future<void> learnFromInput(String input) async {
    final db = await _db.db;
    final tokens = input.split(RegExp(r'\s+')).where((w) => w.length > 2).toList();
    
    for (var word in tokens) {
      final clean = word.toLowerCase().replaceAll(RegExp(r'[؟!.,،]'), '').trim();
      if (clean.length > 2) {
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

  // مرحلة 4: تقييم ذاتي
  Future<double> selfEvaluate(String question, String answer, String intent) async {
    return _neuralEngine.selfEvaluate(question, answer, intent);
  }

  Future<Map<String, dynamic>> getStats() async {
    final db = await _db.db;
    final wordsCount = await db.rawQuery('SELECT COUNT(*) as c FROM words');
    return {'totalUniqueWords': wordsCount.first['c'] ?? 0};
  }
}
