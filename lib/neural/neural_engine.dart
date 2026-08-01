import 'tokenizer.dart';
import 'embeddings.dart';
import 'transformer.dart';
import 'inference.dart';

/// المحرك العصبي الرئيسي - Neural Engine
/// يجمع كل شيء: Tokenizer + Embeddings + Transformer + Inference
/// هذا هو الأساس لـ GGUF/ONNX/TFLite في المرحلة 3
class NeuralEngine {
  final Tokenizer tokenizer = Tokenizer();
  final EmbeddingsEngine embeddings = EmbeddingsEngine();
  final TransformerEngine transformer = TransformerEngine();
  final InferenceEngine inference = InferenceEngine();

  bool _initialized = false;
  double _confidenceThreshold = 0.15;

  Future<void> init({List<Map<String, String>>? knowledgeBase}) async {
    if (_initialized) return;
    
    if (knowledgeBase != null) {
      await inference.init(knowledgeBase);
      for (var item in knowledgeBase) {
        final id = item['id'] ?? item['question'] ?? '';
        final text = '${item['question'] ?? ''} ${item['answer'] ?? ''}';
        embeddings.addDocument(id, text);
      }
    }
    
    _initialized = true;
  }

  /// الفهم الحقيقي - بدل contains()
  Future<Map<String, dynamic>> understand(String text) async {
    final tokens = tokenizer.tokenize(text);
    final tf = tokenizer.getTermFrequency(tokens);
    final embeddingsVector = embeddings.semanticSearch(text, topK: 3);
    
    return {
      'tokens': tokens,
      'termFrequency': tf,
      'semanticResults': embeddingsVector,
      'tokensCount': tokens.length,
    };
  }

  /// استنتاج الإجابة - Inference
  Future<Map<String, dynamic>?> answer(String query) async {
    return await inference.infer(query, threshold: _confidenceThreshold);
  }

  /// تقييم ذاتي - مرحلة 4 Self Learning
  double selfEvaluate(String question, String answer, String intent) {
    return inference.evaluateAnswer(question, answer, intent);
  }

  /// إضافة معرفة جديدة - التعلم المستمر
  void learn(String id, String question, String answer) {
    embeddings.addDocument(id, '$question $answer');
    inference.addKnowledge(id, question, answer);
  }

  void setThreshold(double threshold) => _confidenceThreshold = threshold;
  void clear() {
    embeddings.clear();
    inference.clear();
  }

  Map<String, dynamic> getStats() {
    return {
      'initialized': _initialized,
      'documents': embeddings.docsCount,
      'threshold': _confidenceThreshold,
    };
  }
}
