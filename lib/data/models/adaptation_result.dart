enum AdaptationType { progress, maintain, regress }

class AdaptationResult {
  final AdaptationType type;
  final double readinessScore; // 0.0 - 100.0
  final double performanceScore; // 0.0 - 100.0
  final double confidence; // 0.0 - 100.0
  final double recoveryScore; // 0.0 - 100.0
  final double trendSlope;
  final String trendDirection;
  final bool suggestDeload;

  /// Reference load only. The generator owns the final, exercise-specific load.
  final double recommendedWeight;
  final int recommendedReps;
  final int recommendedSets;
  final List<String> reasons;
  final String statusTitle;

  AdaptationResult({
    required this.type,
    required this.readinessScore,
    required this.performanceScore,
    required this.confidence,
    this.recoveryScore = 0.0,
    this.trendSlope = 0.0,
    this.trendDirection = 'stable',
    this.suggestDeload = false,
    required this.recommendedWeight,
    required this.recommendedReps,
    required this.recommendedSets,
    required this.reasons,
    required this.statusTitle,
  });

  AdaptationResult copyWith({
    AdaptationType? type,
    bool? suggestDeload,
    List<String>? reasons,
    String? statusTitle,
  }) {
    return AdaptationResult(
      type: type ?? this.type,
      readinessScore: readinessScore,
      performanceScore: performanceScore,
      confidence: confidence,
      recoveryScore: recoveryScore,
      trendSlope: trendSlope,
      trendDirection: trendDirection,
      suggestDeload: suggestDeload ?? this.suggestDeload,
      recommendedWeight: recommendedWeight,
      recommendedReps: recommendedReps,
      recommendedSets: recommendedSets,
      reasons: reasons ?? this.reasons,
      statusTitle: statusTitle ?? this.statusTitle,
    );
  }

  String get typeName {
    switch (type) {
      case AdaptationType.progress:
        return 'progress';
      case AdaptationType.maintain:
        return 'maintain';
      case AdaptationType.regress:
        return 'regress';
    }
  }

  static AdaptationType parseType(String str) {
    switch (str.toLowerCase()) {
      case 'progress':
        return AdaptationType.progress;
      case 'regress':
        return AdaptationType.regress;
      case 'maintain':
      default:
        return AdaptationType.maintain;
    }
  }
}
