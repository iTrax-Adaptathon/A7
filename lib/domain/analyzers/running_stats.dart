import 'dart:math' as math;

/// Incremental mean and sample standard deviation using Welford's algorithm.
/// This keeps only aggregate state, so subjective-rating history need not be
/// stored individually for calibration.
class RunningStats {
  int _count;
  double _mean;
  double _m2;

  RunningStats({
    int initialCount = 0,
    double initialMean = 0.0,
    double initialM2 = 0.0,
  }) : _count = initialCount,
       _mean = initialMean,
       _m2 = initialM2;

  int get count => _count;
  double get mean => _mean;

  /// Sample standard deviation. A neutral 1.0 prevents division by zero
  /// before enough observations exist to estimate a personal spread.
  double get stdDev => _count < 2 ? 1.0 : math.sqrt(_m2 / (_count - 1));

  void update(double value) {
    _count++;
    final delta = value - _mean;
    _mean += delta / _count;
    final deltaAfterMean = value - _mean;
    _m2 += delta * deltaAfterMean;
  }

  Map<String, dynamic> toJson() => {'count': _count, 'mean': _mean, 'm2': _m2};

  factory RunningStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RunningStats();
    return RunningStats(
      initialCount: (json['count'] as num?)?.toInt() ?? 0,
      initialMean: (json['mean'] as num?)?.toDouble() ?? 0.0,
      initialM2: (json['m2'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
