import 'package:adaptathon/data/models/exercise_session.dart';
import 'package:adaptathon/data/models/recovery_record.dart';
import 'package:adaptathon/data/models/set_record.dart';
import 'package:adaptathon/data/models/workout_session.dart';
import 'package:adaptathon/domain/analyzers/plateau_risk_predictor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlateauRiskPredictor', () {
    test('flags rising performance with three consecutive recovery drops', () {
      final assessment = PlateauRiskPredictor.assess([
        _session(id: 'newest', performance: 81, sleepHours: 5.0, energy: 2),
        _session(id: 'middle', performance: 80, sleepHours: 6.0, energy: 3),
        _session(id: 'oldest', performance: 78, sleepHours: 7.0, energy: 4),
      ]);

      expect(assessment.atRisk, isTrue);
      expect(assessment.riskScore, greaterThanOrEqualTo(60));
      expect(assessment.reason, isNotEmpty);
    });

    test('does not flag when performance and recovery both decline', () {
      final assessment = PlateauRiskPredictor.assess([
        _session(id: 'newest', performance: 68, sleepHours: 5.0, energy: 2),
        _session(id: 'middle', performance: 73, sleepHours: 6.0, energy: 3),
        _session(id: 'oldest', performance: 78, sleepHours: 7.0, energy: 4),
      ]);

      expect(assessment.atRisk, isFalse);
      expect(assessment.riskScore, 0);
    });

    test('does not flag when fewer than three sessions are available', () {
      final assessment = PlateauRiskPredictor.assess([
        _session(id: 'newest', performance: 81, sleepHours: 5.0, energy: 2),
        _session(id: 'oldest', performance: 78, sleepHours: 7.0, energy: 4),
      ]);

      expect(assessment.atRisk, isFalse);
      expect(assessment.riskScore, 0);
    });
  });
}

WorkoutSession _session({
  required String id,
  required double performance,
  required double sleepHours,
  required int energy,
}) {
  return WorkoutSession(
    id: id,
    title: 'Test session',
    timestamp: DateTime(2026),
    exerciseSessions: [
      ExerciseSession(
        exerciseId: 'squat',
        exerciseName: 'Barbell Back Squat',
        sets: [
          SetRecord(
            setNumber: 1,
            targetWeight: 50,
            targetReps: 8,
            actualWeight: 50,
            actualReps: 8,
            completed: true,
          ),
        ],
        difficultyRating: 3,
      ),
    ],
    recoveryRecord: RecoveryRecord(
      sleepHours: sleepHours,
      energyRating: energy,
      discomfortLevel: 'None',
    ),
    performanceScore: performance,
    readinessScore: 75,
    adaptationType: 'maintain',
    adaptationExplanation: '',
  );
}
