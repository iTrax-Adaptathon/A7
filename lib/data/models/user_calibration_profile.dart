import '../../domain/analyzers/running_stats.dart';

/// Persisted aggregate statistics used to personalize subjective ratings.
/// Individual rating history is intentionally not retained.
class UserCalibrationProfile {
  final RunningStats difficultyRatings;
  final RunningStats energyRatings;

  UserCalibrationProfile({
    RunningStats? difficultyRatings,
    RunningStats? energyRatings,
  }) : difficultyRatings = difficultyRatings ?? RunningStats(),
       energyRatings = energyRatings ?? RunningStats();

  Map<String, dynamic> toJson() => {
    'difficultyRatings': difficultyRatings.toJson(),
    'energyRatings': energyRatings.toJson(),
  };

  factory UserCalibrationProfile.fromJson(Map<String, dynamic>? json) {
    return UserCalibrationProfile(
      difficultyRatings: RunningStats.fromJson(
        json?['difficultyRatings'] as Map<String, dynamic>?,
      ),
      energyRatings: RunningStats.fromJson(
        json?['energyRatings'] as Map<String, dynamic>?,
      ),
    );
  }
}
