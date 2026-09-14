import 'signal_normalizer.dart';

class PerformanceAnalyzer {
  /// Returns performance score from 0.0 to 100.0
  static double analyze(NormalizedSignals signals) {
    // Weight factors:
    // Rep completion: 50%
    // Load compliance: 30%
    // Manageable difficulty: 20%
    final double repScore = (signals.repCompletionRatio.clamp(0.0, 1.0)) * 50.0;
    final double loadScore = (signals.loadComplianceRatio.clamp(0.0, 1.0)) * 30.0;
    final double diffScore = signals.difficultyFactor * 20.0;

    final double total = repScore + loadScore + diffScore;
    return total.clamp(0.0, 100.0);
  }
}
