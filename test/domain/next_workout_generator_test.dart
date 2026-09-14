import 'package:adaptathon/data/models/adaptation_result.dart';
import 'package:adaptathon/data/models/exercise_session.dart';
import 'package:adaptathon/data/models/set_record.dart';
import 'package:adaptathon/domain/generators/next_workout_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'progression applies a larger load change to compounds than accessories',
    () {
      final next = NextWorkoutGenerator.generateNextSessionExercises(
        adaptation: AdaptationResult(
          type: AdaptationType.progress,
          readinessScore: 85,
          performanceScore: 90,
          confidence: 80,
          recommendedWeight: 0,
          recommendedReps: 8,
          recommendedSets: 3,
          reasons: const [],
          statusTitle: 'Progress',
        ),
        previousSessions: [
          _session('ex-bench-press', 'Bench Press', 100),
          _session('ex-lateral-raise', 'Lateral Raise', 100),
        ],
      );

      expect(next[0].sets.first.targetWeight, 105);
      expect(next[1].sets.first.targetWeight, 102.5);
    },
  );

  test(
    'regression reduces compound load more conservatively than accessories',
    () {
      final next = NextWorkoutGenerator.generateNextSessionExercises(
        adaptation: AdaptationResult(
          type: AdaptationType.regress,
          readinessScore: 45,
          performanceScore: 45,
          confidence: 80,
          recommendedWeight: 0,
          recommendedReps: 8,
          recommendedSets: 3,
          reasons: const [],
          statusTitle: 'Regress',
        ),
        previousSessions: [
          _session('ex-squat', 'Squat', 100),
          _session('ex-bicep-curl', 'Bicep Curl', 100),
        ],
      );

      expect(next[0].sets.first.targetWeight, 90);
      expect(next[1].sets.first.targetWeight, 95);
    },
  );
}

ExerciseSession _session(String id, String name, double weight) =>
    ExerciseSession(
      exerciseId: id,
      exerciseName: name,
      difficultyRating: 3,
      sets: [
        SetRecord(
          setNumber: 1,
          targetWeight: weight,
          actualWeight: weight,
          targetReps: 8,
          actualReps: 8,
          completed: true,
        ),
      ],
    );
