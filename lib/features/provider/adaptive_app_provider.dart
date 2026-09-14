import 'package:flutter/material.dart';

import '../../data/local/demo_data_seeder.dart';
import '../../data/local/local_storage_service.dart';
import '../../data/models/adaptation_result.dart';
import '../../data/models/exercise_session.dart';
import '../../data/models/recovery_record.dart';
import '../../data/models/set_record.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/workout_session.dart';
import '../../domain/engines/adaptive_engine.dart';
import '../../domain/generators/next_workout_generator.dart';

class AdaptiveAppProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  bool _isInitialized = false;
  bool _isDemoMode = false;
  List<WorkoutSession> _workoutHistory = [];
  WorkoutSession? _activeWorkout;
  AdaptationResult? _latestAdaptation;
  String? _lastError;

  UserProfile? get userProfile => _userProfile;
  bool get isInitialized => _isInitialized;
  bool get hasCompletedOnboarding => _userProfile != null;
  bool get isDemoMode => _isDemoMode;
  List<WorkoutSession> get workoutHistory => _workoutHistory;
  WorkoutSession? get activeWorkout => _activeWorkout;
  AdaptationResult? get latestAdaptation => _latestAdaptation;
  String? get lastError => _lastError;

  double get currentReadinessScore {
    if (_latestAdaptation != null) return _latestAdaptation!.readinessScore;
    if (_workoutHistory.isNotEmpty) return _workoutHistory.first.readinessScore;
    return 78.0; // Default initial readiness
  }

  String get currentStatusTitle {
    if (_latestAdaptation != null) return _latestAdaptation!.statusTitle;
    if (_workoutHistory.isNotEmpty) {
      final type = _workoutHistory.first.adaptationType;
      if (type == 'progress') return '🟢 READY TO PROGRESS';
      if (type == 'regress') return '🔵 RECOVERY MODE';
    }
    return '🟡 MAINTAIN CURRENT LOAD';
  }

  Future<void> initialize() async {
    try {
      _isDemoMode = await LocalStorageService.getDemoMode();
      _userProfile = await LocalStorageService.getUserProfile();

      if (_isDemoMode) {
        _workoutHistory = DemoDataSeeder.getDemoSessions();
      } else {
        _workoutHistory = await LocalStorageService.getWorkoutHistory();
      }
    } catch (error) {
      _lastError = 'Local data could not be loaded. You can continue with a fresh session.';
      _workoutHistory = [];
    }

    _calculateLatestAdaptation();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await LocalStorageService.saveUserProfile(profile);
      _userProfile = profile;
      _lastError = null;
    } catch (error) {
      _lastError = 'Profile was not saved. Please try again.';
    }
    notifyListeners();
  }

  Future<void> toggleDemoMode(bool value) async {
    try {
      await LocalStorageService.saveDemoMode(value);
      _isDemoMode = value;
      if (_isDemoMode) {
        _workoutHistory = DemoDataSeeder.getDemoSessions();
      } else {
        _workoutHistory = await LocalStorageService.getWorkoutHistory();
      }
      _lastError = null;
    } catch (error) {
      _lastError = 'Demo mode could not be changed. Please try again.';
    }
    _calculateLatestAdaptation();
    notifyListeners();
  }

  void startNewWorkout() {
    final nextExercises = NextWorkoutGenerator.generateNextSessionExercises(
      adaptation:
          _latestAdaptation ??
          AdaptationResult(
            type: AdaptationType.maintain,
            readinessScore: 78.0,
            performanceScore: 80.0,
            confidence: 70.0,
            recommendedWeight: 50.0,
            recommendedReps: 8,
            recommendedSets: 3,
            reasons: ['Initial baseline workout'],
            statusTitle: '🟡 MAINTAIN CURRENT LOAD',
          ),
      previousSessions: _workoutHistory.isNotEmpty
          ? _workoutHistory.first.exerciseSessions
          : [],
    );

    _activeWorkout = WorkoutSession(
      id: 'session-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Upper Body Session',
      timestamp: DateTime.now(),
      exerciseSessions: nextExercises,
      performanceScore: 80.0,
      readinessScore: currentReadinessScore,
      adaptationType: 'maintain',
      adaptationExplanation: 'Session in progress',
    );
    notifyListeners();
  }

  bool updateSetRecord(
    String exerciseId,
    int setIndex,
    double actualWeight,
    int actualReps,
  ) {
    if (_activeWorkout == null ||
        !actualWeight.isFinite ||
        actualWeight <= 0 ||
        actualReps <= 0 ||
        actualReps > 100) {
      _lastError = 'Enter a weight greater than 0 kg and 1-100 repetitions.';
      notifyListeners();
      return false;
    }

    final updatedExercises = _activeWorkout!.exerciseSessions.map((ex) {
      if (ex.exerciseId == exerciseId) {
        final updatedSets = List<SetRecord>.from(ex.sets);
        if (setIndex < updatedSets.length) {
          updatedSets[setIndex] = updatedSets[setIndex].copyWith(
            actualWeight: actualWeight,
            actualReps: actualReps,
            completed: true,
          );
        }
        return ExerciseSession(
          exerciseId: ex.exerciseId,
          exerciseName: ex.exerciseName,
          sets: updatedSets,
          difficultyRating: ex.difficultyRating,
        );
      }
      return ex;
    }).toList();

    _activeWorkout = WorkoutSession(
      id: _activeWorkout!.id,
      title: _activeWorkout!.title,
      timestamp: _activeWorkout!.timestamp,
      exerciseSessions: updatedExercises,
      recoveryRecord: _activeWorkout!.recoveryRecord,
      performanceScore: _activeWorkout!.performanceScore,
      readinessScore: _activeWorkout!.readinessScore,
      adaptationType: _activeWorkout!.adaptationType,
      adaptationExplanation: _activeWorkout!.adaptationExplanation,
    );
    _lastError = null;
    notifyListeners();
    return true;
  }

  bool setExerciseDifficulty(String exerciseId, int rating) {
    if (_activeWorkout == null || rating < 1 || rating > 5) {
      _lastError = 'Choose a difficulty rating from 1 to 5.';
      notifyListeners();
      return false;
    }

    final updatedExercises = _activeWorkout!.exerciseSessions.map((ex) {
      if (ex.exerciseId == exerciseId) {
        return ExerciseSession(
          exerciseId: ex.exerciseId,
          exerciseName: ex.exerciseName,
          sets: ex.sets,
          difficultyRating: rating,
        );
      }
      return ex;
    }).toList();

    _activeWorkout = WorkoutSession(
      id: _activeWorkout!.id,
      title: _activeWorkout!.title,
      timestamp: _activeWorkout!.timestamp,
      exerciseSessions: updatedExercises,
      recoveryRecord: _activeWorkout!.recoveryRecord,
      performanceScore: _activeWorkout!.performanceScore,
      readinessScore: _activeWorkout!.readinessScore,
      adaptationType: _activeWorkout!.adaptationType,
      adaptationExplanation: _activeWorkout!.adaptationExplanation,
    );
    _lastError = null;
    notifyListeners();
    return true;
  }

  void submitRecoveryCheck(
    double sleepHours,
    int energyRating,
    String discomfortLevel,
  ) {
    if (_activeWorkout == null) return;

    final recovery = RecoveryRecord(
      sleepHours: sleepHours,
      energyRating: energyRating,
      discomfortLevel: discomfortLevel,
    );

    _activeWorkout = WorkoutSession(
      id: _activeWorkout!.id,
      title: _activeWorkout!.title,
      timestamp: _activeWorkout!.timestamp,
      exerciseSessions: _activeWorkout!.exerciseSessions,
      recoveryRecord: recovery,
      performanceScore: _activeWorkout!.performanceScore,
      readinessScore: _activeWorkout!.readinessScore,
      adaptationType: _activeWorkout!.adaptationType,
      adaptationExplanation: _activeWorkout!.adaptationExplanation,
    );
    notifyListeners();
  }

  Future<WorkoutSession?> finalizeWorkout() async {
    if (_activeWorkout == null) return null;

    // Run Adaptive Engine Domain Processing
    final adaptation = AdaptiveEngine.process(
      exerciseSessions: _activeWorkout!.exerciseSessions,
      recovery: _activeWorkout!.recoveryRecord,
      history: _workoutHistory,
      userProfile: _userProfile,
    );

    final completedSession = WorkoutSession(
      id: _activeWorkout!.id,
      title: _activeWorkout!.title,
      timestamp: DateTime.now(),
      exerciseSessions: _activeWorkout!.exerciseSessions,
      recoveryRecord: _activeWorkout!.recoveryRecord,
      performanceScore: adaptation.performanceScore,
      readinessScore: adaptation.readinessScore,
      adaptationType: adaptation.typeName,
      adaptationExplanation: adaptation.reasons.join('\n• '),
    );

    _workoutHistory.insert(0, completedSession);
    _latestAdaptation = adaptation;
    _activeWorkout = null;

    if (!_isDemoMode) {
      try {
        await LocalStorageService.saveWorkoutHistory(_workoutHistory);
        _lastError = null;
      } catch (error) {
        _lastError = 'Workout completed, but it could not be saved locally.';
      }
    }
    notifyListeners();
    return completedSession;
  }

  void _calculateLatestAdaptation() {
    if (_workoutHistory.isEmpty) {
      _latestAdaptation = AdaptationResult(
        type: AdaptationType.maintain,
        readinessScore: 78.0,
        performanceScore: 80.0,
        confidence: 70.0,
        recommendedWeight: 50.0,
        recommendedReps: 8,
        recommendedSets: 3,
        reasons: [
          'No previous workout data available. Establishing personal baseline.',
        ],
        statusTitle: '🟡 MAINTAIN CURRENT LOAD',
      );
      return;
    }

    final latest = _workoutHistory.first;
    _latestAdaptation = AdaptiveEngine.process(
      exerciseSessions: latest.exerciseSessions,
      recovery: latest.recoveryRecord,
      history: _workoutHistory.skip(1).toList(),
      userProfile: _userProfile,
    );
  }
}
