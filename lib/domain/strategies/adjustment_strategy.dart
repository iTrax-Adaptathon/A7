import '../../data/models/adaptation_result.dart';
import '../analyzers/signal_normalizer.dart';

abstract class AdjustmentStrategy {
  AdaptationResult computeAdjustment({
    required double readinessScore,
    required double performanceScore,
    required double confidence,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
    required List<String> baseFactors,
    required NormalizedSignals signals,
  });
}

class ProgressStrategy implements AdjustmentStrategy {
  @override
  AdaptationResult computeAdjustment({
    required double readinessScore,
    required double performanceScore,
    required double confidence,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
    required List<String> baseFactors,
    required NormalizedSignals signals,
  }) {
    final List<String> reasons = [
      ...baseFactors,
      _repReason(signals.repCompletionRatio),
      _difficultyReason(signals.difficultyFactor),
      _recoveryReason(signals),
      'Next-session load will be adjusted per exercise',
    ];

    return AdaptationResult(
      type: AdaptationType.progress,
      readinessScore: readinessScore,
      performanceScore: performanceScore,
      confidence: confidence,
      recommendedWeight: currentWeight,
      recommendedReps: currentReps,
      recommendedSets: currentSets,
      reasons: reasons,
      statusTitle: '🟢 READY TO PROGRESS',
    );
  }
}

class MaintainStrategy implements AdjustmentStrategy {
  @override
  AdaptationResult computeAdjustment({
    required double readinessScore,
    required double performanceScore,
    required double confidence,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
    required List<String> baseFactors,
    required NormalizedSignals signals,
  }) {
    final List<String> reasons = [
      ...baseFactors,
      _repReason(signals.repCompletionRatio),
      _difficultyReason(signals.difficultyFactor),
      _recoveryReason(signals),
      'Next-session load will retain the current exercise-specific baseline',
    ];

    return AdaptationResult(
      type: AdaptationType.maintain,
      readinessScore: readinessScore,
      performanceScore: performanceScore,
      confidence: confidence,
      recommendedWeight: currentWeight,
      recommendedReps: currentReps,
      recommendedSets: currentSets,
      reasons: reasons,
      statusTitle: '🟡 MAINTAIN CURRENT LOAD',
    );
  }
}

class RegressStrategy implements AdjustmentStrategy {
  @override
  AdaptationResult computeAdjustment({
    required double readinessScore,
    required double performanceScore,
    required double confidence,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
    required List<String> baseFactors,
    required NormalizedSignals signals,
  }) {
    final List<String> reasons = [
      ...baseFactors,
      _repReason(signals.repCompletionRatio),
      _difficultyReason(signals.difficultyFactor),
      _recoveryReason(signals),
      'Next-session load will be reduced per exercise to promote recovery',
    ];

    return AdaptationResult(
      type: AdaptationType.regress,
      readinessScore: readinessScore,
      performanceScore: performanceScore,
      confidence: confidence,
      recommendedWeight: currentWeight,
      recommendedReps: currentReps,
      recommendedSets: currentSets,
      reasons: reasons,
      statusTitle: '🔵 RECOVERY MODE',
    );
  }
}

String _repReason(double ratio) {
  if (ratio >= 1.0) return 'Repetition completion met or exceeded the target';
  if (ratio >= 0.85) return 'Repetition completion was close to the target';
  return 'Repetition completion was below the target';
}

String _difficultyReason(double factor) {
  if (factor >= 0.75) return 'Reported difficulty was manageable';
  if (factor >= 0.45) return 'Reported difficulty was moderate';
  return 'Reported difficulty was high';
}

String _recoveryReason(NormalizedSignals signals) {
  final sleep = signals.sleepFactor;
  final energy = signals.energyFactor;
  final discomfort = signals.discomfortFactor;
  if (sleep >= 0.8 && energy >= 0.8 && discomfort >= 0.8) {
    return 'Sleep, energy, and discomfort signals supported recovery';
  }
  if (sleep < 0.5 || energy < 0.5 || discomfort < 0.5) {
    return 'Recovery signals indicated elevated fatigue or discomfort';
  }
  return 'Recovery signals were mixed';
}
