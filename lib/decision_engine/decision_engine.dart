/// AI Core OS V2 - Decision Engine - ENTERPRISE 10/10 LOCKED
/// Sorted Registry Once + Rich Metadata + No! + No Magic Numbers

import '../services/logger_service.dart';

/// كل الأرقام في مكان واحد
class DecisionConstants {
  static const double maxFactConfidence = 0.95;
  static const double maxMemoryConfidence = 0.85;
  static const double fallbackConfidence = 0.1;
  static const double factBaseScore = 0.2;
  static const double factCountDivider = 20.0;
  static const double factCountMax = 0.5;
  static const double goalBoost = 0.15;
  static const double enoughFactsBoost = 0.1;
  static const int enoughFactsThreshold = 3;
  static const double memoryBaseScore = 0.25;
  static const double memoryCountDivider = 15.0;
  static const double memoryCountMax = 0.4;
  static const double sessionBoost = 0.1;
  static const double userBoost = 0.1;
  static const int factPriority = 100;
  static const int memoryPriority = 80;
  static const int fallbackPriority = 0;
  DecisionConstants._();
}

class StrategyNames {
  static const String factBased = 'fact_based';
  static const String memoryBased = 'memory_based';
  static const String fallback = 'fallback';
  static const List<String> all = [factBased, memoryBased, fallback];
  StrategyNames._();
}

