import 'package:adaptathon/data/models/user_calibration_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calibration profile preserves both rating trackers in JSON', () {
    final profile = UserCalibrationProfile();
    profile.difficultyRatings.update(4);
    profile.difficultyRatings.update(5);
    profile.energyRatings.update(2);
    profile.energyRatings.update(3);

    final restored = UserCalibrationProfile.fromJson(profile.toJson());

    expect(restored.difficultyRatings.count, 2);
    expect(restored.difficultyRatings.mean, 4.5);
    expect(restored.energyRatings.count, 2);
    expect(restored.energyRatings.mean, 2.5);
  });
}
