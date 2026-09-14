import '../../data/models/adaptation_result.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_session.dart';
import '../../data/models/set_record.dart';
import '../../data/models/workout_session.dart';
import '../analyzers/trend_analyzer.dart';

class NextWorkoutGenerator {
  static List<Exercise> get defaultExerciseLibrary => [
    // Chest
    Exercise(
      id: 'ex-bench-press',
      name: 'Bench Press',
      category: 'Chest',
      defaultSets: 3,
      defaultReps: 8,
      defaultWeight: 50.0,
    ),
    Exercise(
      id: 'ex-incline-press',
      name: 'Incline Dumbbell Press',
      category: 'Chest',
      defaultSets: 3,
      defaultReps: 10,
      defaultWeight: 22.5,
    ),
    Exercise(
      id: 'ex-cable-fly',
      name: 'Cable Fly',
      category: 'Chest',
      defaultSets: 3,
      defaultReps: 12,
      defaultWeight: 15.0,
    ),
    // Back
    Exercise(
      id: 'ex-lat-pulldown',
      name: 'Lat Pulldown',
      category: 'Back',
      defaultSets: 3,
      defaultReps: 10,
      defaultWeight: 45.0,
    ),
    Exercise(
      id: 'ex-seated-row',
      name: 'Seated Row',
      category: 'Back',
      defaultSets: 3,
      defaultReps: 10,
      defaultWeight: 40.0,
    ),
    Exercise(
      id: 'ex-barbell-row',
      name: 'Barbell Row',
      category: 'Back',
      defaultSets: 3,
      defaultReps: 8,
      defaultWeight: 45.0,
    ),
    // Shoulders
    Exercise(
      id: 'ex-shoulder-press',
      name: 'Shoulder Press',
      category: 'Shoulders',
      defaultSets: 3,
      defaultReps: 8,
      defaultWeight: 15.0,
    ),
    Exercise(
      id: 'ex-lateral-raise',
      name: 'Lateral Raise',
      category: 'Shoulders',
      defaultSets: 3,
      defaultReps: 12,
      defaultWeight: 8.0,
    ),
    // Legs
    Exercise(
      id: 'ex-squat',
      name: 'Squat',
      category: 'Legs',
      defaultSets: 3,
      defaultReps: 8,
      defaultWeight: 60.0,
    ),
    Exercise(
      id: 'ex-leg-press',
      name: 'Leg Press',
      category: 'Legs',
      defaultSets: 3,
      defaultReps: 10,
      defaultWeight: 100.0,
    ),
    Exercise(
      id: 'ex-rdl',
      name: 'Romanian Deadlift',
      category: 'Legs',
      defaultSets: 3,
      defaultReps: 8,
      defaultWeight: 55.0,
    ),
    // Arms
    Exercise(
      id: 'ex-bicep-curl',
      name: 'Bicep Curl',
      category: 'Arms',
      defaultSets: 3,
      defaultReps: 12,
      defaultWeight: 12.5,
    ),
    Exercise(
      id: 'ex-tricep-pushdown',
      name: 'Tricep Pushdown',
      category: 'Arms',
      defaultSets: 3,
      defaultReps: 12,
      defaultWeight: 20.0,
    ),
  ];

  static List<ExerciseSession> generateNextSessionExercises({
    required AdaptationResult adaptation,
    required List<ExerciseSession> previousSessions,
    List<WorkoutSession> history = const [],
  }) {
    if (previousSessions.isEmpty) {
      // Baseline default session
      return [
        _createSession('ex-bench-press', 'Bench Press', 50.0, 8, 3),
        _createSession('ex-lat-pulldown', 'Lat Pulldown', 45.0, 10, 3),
        _createSession('ex-shoulder-press', 'Shoulder Press', 15.0, 8, 3),
      ];
    }

    final List<ExerciseSession> nextSessions = [];

    for (final prevSession in previousSessions) {
      if (prevSession.sets.isEmpty) continue;
      final SetRecord referenceSet = prevSession.sets.first;
      final exerciseAdaptation = _adaptationForExercise(
        adaptation: adaptation,
        exerciseId: prevSession.exerciseId,
        history: history,
      );
      final double targetW = _recommendedWeightForExercise(
        exerciseId: prevSession.exerciseId,
        currentWeight: referenceSet.actualWeight,
        adaptation: exerciseAdaptation,
      );
      final int targetR = exerciseAdaptation.type == AdaptationType.maintain
          ? referenceSet.targetReps
          : exerciseAdaptation.recommendedReps;
      final int targetS = exerciseAdaptation.type == AdaptationType.maintain
          ? prevSession.sets.length
          : exerciseAdaptation.recommendedSets;

      nextSessions.add(
        _createSession(
          prevSession.exerciseId,
          prevSession.exerciseName,
          targetW,
          targetR,
          targetS,
        ),
      );
    }

    return nextSessions;
  }

  static AdaptationResult _adaptationForExercise({
    required AdaptationResult adaptation,
    required String exerciseId,
    required List<WorkoutSession> history,
  }) {
    // Scoped design: readiness/recovery remains session-wide because sleep,
    // energy, and discomfort cannot be meaningfully split by lift. A lift's
    // own trend only confirms whether its load should follow that verdict.
    // No lift history means there is nothing to confirm yet, so preserve the
    // session recommendation during baseline training.
    if (history.isEmpty) return adaptation;
    final trend = TrendAnalyzer.analyzeForExercise(exerciseId, history);
    final agrees =
        adaptation.type == AdaptationType.maintain ||
        (adaptation.type == AdaptationType.progress &&
            trend.direction == TrendDirection.improving) ||
        (adaptation.type == AdaptationType.regress &&
            trend.direction == TrendDirection.declining);
    return agrees
        ? adaptation
        : adaptation.copyWith(type: AdaptationType.maintain);
  }

  static double _recommendedWeightForExercise({
    required String exerciseId,
    required double currentWeight,
    required AdaptationResult adaptation,
  }) {
    // This is the single source of truth for final load magnitude. Strategy
    // results describe direction; this generator applies it per exercise.
    const compoundExercises = {
      'ex-bench-press',
      'ex-squat',
      'ex-rdl',
      'ex-barbell-row',
      'ex-lat-pulldown',
      'ex-shoulder-press',
    };
    final bool isCompound = compoundExercises.contains(exerciseId);
    if (adaptation.suggestDeload) {
      return (currentWeight * 0.80 * 2).roundToDouble() / 2;
    }
    double multiplier = 1.0;
    if (adaptation.type == AdaptationType.progress) {
      multiplier = isCompound ? 1.05 : 1.025;
    } else if (adaptation.type == AdaptationType.regress) {
      multiplier = isCompound ? 0.90 : 0.95;
    }
    return (currentWeight * multiplier * 2).roundToDouble() / 2;
  }

  static ExerciseSession _createSession(
    String id,
    String name,
    double weight,
    int reps,
    int setsCount,
  ) {
    final List<SetRecord> setRecords = [];
    for (int i = 1; i <= setsCount; i++) {
      setRecords.add(
        SetRecord(
          setNumber: i,
          targetWeight: weight,
          actualWeight: weight,
          targetReps: reps,
          actualReps: reps,
          completed: true,
        ),
      );
    }

    return ExerciseSession(
      exerciseId: id,
      exerciseName: name,
      sets: setRecords,
      difficultyRating: 3,
    );
  }
}