class DecisionContext {
  final String userQuery;
  final List<Map<String, dynamic>> facts;
  final Map<String, dynamic> memory;
  final Map<String, dynamic> goals;
  final String? sessionId;
  final String? conversationId;
  final String? userId;
  final String? locale;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  DecisionContext({
    required this.userQuery,
    this.facts = const [],
    this.memory = const {},
    this.goals = const {},
    this.sessionId,
    this.conversationId,
    this.userId,
    this.locale,
    this.metadata = const {},
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get hasFacts => facts.isNotEmpty;
  bool get hasMemory => memory.isNotEmpty;
  bool get hasGoals => goals.isNotEmpty;
}

class DecisionResult {
  final String decision;
  final double confidence;
  final String reasoning;
  final String strategyUsed;
  final List<String> alternatives;
  final Map<String, dynamic> metadata;

  const DecisionResult({
    required this.decision,
    required this.confidence,
    required this.reasoning,
    required this.strategyUsed,
    this.alternatives = const [],
    this.metadata = const {},
  });

  bool get isHighConfidence => confidence >= 0.8;
  bool get isLowConfidence => confidence < 0.5;

  DecisionResult copyWith({
    String? decision,
    double? confidence,
    String? reasoning,
    String? strategyUsed,
    List<String>? alternatives,
    Map<String, dynamic>? metadata,
  }) {
    return DecisionResult(
      decision: decision ?? this.decision,
      confidence: confidence ?? this.confidence,
      reasoning: reasoning ?? this.reasoning,
      strategyUsed: strategyUsed ?? this.strategyUsed,
      alternatives: alternatives ?? this.alternatives,
      metadata: metadata ?? this.metadata,
    );
  }
}

abstract class DecisionStrategy {
  String get name;
  String get version;
  int get priority;
  bool canHandle(DecisionContext context);
  Future<double> score(DecisionContext context);
  Future<DecisionResult> decide(DecisionContext context);
}

class FactBasedStrategy implements DecisionStrategy {
  @override
  String get name => StrategyNames.factBased;
  @override
  String get version => '1.0';
  @override
  int get priority => DecisionConstants.factPriority;

  @override
  bool canHandle(DecisionContext context) => context.hasFacts;

  @override
  Future<double> score(DecisionContext context) async {
    if (!canHandle(context)) return 0.0;
    final countFactor = (context.facts.length / DecisionConstants.factCountDivider)
        .clamp(0.0, DecisionConstants.factCountMax);
    final goalBoost = context.hasGoals ? DecisionConstants.goalBoost : 0.0;
    final enoughBoost = _hasEnoughFacts(context) ? DecisionConstants.enoughFactsBoost : 0.0;
    final total = countFactor + goalBoost + enoughBoost + DecisionConstants.factBaseScore;
    return total.clamp(0.0, DecisionConstants.maxFactConfidence);
  }

  bool _hasEnoughFacts(DecisionContext context) {
    return context.facts.length > DecisionConstants.enoughFactsThreshold;
  }

  @override
  Future<DecisionResult> decide(DecisionContext context) async {
    LoggerService.info('Decision: FactBased handling "${context.userQuery}"');
    return DecisionResult(
      decision: 'Decision based on ${context.facts.length} facts',
      confidence: await score(context),
      reasoning:
          'Found ${context.facts.length} facts, hasGoals=${context.hasGoals}, enough=${_hasEnoughFacts(context)}',
      strategyUsed: name,
      metadata: {
        'factsCount': context.facts.length,
        'scoring': 'count + goals + enoughFacts',
      },
    );
  }
}

class MemoryBasedStrategy implements DecisionStrategy {
  @override
  String get name => StrategyNames.memoryBased;
  @override
  String get version => '1.0';
  @override
  int get priority => DecisionConstants.memoryPriority;

  @override
  bool canHandle(DecisionContext context) => context.hasMemory;

  @override
  Future<double> score(DecisionContext context) async {
    if (!canHandle(context)) return 0.0;
    final memoryCount = context.memory.length;
    final countFactor = (memoryCount / DecisionConstants.memoryCountDivider)
        .clamp(0.0, DecisionConstants.memoryCountMax);
    final sessionBoost = context.sessionId != null ? DecisionConstants.sessionBoost : 0.0;
    final userBoost = context.userId != null ? DecisionConstants.userBoost : 0.0;
    final total = countFactor + sessionBoost + userBoost + DecisionConstants.memoryBaseScore;
    return total.clamp(0.0, DecisionConstants.maxMemoryConfidence);
  }

  @override
  Future<DecisionResult> decide(DecisionContext context) async {
    return DecisionResult(
      decision: 'Decision based on ${context.memory.length} memory entries',
      confidence: await score(context),
      reasoning:
          'Memory count=${context.memory.length}, session=${context.sessionId != null}',
      strategyUsed: name,
    );
  }
}

class FallbackStrategy implements DecisionStrategy {
  @override
  String get name => StrategyNames.fallback;
  @override
  String get version => '1.0';
  @override
  int get priority => DecisionConstants.fallbackPriority;

  @override
  bool canHandle(DecisionContext context) => true;

  @override
  Future<double> score(DecisionContext context) async {
    return DecisionConstants.fallbackConfidence;
  }

  @override
  Future<DecisionResult> decide(DecisionContext context) async {
    return const DecisionResult(
      decision: 'No confident decision - need more data',
      confidence: DecisionConstants.fallbackConfidence,
      reasoning: 'No strategy had high confidence, using fallback',
      strategyUsed: StrategyNames.fallback,
    );
  }
}

/// المحرك - ENTERPRISE 10/10
class DecisionEngine {
  DecisionEngine._();

  static const String firstStrategy = StrategyNames.factBased;

  // ترتيب مرة واحدة حسب الأولوية
  static final List<DecisionStrategy> _orderedStrategies = [
    FactBasedStrategy(),
    MemoryBasedStrategy(),
    FallbackStrategy(),
  ]..sort((a, b) => b.priority.compareTo(a.priority));

  // Registry للبحث السريع
  static final Map<String, DecisionStrategy> _strategies = Map.unmodifiable({
    for (final s in _orderedStrategies) s.name: s,
  });

  static Future<DecisionResult> makeDecision(DecisionContext context) async {
    final fallback = _strategies[StrategyNames.fallback];
    if (fallback == null) {
      throw StateError('Fallback strategy "${StrategyNames.fallback}" is not registered');
    }

    LoggerService.info('DecisionEngine: Processing "${context.userQuery}"');

    if (context.userQuery.trim().isEmpty) {
      LoggerService.warning('DecisionEngine: Empty query');
      return const DecisionResult(
        decision: 'Empty query',
        confidence: 0.0,
        reasoning: 'User query is empty',
        strategyUsed: 'validation',
      );
    }

    final capable = <DecisionStrategy>[];
    for (final strategy in _orderedStrategies) {
      if (strategy.canHandle(context)) {
        capable.add(strategy);
      }
    }

    DecisionStrategy? bestStrategy;
    double bestScore = -1;

    for (final strategy in capable) {
      try {
        final score = await strategy.score(context);
        LoggerService.info('DecisionEngine: ${strategy.name} scored $score (priority ${strategy.priority})');
        if (score > bestScore) {
          bestScore = score;
          bestStrategy = strategy;
        }
      } catch (e, st) {
        LoggerService.error('DecisionEngine: ${strategy.name} failed: $e', st);
      }
    }

    final selected = bestStrategy ?? fallback;

    try {
      final rawResult = await selected.decide(context);

      final enrichedMetadata = {
        ...rawResult.metadata,
        'score': bestScore,
        'priority': selected.priority,
        'timestamp': context.timestamp.toIso8601String(),
        'query': context.userQuery,
        'strategiesChecked': capable.length,
        'allScores': {for (final s in capable) s.name: await s.score(context)},
        'sessionId': context.sessionId,
        'userId': context.userId,
      };

      final result = rawResult.copyWith(metadata: enrichedMetadata);

      LoggerService.success(
        'DecisionEngine: ${result.strategyUsed} -> ${result.confidence} - ${result.decision}',
      );
      return result;
    } catch (e, st) {
      LoggerService.error('DecisionEngine: ${selected.name} decide failed: $e', st);
      return fallback.decide(context);
    }
  }

  static bool hasStrategy(String name) => _strategies.containsKey(name);
  static List<String> get availableStrategies => _strategies.keys.toList();
  static List<DecisionStrategy> get orderedStrategies => List.unmodifiable(_orderedStrategies);
}
