import '../models/exercise_session.dart';
import '../models/recovery_record.dart';
import '../models/set_record.dart';
import '../models/workout_session.dart';

class DemoDataSeeder {
  static List<WorkoutSession> getDemoSessions() {
    final now = DateTime.now();

    // Session 1 (5 days ago) - High Fatigue / Regress Scenario
    final s1 = WorkoutSession(
      id: 'demo-session-1',
      title: 'Upper Body Strength',
      timestamp: now.subtract(const Duration(days: 5)),
      performanceScore: 58.0,
      readinessScore: 52.0,
      adaptationType: 'regress',
      adaptationExplanation: 'Reduced rep completion and low sleep hours (4.0h) signaled elevated fatigue.',
      recoveryRecord: RecoveryRecord(
        sleepHours: 4.0,
        energyRating: 2,
        discomfortLevel: 'Mild',
      ),
      exerciseSessions: [
        ExerciseSession(
          exerciseId: 'ex-bench-press',
          exerciseName: 'Bench Press',
          difficultyRating: 5,
          sets: [
            SetRecord(
              setNumber: 1,
              targetWeight: 50.0,
              actualWeight: 50.0,
              targetReps: 8,
              actualReps: 8,
              completed: true,
            ),
            SetRecord(
              setNumber: 2,
              targetWeight: 50.0,
              actualWeight: 50.0,
              targetReps: 8,
              actualReps: 6,
              completed: false,
            ),
            SetRecord(
              setNumber: 3,
              targetWeight: 50.0,
              actualWeight: 50.0,
              targetReps: 8,
              actualReps: 5,
              completed: false,
            ),
          ],
        ),
      ],
    );

    // Session 2 (3 days ago) - Regress Implemented / Consolidation / Maintain Scenario
    final s2 = WorkoutSession(
      id: 'demo-session-2',
      title: 'Upper Body Deload',
      timestamp: now.subtract(const Duration(days: 3)),
      performanceScore: 74.0,
      readinessScore: 68.0,
      adaptationType: 'maintain',
      adaptationExplanation: 'Load reduced to 45kg to allow recovery; set targets completed adequately.',
      recoveryRecord: RecoveryRecord(
        sleepHours: 6.5,
        energyRating: 3,
        discomfortLevel: 'None',
      ),
      exerciseSessions: [
        ExerciseSession(
          exerciseId: 'ex-bench-press',
          exerciseName: 'Bench Press',
          difficultyRating: 3,
          sets: [
            SetRecord(
              setNumber: 1,
              targetWeight: 45.0,
              actualWeight: 45.0,
              targetReps: 8,
              actualReps: 8,
              completed: true,
            ),
            SetRecord(
              setNumber: 2,
              targetWeight: 45.0,
              actualWeight: 45.0,
              targetReps: 8,
              actualReps: 8,
              completed: true,
            ),
            SetRecord(
              setNumber: 3,
              targetWeight: 45.0,
              actualWeight: 45.0,
              targetReps: 8,
              actualReps: 8,
              completed: true,
            ),
          ],
        ),
      ],
    );

    // Session 3 (1 day ago) - High Recovery & Optimal Reps / Progress Scenario
    final s3 = WorkoutSession(
      id: 'demo-session-3',
      title: 'Upper Body Hypertrophy',
      timestamp: now.subtract(const Duration(days: 1)),
      performanceScore: 92.0,
      readinessScore: 84.0,
      adaptationType: 'progress',
      adaptationExplanation:
          'Exceeded rep targets, optimal 8.0h sleep, low difficulty rating.',
      recoveryRecord: RecoveryRecord(
        sleepHours: 8.0,
        energyRating: 5,
        discomfortLevel: 'None',
      ),
      exerciseSessions: [
        ExerciseSession(
          exerciseId: 'ex-bench-press',
          exerciseName: 'Bench Press',
          difficultyRating: 2,
          sets: [
            SetRecord(
              setNumber: 1,
              targetWeight: 45.0,
              actualWeight: 45.0,
              targetReps: 8,
              actualReps: 8,
              completed: true,
            ),
            SetRecord(
              setNumber: 2,
              targetWeight: 45.0,
              actualWeight: 45.0,
              targetReps: 8,
              actualReps: 8,
              completed: true,
            ),
            SetRecord(
              setNumber: 3,
              targetWeight: 45.0,
              actualWeight: 45.0,
              targetReps: 8,
              actualReps: 9,
              completed: true,
            ),
          ],
        ),
      ],
    );

    return [s3, s2, s1]; // newest first
  }
}
