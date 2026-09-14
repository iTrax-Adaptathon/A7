import '../../data/models/adaptation_result.dart';

abstract class AdjustmentStrategy {
  AdaptationResult computeAdjustment({
    required double readinessScore,
    required double performanceScore,
    required double confidence,
    required double currentWeight,
    required int currentReps,
    required int currentSets,
    required List<String> baseFactors,
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
  }) {
    final double recommendedWeight = currentWeight + 2.5;
    final List<String> reasons = [
      ...baseFactors,
      '✓ Repetition completion exceeded target',
      '✓ Subjective difficulty remained manageable',
      '✓ Sleep and recovery ratings are optimal',
      'System increased load by +2.5 kg for next session',
    ];

    return AdaptationResult(
      type: AdaptationType.progress,
      readinessScore: readinessScore,
      performanceScore: performanceScore,
      confidence: confidence,
      recommendedWeight: recommendedWeight,
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
  }) {
    final List<String> reasons = [
      ...baseFactors,
      '✓ Completed target workload adequately',
      '✓ Moderate difficulty rating reported',
      '✓ Normal recovery state',
      'System maintained current load ($currentWeight kg) to consolidate strength',
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
  }) {
    final double recommendedWeight = (currentWeight * 0.9).clamp(5.0, 300.0);
    final List<String> reasons = [
      ...baseFactors,
      '⚠️ Repetition completion was below target',
      '⚠️ High difficulty or elevated fatigue signals detected',
      '⚠️ Reduced recovery/sleep hours reported',
      'System reduced load to ${recommendedWeight.toStringAsFixed(1)} kg to promote recovery',
    ];

    return AdaptationResult(
      type: AdaptationType.regress,
      readinessScore: readinessScore,
      performanceScore: performanceScore,
      confidence: confidence,
      recommendedWeight: recommendedWeight,
      recommendedReps: currentReps,
      recommendedSets: currentSets,
      reasons: reasons,
      statusTitle: '🔵 RECOVERY MODE',
    );
  }
}
