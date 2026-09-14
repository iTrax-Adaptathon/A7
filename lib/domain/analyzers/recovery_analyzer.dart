import '../../data/models/user_profile.dart';
import 'signal_normalizer.dart';

class RecoveryAnalyzer {
  /// Returns recovery score from 0.0 to 100.0
  static double analyze(NormalizedSignals signals, {UserProfile? userProfile}) {
    // Base Weight factors:
    // Sleep: 40%
    // Subjective Energy: 30%
    // Discomfort Penalty: 30%
    final double sleepPart = signals.sleepFactor * 40.0;
    final double energyPart = signals.energyFactor * 30.0;
    final double discomfortPart = signals.discomfortFactor * 30.0;

    double total = sleepPart + energyPart + discomfortPart;

    // Backend Menstrual Cycle Adaptation Modifier
    if (userProfile != null &&
        userProfile.sex == 'Female' &&
        userProfile.trackMenstrualCycle) {
      final phase = userProfile.currentMenstrualPhase;
      if (phase != null) {
        if (phase.contains('Menstrual')) {
          // Moderate fatigue mitigation (-12% readiness)
          total *= 0.88;
        } else if (phase.contains('Follicular')) {
          // Peak strength building (+8% readiness bonus)
          total *= 1.08;
        } else if (phase.contains('Ovulatory')) {
          // Maximum neuromuscular power (+10% readiness bonus)
          total *= 1.10;
        } else if (phase.contains('Luteal')) {
          // Increased core temperature & fatigue sensitivity (-8% readiness)
          total *= 0.92;
        }
      }
    }

    return total.clamp(0.0, 100.0);
  }
}
