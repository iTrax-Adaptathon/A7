import '../../data/models/user_profile.dart';
import '../../data/models/workout_session.dart';
import '../../data/models/plateau_risk_assessment.dart';
import 'recovery_analyzer.dart';
import 'signal_normalizer.dart';
import 'trend_analyzer.dart';

/// An early warning for a likely plateau caused by declining recovery while
/// performance is still being maintained.
class PlateauRiskPredictor {
  /// Checks the latest three sessions for a recovery/performance divergence.
  /// The optional profile keeps recovery scoring aligned with the engine's
  /// existing cycle-aware [RecoveryAnalyzer] calculation.
  static PlateauRiskAssessment assess(
    List<WorkoutSession> history, {
    UserProfile? userProfile,
  }) {
    // Three observations confirm two consecutive recovery drops, rather than
    // treating one unusually difficult session as a trend.
    if (history.length < 3) return PlateauRiskAssessment.noRisk;

    final recent = history.take(3).toList();
    final performanceTrend = TrendAnalyzer.analyze(recent);
    final recoveryScores = recent
        .map(
          (session) => RecoveryAnalyzer.analyze(
            SignalNormalizer.normalize(
              exerciseSessions: session.exerciseSessions,
              recovery: session.recoveryRecord,
            ),
            userProfile: userProfile,
          ),
        )
        .toList();
    final recoverySlope = _leastSquaresSlope(recoveryScores);

    // A 5-point/session decline (about 10 points over three sessions) is
    // intentionally above ordinary day-to-day score variation.
    const minimumRecoveryDecline = 5.0;
    final recoveryDropsConsecutively =
        recoveryScores[0] < recoveryScores[1] &&
        recoveryScores[1] < recoveryScores[2];
    final performanceIsHolding = performanceTrend.slope >= 0;
    final recoveryIsDeclining = recoverySlope <= -minimumRecoveryDecline;

    if (!performanceIsHolding ||
        !recoveryIsDeclining ||
        !recoveryDropsConsecutively) {
      return PlateauRiskAssessment.noRisk;
    }

    // 60 represents a confirmed divergence. The remaining points scale its
    // severity without letting an early warning present as a certainty.
    final recoverySeverity =
        ((-recoverySlope - minimumRecoveryDecline) * 2.5)
            .clamp(0.0, 25.0)
            .toDouble();
    // A 6-point/session gain reaches the 15-point cap: it is strong evidence
    // that performance is being sustained despite worsening recovery.
    final performanceSeverity =
        (performanceTrend.slope * 2.5).clamp(0.0, 15.0).toDouble();
    final riskScore = (60.0 + recoverySeverity + performanceSeverity)
        .clamp(0.0, 100.0)
        .toDouble();

    return PlateauRiskAssessment(
      atRisk: true,
      reason:
          'Performance is holding steady while recovery has dropped for three sessions; a plateau may be close.',
      riskScore: riskScore,
    );
  }

  static double _leastSquaresSlope(List<double> newestFirstScores) {
    final count = newestFirstScores.length;
    final meanX = (count - 1) / 2;
    final meanY =
        newestFirstScores.reduce((sum, score) => sum + score) / count;
    var numerator = 0.0;
    var denominator = 0.0;

    for (var index = 0; index < count; index++) {
      final xDelta = (count - 1 - index).toDouble() - meanX;
      numerator += xDelta * (newestFirstScores[index] - meanY);
      denominator += xDelta * xDelta;
    }
    return denominator == 0 ? 0.0 : numerator / denominator;
  }
}
