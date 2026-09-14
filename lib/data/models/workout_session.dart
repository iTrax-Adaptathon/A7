import 'exercise_session.dart';
import 'recovery_record.dart';

class WorkoutSession {
  final String id;
  final String title;
  final DateTime timestamp;
  final List<ExerciseSession> exerciseSessions;
  final RecoveryRecord? recoveryRecord;
  final double performanceScore; // 0 - 100
  final double readinessScore;   // 0 - 100
  final String adaptationType;   // progress, maintain, regress
  final String adaptationExplanation;

  WorkoutSession({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.exerciseSessions,
    this.recoveryRecord,
    required this.performanceScore,
    required this.readinessScore,
    required this.adaptationType,
    required this.adaptationExplanation,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'timestamp': timestamp.toIso8601String(),
      'exerciseSessions': exerciseSessions.map((e) => e.toJson()).toList(),
      'recoveryRecord': recoveryRecord?.toJson(),
      'performanceScore': performanceScore,
      'readinessScore': readinessScore,
      'adaptationType': adaptationType,
      'adaptationExplanation': adaptationExplanation,
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Upper Body Session',
      timestamp: DateTime.parse(json['timestamp'] as String),
      exerciseSessions: (json['exerciseSessions'] as List<dynamic>)
          .map((e) => ExerciseSession.fromJson(e as Map<String, dynamic>))
          .toList(),
      recoveryRecord: json['recoveryRecord'] != null
          ? RecoveryRecord.fromJson(json['recoveryRecord'] as Map<String, dynamic>)
          : null,
      performanceScore: (json['performanceScore'] as num?)?.toDouble() ?? 80.0,
      readinessScore: (json['readinessScore'] as num?)?.toDouble() ?? 78.0,
      adaptationType: json['adaptationType'] as String? ?? 'maintain',
      adaptationExplanation: json['adaptationExplanation'] as String? ?? '',
    );
  }
}
