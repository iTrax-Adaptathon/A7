import '../../data/models/workout_session.dart';
import 'performance_analyzer.dart';
import 'signal_normalizer.dart';

enum TrendDirection { improving, stable, declining }

class TrendAnalysis {
  final TrendDirection direction;
  final double averagePerformance;
  final double averageReadiness;
  final double slope;

  TrendAnalysis({
    required this.direction,
    required this.averagePerformance,
    required this.averageReadiness,
    required this.slope,
  });
}

class TrendAnalyzer {
  static TrendAnalysis analyze(List<WorkoutSession> history) {
    if (history.isEmpty) {
      return TrendAnalysis(
        direction: TrendDirection.stable,
        averagePerformance: 80.0,
        averageReadiness: 80.0,
        slope: 0.0,
      );
    }

    // Look at last 5 sessions max
    final recent = history.take(5).toList();
    double totalPerf = 0;
    double totalReadiness = 0;

    for (final s in recent) {
      totalPerf += s.performanceScore;
      totalReadiness += s.readinessScore;
    }

    final double avgPerf = totalPerf / recent.length;
    final double avgReadiness = totalReadiness / recent.length;

    if (recent.length < 2) {
      return TrendAnalysis(
        direction: TrendDirection.stable,
        averagePerformance: avgPerf,
        averageReadiness: avgReadiness,
        slope: 0.0,
      );
    }

    // Fit performance over time using all sessions in chronological order.
    // `recent` is newest-first, so reverse its index for an oldest-to-newest x.
    final int count = recent.length;
    final double meanX = (count - 1) / 2;
    final double meanY = avgPerf;
    double numerator = 0;
    double denominator = 0;
    for (int index = 0; index < count; index++) {
      final double x = (count - 1 - index).toDouble();
      final double xDelta = x - meanX;
      numerator += xDelta * (recent[index].performanceScore - meanY);
      denominator += xDelta * xDelta;
    }
    final double slope = denominator == 0 ? 0 : numerator / denominator;

    TrendDirection dir = TrendDirection.stable;
    if (slope > 4.0) {
      dir = TrendDirection.improving;
    } else if (slope < -4.0) {
      dir = TrendDirection.declining;
    }

    return TrendAnalysis(
      direction: dir,
      averagePerformance: avgPerf,
      averageReadiness: avgReadiness,
      slope: slope,
    );
  }

  /// Reconstructs a lift-specific performance history from the workout log.
  /// Sessions are newest-first, matching the existing whole-session analysis.
  static TrendAnalysis analyzeForExercise(
    String exerciseId,
    List<WorkoutSession> history,
  ) {
    final scores = <double>[];
    for (final workout in history) {
      final matching = workout.exerciseSessions.where(
        (exercise) => exercise.exerciseId == exerciseId,
      );
      for (final exercise in matching) {
        scores.add(
          PerformanceAnalyzer.analyze(
            SignalNormalizer.normalize(
              exerciseSessions: [exercise],
              recovery: null,
            ),
          ),
        );
      }
    }
    return _analyzeScores(scores);
  }

  static TrendAnalysis _analyzeScores(List<double> scores) {
    if (scores.isEmpty) {
      return TrendAnalysis(
        direction: TrendDirection.stable,
        averagePerformance: 80.0,
        averageReadiness: 80.0,
        slope: 0.0,
      );
    }
    final recent = scores.take(5).toList();
    final average = recent.reduce((sum, score) => sum + score) / recent.length;
    if (recent.length < 2) {
      return TrendAnalysis(
        direction: TrendDirection.stable,
        averagePerformance: average,
        averageReadiness: average,
        slope: 0.0,
      );
    }
    final count = recent.length;
    final meanX = (count - 1) / 2;
    double numerator = 0;
    double denominator = 0;
    for (var index = 0; index < count; index++) {
      final xDelta = (count - 1 - index).toDouble() - meanX;
      numerator += xDelta * (recent[index] - average);
      denominator += xDelta * xDelta;
    }
    final slope = denominator == 0 ? 0.0 : numerator / denominator;
    final direction = slope > 4.0
        ? TrendDirection.improving
        : slope < -4.0
        ? TrendDirection.declining
        : TrendDirection.stable;
    return TrendAnalysis(
      direction: direction,
      averagePerformance: average,
      averageReadiness: average,
      slope: slope,
    );
  }
}
