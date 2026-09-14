import 'set_record.dart';

class ExerciseSession {
  final String exerciseId;
  final String exerciseName;
  final List<SetRecord> sets;
  final int difficultyRating; // 1-5 (Very Easy to Extremely Hard)

  ExerciseSession({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.difficultyRating,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'sets': sets.map((s) => s.toJson()).toList(),
      'difficultyRating': difficultyRating,
    };
  }

  factory ExerciseSession.fromJson(Map<String, dynamic> json) {
    return ExerciseSession(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      sets: (json['sets'] as List<dynamic>)
          .map((s) => SetRecord.fromJson(s as Map<String, dynamic>))
          .toList(),
      difficultyRating: (json['difficultyRating'] as num?)?.toInt() ?? 3,
    );
  }
}
