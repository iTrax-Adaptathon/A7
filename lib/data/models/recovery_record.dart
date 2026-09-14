class RecoveryRecord {
  final double sleepHours;
  final int energyRating; // 1-5 (Very Low to Excellent)
  final String discomfortLevel; // 'None', 'Mild', 'Significant'

  RecoveryRecord({
    required this.sleepHours,
    required this.energyRating,
    required this.discomfortLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'sleepHours': sleepHours,
      'energyRating': energyRating,
      'discomfortLevel': discomfortLevel,
    };
  }

  factory RecoveryRecord.fromJson(Map<String, dynamic> json) {
    return RecoveryRecord(
      sleepHours: (json['sleepHours'] as num?)?.toDouble() ?? 7.5,
      energyRating: (json['energyRating'] as num?)?.toInt() ?? 4,
      discomfortLevel: json['discomfortLevel'] as String? ?? 'None',
    );
  }
}
