import '../database/database.dart';
import '../neural/neural_engine.dart';

class Knowledge {
  final AppDatabase _db = AppDatabase();
  final NeuralEngine _neuralEngine;
  final Map<String, String> _builtin = {
    'من انت': 'أنا نوار AI Core OS V3 - Neural Engine: Tokenizer + Embeddings + Transformer + Inference - عقل مستقل 100% أوفلاين',
    'ما هي قدراتك': 'عندي: Tokenizer حقيقي، Embeddings TF-IDF، Transformer Attention، Plugin System للمهارات، SQLite، Self Learning',
    'كيف تعمل': 'عندي Neural Engine: فهم دلالي بدل contains() + Skills قابلة للتوسع + تقييم ذاتي',
  };

  Knowledge({required NeuralEngine neuralEngine}) : _neuralEngine = neuralEngine;

  Future<void> init() async {
    await _db.db;
    // إضافة المعرفة للـ Neural Engine
    for (var entry in _builtin.entries) {
      _neuralEngine.learn(entry.key, entry.key, entry.value);
    }
  }

  Future<String?> search(String query) async {
    final q = query.toLowerCase().trim();
    
    for (var e in _builtin.entries) {
      if (q.contains(e.key.toLowerCase())) return e.value;
    }

    final semantic = await _neuralEngine.answer(query);
    if (semantic != null && (semantic['confidence'] as double) > 0.2) {
      final result = await _db.searchKnowledge(query);
      return result;
    }

    return await _db.searchKnowledge(query) ?? await _db.getFact(q);
  }

  Future<void> addKnowledge(String question, String answer) async {
    await _db.saveKnowledge(question, answer);
    _neuralEngine.learn(question, question, answer);
  }
}
