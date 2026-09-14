import 'package:adaptathon/domain/analyzers/running_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Welford running statistics match a known sequence', () {
    final stats = RunningStats();
    for (final value in [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0]) {
      stats.update(value);
    }

    expect(stats.count, 8);
    expect(stats.mean, closeTo(5.0, 0.0001));
    expect(stats.stdDev, closeTo(2.1381, 0.0001));

    final restored = RunningStats.fromJson(stats.toJson());
    expect(restored.mean, closeTo(stats.mean, 0.0001));
    expect(restored.stdDev, closeTo(stats.stdDev, 0.0001));
  });
}
