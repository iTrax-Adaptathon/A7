import '../../data/models/workout_session.dart';

enum TrendDirection {
  improving,
  stable,
  declining,
}

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

    // Compute slope between latest and oldest in recent window
    final double firstPerf = recent.last.performanceScore;
    final double latestPerf = recent.first.performanceScore;
    final double slope = latestPerf - firstPerf;

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
}
