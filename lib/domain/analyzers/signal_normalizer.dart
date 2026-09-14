import '../../data/models/exercise_session.dart';
import '../../data/models/recovery_record.dart';

class NormalizedSignals {
  final double repCompletionRatio; // 0.0 to 1.0
  final double loadComplianceRatio; // 0.0 to 1.0
  final double difficultyFactor;    // 0.0 to 1.0 (higher is better/easier)
  final double sleepFactor;         // 0.0 to 1.0 (8h optimal)
  final double energyFactor;        // 0.0 to 1.0
  final double discomfortFactor;    // 0.0 to 1.0 (1.0 = None, 0.3 = Significant)

  NormalizedSignals({
    required this.repCompletionRatio,
    required this.loadComplianceRatio,
    required this.difficultyFactor,
    required this.sleepFactor,
    required this.energyFactor,
    required this.discomfortFactor,
  });
}

class SignalNormalizer {
  static NormalizedSignals normalize({
    required List<ExerciseSession> exerciseSessions,
    required RecoveryRecord? recovery,
  }) {
    if (exerciseSessions.isEmpty) {
      return NormalizedSignals(
        repCompletionRatio: 0.8,
        loadComplianceRatio: 1.0,
        difficultyFactor: 0.5,
        sleepFactor: 0.8,
        energyFactor: 0.8,
        discomfortFactor: 1.0,
      );
    }

    int totalTargetReps = 0;
    int totalActualReps = 0;
    double totalTargetWeight = 0;
    double totalActualWeight = 0;
    int totalDifficulty = 0;
    int exerciseCount = 0;

    for (final session in exerciseSessions) {
      totalDifficulty += session.difficultyRating;
      exerciseCount++;
      for (final set in session.sets) {
        totalTargetReps += set.targetReps;
        totalActualReps += set.actualReps;
        totalTargetWeight += set.targetWeight;
        totalActualWeight += set.actualWeight;
      }
    }

    final double repRatio = totalTargetReps > 0
        ? (totalActualReps / totalTargetReps).clamp(0.0, 1.2)
        : 1.0;

    final double loadRatio = totalTargetWeight > 0
        ? (totalActualWeight / totalTargetWeight).clamp(0.0, 1.2)
        : 1.0;

    final double avgDifficulty = exerciseCount > 0 ? totalDifficulty / exerciseCount : 3.0;
    // Rating 1 (very easy) -> 1.0, Rating 5 (extremely hard) -> 0.1
    final double diffFactor = ((5.5 - avgDifficulty) / 4.5).clamp(0.1, 1.0);

    // Sleep: 8h optimal (1.0), 4h or less (0.1)
    final double sleepHours = recovery?.sleepHours ?? 7.5;
    final double sleepFact = ((sleepHours - 3.5) / 4.5).clamp(0.1, 1.0);

    // Energy: 1-5 rating -> 0.2 to 1.0
    final int energy = recovery?.energyRating ?? 4;
    final double energyFact = (energy / 5.0).clamp(0.2, 1.0);

    // Discomfort
    double discFact = 1.0;
    final String disc = recovery?.discomfortLevel ?? 'None';
    if (disc == 'Mild') {
      discFact = 0.65;
    } else if (disc == 'Significant') {
      discFact = 0.25;
    }

    return NormalizedSignals(
      repCompletionRatio: repRatio,
      loadComplianceRatio: loadRatio,
      difficultyFactor: diffFactor,
      sleepFactor: sleepFact,
      energyFactor: energyFact,
      discomfortFactor: discFact,
    );
  }
}
