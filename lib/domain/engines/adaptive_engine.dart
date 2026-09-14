import '../../data/models/user_profile.dart';
import '../../data/models/adaptation_result.dart';
import '../../data/models/exercise_session.dart';
import '../../data/models/recovery_record.dart';
import '../../data/models/workout_session.dart';
import '../analyzers/performance_analyzer.dart';
import '../analyzers/recovery_analyzer.dart';
import '../analyzers/signal_normalizer.dart';
import '../analyzers/trend_analyzer.dart';
import '../engines/readiness_model.dart';
import '../strategies/adjustment_strategy.dart';

class AdaptiveEngine {
  static AdaptationResult process({
    required List<ExerciseSession> exerciseSessions,
    required RecoveryRecord? recovery,
    required List<WorkoutSession> history,
    UserProfile? userProfile,
    double defaultWeight = 50.0,
    int defaultReps = 8,
    int defaultSets = 3,
  }) {
    // 1. Signal Normalization
    final signals = SignalNormalizer.normalize(
      exerciseSessions: exerciseSessions,
      recovery: recovery,
    );

    // 2. Analyzers
    final double perfScore = PerformanceAnalyzer.analyze(signals);
    final double recScore = RecoveryAnalyzer.analyze(
      signals,
      userProfile: userProfile,
    );
    final trend = TrendAnalyzer.analyze(history);

    // 3. Readiness Model
    final readinessEval = ReadinessModel.evaluate(
      performanceScore: perfScore,
      recoveryScore: recScore,
      trend: trend,
      historyCount: history.length,
    );

    // Get primary exercise current load
    double currentWeight = defaultWeight;
    int currentReps = defaultReps;
    int currentSets = defaultSets;

    if (exerciseSessions.isNotEmpty && exerciseSessions.first.sets.isNotEmpty) {
      currentWeight = exerciseSessions.first.sets.first.actualWeight;
      currentReps = exerciseSessions.first.sets.first.targetReps;
      currentSets = exerciseSessions.first.sets.length;
    }

    // 4. Strategy Selection
    final AdaptationType decision = selectAdaptationType(
      readinessScore: readinessEval.readinessScore,
      performanceScore: perfScore,
      recoveryScore: recScore,
      trend: trend,
      historyCount: history.length,
      discomfortLevel: recovery?.discomfortLevel,
    );

    AdjustmentStrategy strategy;
    if (decision == AdaptationType.regress) {
      strategy = RegressStrategy();
    } else if (decision == AdaptationType.progress) {
      strategy = ProgressStrategy();
    } else {
      strategy = MaintainStrategy();
    }

    // 5. Execute Strategy
    return strategy.computeAdjustment(
      readinessScore: readinessEval.readinessScore,
      performanceScore: perfScore,
      confidence: readinessEval.confidence,
      currentWeight: currentWeight,
      currentReps: currentReps,
      currentSets: currentSets,
      baseFactors: readinessEval.factors,
    );
  }

  /// Chooses an adjustment only when the current signal agrees with the
  /// recent direction. Significant discomfort remains a conservative safety
  /// override. With fewer than two historical sessions, there is no trend to
  /// corroborate, so the initial recommendation uses the current baseline.
  static AdaptationType selectAdaptationType({
    required double readinessScore,
    required double performanceScore,
    required double recoveryScore,
    required TrendAnalysis trend,
    required int historyCount,
    String? discomfortLevel,
  }) {
    if (discomfortLevel == 'Significant') return AdaptationType.regress;

    final bool needsTrendConfirmation = historyCount >= 2;
    final bool canProgress =
        readinessScore >= 75.0 &&
        performanceScore >= 75.0 &&
        recoveryScore >= 65.0 &&
        (!needsTrendConfirmation ||
            trend.direction == TrendDirection.improving);
    if (canProgress) return AdaptationType.progress;

    final bool canRegress =
        readinessScore < 55.0 &&
        (!needsTrendConfirmation ||
            trend.direction == TrendDirection.declining);
    if (canRegress) return AdaptationType.regress;

    return AdaptationType.maintain;
  }
}
