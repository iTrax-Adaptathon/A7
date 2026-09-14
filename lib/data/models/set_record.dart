class SetRecord {
  final int setNumber;
  final double targetWeight;
  final double actualWeight;
  final int targetReps;
  final int actualReps;
  final bool completed;

  SetRecord({
    required this.setNumber,
    required this.targetWeight,
    required this.actualWeight,
    required this.targetReps,
    required this.actualReps,
    required this.completed,
  });

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'targetWeight': targetWeight,
      'actualWeight': actualWeight,
      'targetReps': targetReps,
      'actualReps': actualReps,
      'completed': completed,
    };
  }

  factory SetRecord.fromJson(Map<String, dynamic> json) {
    return SetRecord(
      setNumber: (json['setNumber'] as num).toInt(),
      targetWeight: (json['targetWeight'] as num).toDouble(),
      actualWeight: (json['actualWeight'] as num).toDouble(),
      targetReps: (json['targetReps'] as num).toInt(),
      actualReps: (json['actualReps'] as num).toInt(),
      completed: json['completed'] as bool? ?? true,
    );
  }

  SetRecord copyWith({
    int? setNumber,
    double? targetWeight,
    double? actualWeight,
    int? targetReps,
    int? actualReps,
    bool? completed,
  }) {
    return SetRecord(
      setNumber: setNumber ?? this.setNumber,
      targetWeight: targetWeight ?? this.targetWeight,
      actualWeight: actualWeight ?? this.actualWeight,
      targetReps: targetReps ?? this.targetReps,
      actualReps: actualReps ?? this.actualReps,
      completed: completed ?? this.completed,
    );
  }
}
