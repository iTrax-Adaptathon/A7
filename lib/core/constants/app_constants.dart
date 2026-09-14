class AppConstants {
  static const String appName = 'ADAPTIVE';
  static const String tagline = 'Your workout changes with you.';
  static const String version = 'v1.0.0 (MVP)';

  // Storage Keys
  static const String prefUserProfile = 'adaptive_user_profile';
  static const String prefWorkoutHistory = 'adaptive_workout_history';
  static const String prefDemoMode = 'adaptive_demo_mode';
  static const String prefUserCalibration = 'adaptive_user_calibration_profile';

  /// Five sessions provide enough observations for a tentative personal
  /// baseline; below this, the absolute 1-5 scale is more trustworthy.
  static const int kCalibrationMinSessions = 5;

  // Exercise Categories
  static const List<String> muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Legs',
    'Arms',
  ];
}
