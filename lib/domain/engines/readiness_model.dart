import '../analyzers/trend_analyzer.dart';

class ReadinessEvaluation {
  final double readinessScore; // 0.0 to 100.0
  final double confidence; // 0.0 to 100.0
  final List<String> factors;

  ReadinessEvaluation({
    required this.readinessScore,
    required this.confidence,
    required this.factors,
  });
}

class ReadinessModel {
  static ReadinessEvaluation evaluate({
    required double performanceScore,
    required double recoveryScore,
    required TrendAnalysis trend,
    required int historyCount,
  }) {
    final List<String> factors = [];

    // Weighting:
    // Performance: 40%
    // Recovery: 35%
    // Trend modifier: 25%

    double trendModifier = 50.0;
    if (trend.direction == TrendDirection.improving) {
      trendModifier = 85.0;
      factors.add(
        'Recent performance trend is positive (+${trend.slope.toStringAsFixed(1)})',
      );
    } else if (trend.direction == TrendDirection.declining) {
      trendModifier = 25.0;
      factors.add(
        'Recent performance trend is declining (${trend.slope.toStringAsFixed(1)})',
      );
    } else {
      factors.add('Performance and recovery are stable');
    }

    final double currentScore =
        (performanceScore * 0.40) +
        (recoveryScore * 0.35) +
        (trendModifier * 0.25);

    // One session contains noisy, partly subjective inputs. Once we have a
    // small history, retain the current signal while anchoring it to the
    // athlete's recent readiness baseline. This prevents one unusually good
    // or bad day from carrying the same weight as a sustained trend.
    final bool hasReliableHistory = historyCount >= 2;
    final double score = hasReliableHistory
        ? (currentScore * 0.60) + (trend.averageReadiness * 0.40)
        : currentScore;
    if (hasReliableHistory) {
      factors.add(
        'Current signals are weighted against the recent readiness baseline',
      );
    }

    // Confidence grows with session history
    final double confidence = (50.0 + (historyCount * 10.0)).clamp(50.0, 95.0);

    return ReadinessEvaluation(
      readinessScore: score.clamp(0.0, 100.0),
      confidence: confidence,
      factors: factors,
    );
  }
}
