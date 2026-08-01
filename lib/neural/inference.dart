import 'embeddings.dart';
import 'tokenizer.dart';

/// محرك الاستنتاج - Inference Engine
/// يربط بين السؤال وقاعدة المعرفة ويستنتج الإجابة
class InferenceEngine {
  final EmbeddingsEngine _embeddings = EmbeddingsEngine();
  final Tokenizer _tokenizer = Tokenizer();
  bool _initialized = false;

  Future<void> init(List<Map<String, String>> knowledgeBase) async {
    if (_initialized) return;
    
    for (var item in knowledgeBase) {
      final id = item['id'] ?? item['question'] ?? '';
      final text = '${item['question'] ?? ''} ${item['answer'] ?? ''}';
      _embeddings.addDocument(id, text);
    }
    
    _initialized = true;
  }

  void addKnowledge(String id, String question, String answer) {
    _embeddings.addDocument(id, '$question $answer');
  }

  // الاستنتاج الحقيقي - بدل if/else
  Future<Map<String, dynamic>?> infer(String query, {double threshold = 0.15}) async {
    final results = _embeddings.semanticSearch(query, topK: 1, threshold: threshold);
    
    if (results.isEmpty) return null;
    
    final best = results.first;
    return {
      'id': best['id'],
      'confidence': best['similarity'],
      'similarity': best['similarity'],
    };
  }

  // تقييم الإجابة - Self Learning مرحلة 4
  double evaluateAnswer(String question, String answer, String expectedIntent) {
    final qTokens = _tokenizer.tokenize(question);
    final aTokens = _tokenizer.tokenize(answer);
    
    // بسيط: لو الإجابة فيها كلمات من السؤال + طول مناسب = جيدة
    final overlap = qTokens.where((t) => aTokens.contains(t)).length;
    final lengthScore = (aTokens.length >= 3 && aTokens.length <= 30) ? 0.3 : 0;
    final overlapScore = qTokens.isNotEmpty ? (overlap / qTokens.length) * 0.7 : 0;
    
    return (lengthScore + overlapScore).clamp(0.0, 1.0);
  }

  void clear() => _embeddings.clear();
}
