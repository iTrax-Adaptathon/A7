import '../../data/models/exercise_session.dart';
import '../../data/models/workout_session.dart';
import '../analyzers/trend_analyzer.dart';

class SubstitutionSuggestion {
  final String originalExerciseName;
  final String suggestedExerciseName;
  final String reason;

  const SubstitutionSuggestion({
    required this.originalExerciseName,
    required this.suggestedExerciseName,
    required this.reason,
  });
}

class ExerciseSubstitutionEngine {
  // Seed dataset only: these common alternatives are easy to extend, but are
  // not intended as exhaustive exercise-science or medical guidance.
  static const _substitutions = <String, _SubstitutionDefinition>{
    'bench press': _SubstitutionDefinition(
      substitute: 'Dumbbell Bench Press',
      benefit: 'typically easier to adjust for shoulder comfort',
    ),
    'barbell bench press': _SubstitutionDefinition(
      substitute: 'Dumbbell Bench Press',
      benefit: 'typically easier to adjust for shoulder comfort',
    ),
    'barbell back squat': _SubstitutionDefinition(
      substitute: 'Goblet Squat',
      benefit: 'typically gentler on the knees',
    ),
    'conventional deadlift': _SubstitutionDefinition(
      substitute: 'Trap Bar Deadlift',
      benefit: 'often easier to recover from',
    ),
    'overhead press': _SubstitutionDefinition(
      substitute: 'Landmine Press',
      benefit: 'typically more shoulder-friendly',
    ),
    'barbell overhead press': _SubstitutionDefinition(
      substitute: 'Landmine Press',
      benefit: 'typically more shoulder-friendly',
    ),
  };

  static List<SubstitutionSuggestion> suggest(
    List<ExerciseSession> currentPlan,
    List<WorkoutSession> history,
  ) {
    return currentPlan
        .map((exercise) => _suggestForExercise(exercise, history))
        .whereType<SubstitutionSuggestion>()
        .toList();
  }

  static SubstitutionSuggestion? _suggestForExercise(
    ExerciseSession exercise,
    List<WorkoutSession> history,
  ) {
    final definition = _substitutions[exercise.exerciseName.toLowerCase()];
    if (definition == null) return null;

    final recentSessions = history
        .where(
          (workout) => workout.exerciseSessions.any(
            (loggedExercise) => loggedExercise.exerciseId == exercise.exerciseId,
          ),
        )
        .take(3)
        .toList();
    final repeatedRegression = _hasRepeatedRegression(
      exercise.exerciseId,
      recentSessions,
    );
    final repeatedDiscomfort = _hasRepeatedDiscomfort(recentSessions);

    if (!repeatedRegression && !repeatedDiscomfort) return null;

    final trigger = repeatedRegression && repeatedDiscomfort
        ? 'has regressed in two consecutive sessions with significant discomfort reported during those sessions'
        : repeatedRegression
        ? 'has regressed in two consecutive sessions'
        : 'has significant discomfort reported in two of its last three sessions';
    return SubstitutionSuggestion(
      originalExerciseName: exercise.exerciseName,
      suggestedExerciseName: definition.substitute,
      reason:
          '${exercise.exerciseName} $trigger — try ${definition.substitute}, which is ${definition.benefit}.',
    );
  }

  static bool _hasRepeatedRegression(
    String exerciseId,
    List<WorkoutSession> recentSessions,
  ) {
    // Three appearances create two adjacent comparisons, preventing a single
    // poor session from being mistaken for an exercise-level regression.
    if (recentSessions.length < 3) return false;
    final latestTrend = TrendAnalyzer.analyzeForExercise(
      exerciseId,
      recentSessions.take(2).toList(),
    );
    final previousTrend = TrendAnalyzer.analyzeForExercise(
      exerciseId,
      recentSessions.skip(1).take(2).toList(),
    );
    // Reuses the existing -4 point/session declining threshold so lift-level
    // substitution and next-workout load adjustment agree on "regression".
    return latestTrend.direction == TrendDirection.declining &&
        previousTrend.direction == TrendDirection.declining;
  }

  static bool _hasRepeatedDiscomfort(List<WorkoutSession> recentSessions) {
    // Two reports in three exposures confirm a recurring issue while allowing
    // one isolated discomfort report to resolve without changing the plan.
    return recentSessions
            .where(
              (session) =>
                  session.recoveryRecord?.discomfortLevel == 'Significant',
            )
            .length >=
        2;
  }
}

class _SubstitutionDefinition {
  final String substitute;
  final String benefit;

  const _SubstitutionDefinition({
    required this.substitute,
    required this.benefit,
  });
}
