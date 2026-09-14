enum AdaptationType {
  progress,
  maintain,
  regress,
}

class AdaptationResult {
  final AdaptationType type;
  final double readinessScore;   // 0.0 - 100.0
  final double performanceScore; // 0.0 - 100.0
  final double confidence;       // 0.0 - 100.0
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
    required this.recommendedWeight,
    required this.recommendedReps,
    required this.recommendedSets,
    required this.reasons,
    required this.statusTitle,
  });

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
