import 'dart:math';

/// Transformer مبسط - Self-Attention
/// أساس لفهم السياق - مرحلة انتقالية قبل GGUF/ONNX
class TransformerEngine {
  final Random _random = Random(42);
  static const int _embeddingSize = 64;
  static const int _heads = 4;

  // Self-Attention مبسط
  List<double> selfAttention(List<List<double>> embeddings) {
    if (embeddings.isEmpty) return [];
    
    final seqLen = embeddings.length;
    final headSize = _embeddingSize ~/ _heads;
    
    // Simplified attention scores
    final attentionScores = List.generate(seqLen, (_) => List.filled(seqLen, 0.0));
    
    for (int i = 0; i < seqLen; i++) {
      for (int j = 0; j < seqLen; j++) {
        double score = 0;
        for (int k = 0; k < min(embeddings[i].length, embeddings[j].length); k++) {
          score += embeddings[i][k] * embeddings[j][k];
        }
        attentionScores[i][j] = score / sqrt(headSize);
      }
    }

    // Softmax
    final attended = <double>[];
    for (int i = 0; i < seqLen; i++) {
      double maxScore = attentionScores[i].reduce(max);
      double sumExp = 0;
      for (var score in attentionScores[i]) {
        sumExp += exp(score - maxScore);
      }
      
      double weighted = 0;
      for (int j = 0; j < seqLen; j++) {
        final prob = exp(attentionScores[i][j] - maxScore) / sumExp;
        weighted += prob * (j < embeddings.length ? embeddings[j].fold(0.0, (a, b) => a + b) / embeddings[j].length : 0);
      }
      attended.add(weighted);
    }

    return attended;
  }

  // تحويل توكنز لـ embeddings عشوائية (مؤقتاً - لحد ما نجيب موديل حقيقي)
  List<List<double>> tokensToEmbeddings(List<String> tokens) {
    return tokens.map((token) {
      final hash = token.hashCode;
      return List.generate(_embeddingSize, (i) => sin(hash * 0.1 + i * 0.5) * 0.5 + _random.nextDouble() * 0.5);
    }).toList();
  }

  // فهم النية باستخدام Attention
  double understandIntent(List<String> tokens, List<String> intentKeywords) {
    if (tokens.isEmpty || intentKeywords.isEmpty) return 0;
    
    final tokenEmbeddings = tokensToEmbeddings(tokens);
    final keywordEmbeddings = tokensToEmbeddings(intentKeywords);
    
    final attendedTokens = selfAttention(tokenEmbeddings);
    final attendedKeywords = selfAttention(keywordEmbeddings);
    
    if (attendedTokens.isEmpty || attendedKeywords.isEmpty) return 0;
    
    double similarity = 0;
    for (int i = 0; i < min(attendedTokens.length, attendedKeywords.length); i++) {
      similarity += (attendedTokens[i] - attendedKeywords[i]).abs() < 0.5 ? 1 : 0;
    }
    
    return similarity / max(tokens.length, intentKeywords.length);
  }
}
