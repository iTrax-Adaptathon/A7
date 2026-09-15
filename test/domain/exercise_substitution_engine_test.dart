import 'package:adaptathon/data/models/exercise_session.dart';
import 'package:adaptathon/data/models/recovery_record.dart';
import 'package:adaptathon/data/models/set_record.dart';
import 'package:adaptathon/data/models/workout_session.dart';
import 'package:adaptathon/domain/engines/exercise_substitution_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const plan = [
    ExerciseSession(
      exerciseId: 'ex-bench-press',
      exerciseName: 'Bench Press',
      sets: [],
      difficultyRating: 3,
    ),
  ];

  group('ExerciseSubstitutionEngine', () {
    test('suggests a mapped exercise after two consecutive regressions', () {
      final suggestions = ExerciseSubstitutionEngine.suggest(plan, [
        _workout(id: 'newest', actualReps: 2),
        _workout(id: 'middle', actualReps: 5),
        _workout(id: 'oldest', actualReps: 8),
      ]);

      expect(suggestions, hasLength(1));
      expect(suggestions.single.originalExerciseName, 'Bench Press');
      expect(suggestions.single.suggestedExerciseName, 'Dumbbell Bench Press');
    });

    test('does not suggest a substitute after only one regression', () {
      final suggestions = ExerciseSubstitutionEngine.suggest(plan, [
        _workout(id: 'newest', actualReps: 5),
        _workout(id: 'oldest', actualReps: 8),
      ]);

      expect(suggestions, isEmpty);
    });

    test('does not suggest an exercise absent from the seed map', () {
      const unmappedPlan = [
        ExerciseSession(
          exerciseId: 'ex-lat-pulldown',
          exerciseName: 'Lat Pulldown',
          sets: [],
          difficultyRating: 3,
        ),
      ];

      final suggestions = ExerciseSubstitutionEngine.suggest(
        unmappedPlan,
        [
          _workout(
            id: 'newest',
            actualReps: 2,
            exerciseId: 'ex-lat-pulldown',
            exerciseName: 'Lat Pulldown',
          ),
          _workout(
            id: 'middle',
            actualReps: 5,
            exerciseId: 'ex-lat-pulldown',
            exerciseName: 'Lat Pulldown',
          ),
          _workout(
            id: 'oldest',
            actualReps: 8,
            exerciseId: 'ex-lat-pulldown',
            exerciseName: 'Lat Pulldown',
          ),
        ],
      );

      expect(suggestions, isEmpty);
    });

    test('does not suggest a substitute without enough exercise history', () {
      final suggestions = ExerciseSubstitutionEngine.suggest(plan, [
        _workout(id: 'only', actualReps: 2),
      ]);

      expect(suggestions, isEmpty);
    });
  });
}

WorkoutSession _workout({
  required String id,
  required int actualReps,
  String exerciseId = 'ex-bench-press',
  String exerciseName = 'Bench Press',
}) {
  return WorkoutSession(
    id: id,
    title: 'Test session',
    timestamp: DateTime(2026),
    exerciseSessions: [
      ExerciseSession(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        sets: [
          SetRecord(
            setNumber: 1,
            targetWeight: 50,
            actualWeight: 50,
            targetReps: 8,
            actualReps: actualReps,
            completed: true,
          ),
        ],
        difficultyRating: 3,
      ),
    ],
    recoveryRecord: RecoveryRecord(
      sleepHours: 7.5,
      energyRating: 4,
      discomfortLevel: 'None',
    ),
    performanceScore: 75,
    readinessScore: 75,
    adaptationType: 'maintain',
    adaptationExplanation: '',
  );
}
