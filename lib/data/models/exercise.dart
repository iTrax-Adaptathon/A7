class Exercise {
  final String id;
  final String name;
  final String category; // Chest, Back, Shoulders, Legs, Arms
  final int defaultSets;
  final int defaultReps;
  final double defaultWeight;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.defaultSets,
    required this.defaultReps,
    required this.defaultWeight,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'defaultSets': defaultSets,
      'defaultReps': defaultReps,
      'defaultWeight': defaultWeight,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      defaultSets: (json['defaultSets'] as num?)?.toInt() ?? 3,
      defaultReps: (json['defaultReps'] as num?)?.toInt() ?? 8,
      defaultWeight: (json['defaultWeight'] as num?)?.toDouble() ?? 50.0,
    );
  }
}
