import 'dart:math';
import 'tokenizer.dart';

/// Embeddings حقيقية - TF-IDF + Cosine Similarity
/// بدل contains() -> فهم دلالي حقيقي
class EmbeddingsEngine {
  final Tokenizer _tokenizer = Tokenizer();
  final Map<String, Map<String, double>> _documentVectors = {};
  final Map<String, int> _documentFrequency = {};
  int _totalDocs = 0;

  // إضافة مستند لقاعدة المعرفة
  void addDocument(String id, String text) {
    final tokens = _tokenizer.tokenize(text);
    if (tokens.isEmpty) return;

    final tf = _tokenizer.getTermFrequency(tokens);
    final vector = <String, double>{};
    
    for (var entry in tf.entries) {
      // TF
      final tfScore = entry.value / tokens.length;
      vector[entry.key] = tfScore;
      
      // DF
      _documentFrequency[entry.key] = (_documentFrequency[entry.key] ?? 0) + 1;
    }
    
    _documentVectors[id] = vector;
    _totalDocs++;
  }

  // حساب TF-IDF vector
  Map<String, double> _getTfIdfVector(Map<String, double> tfVector) {
    final tfidf = <String, double>{};
    for (var entry in tfVector.entries) {
      final term = entry.key;
      final tf = entry.value;
      final df = _documentFrequency[term] ?? 1;
      final idf = log(_totalDocs / df + 1);
      tfidf[term] = tf * idf;
    }
    return tfidf;
  }

  // Cosine Similarity
  double cosineSimilarity(Map<String, double> vecA, Map<String, double> vecB) {
    if (vecA.isEmpty || vecB.isEmpty) return 0.0;
    
    double dotProduct = 0;
    double magA = 0;
    double magB = 0;

    final allKeys = {...vecA.keys, ...vecB.keys};
    
    for (var key in allKeys) {
      final a = vecA[key] ?? 0;
      final b = vecB[key] ?? 0;
      dotProduct += a * b;
      magA += a * a;
      magB += b * b;
    }

    if (magA == 0 || magB == 0) return 0;
    return dotProduct / (sqrt(magA) * sqrt(magB));
  }

  // البحث الدلالي - أهم دالة
  List<Map<String, dynamic>> semanticSearch(String query, {int topK = 3, double threshold = 0.1}) {
    final queryTokens = _tokenizer.tokenize(query);
    if (queryTokens.isEmpty) return [];

    final queryTf = _tokenizer.getTermFrequency(queryTokens);
    final queryVector = <String, double>{};
    for (var entry in queryTf.entries) {
      queryVector[entry.key] = entry.value / queryTokens.length;
    }
    final queryTfIdf = _getTfIdfVector(queryVector);

    final results = <Map<String, dynamic>>[];
    
    for (var entry in _documentVectors.entries) {
      final docId = entry.key;
      final docVector = _getTfIdfVector(entry.value);
      final similarity = cosineSimilarity(queryTfIdf, docVector);
      
      if (similarity >= threshold) {
        results.add({'id': docId, 'similarity': similarity, 'vector': docVector});
      }
    }

    results.sort((a, b) => (b['similarity'] as double).compareTo(a['similarity'] as double));
    return results.take(topK).toList();
  }

  void clear() {
    _documentVectors.clear();
    _documentFrequency.clear();
    _totalDocs = 0;
  }

  int get docsCount => _totalDocs;
}
