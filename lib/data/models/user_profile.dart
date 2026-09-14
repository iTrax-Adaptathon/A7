class UserProfile {
  final String name;
  final int age;
  final String sex; // 'Male' or 'Female'
  final double height; // in cm
  final double weight; // in kg
  final String fitnessLevel; // Beginner, Intermediate, Advanced
  final String primaryGoal;  // Strength, Muscle Gain, General Fitness
  final String frequency;    // 3 days/week, 4 days/week, 5 days/week
  
  // Menstrual Cycle Tracking (Optional, for female athletes)
  final bool trackMenstrualCycle;
  final int cycleLengthDays; // Default 28
  final int periodDurationDays; // Default 5
  final DateTime? lastPeriodStartDate;

  UserProfile({
    required this.name,
    required this.age,
    this.sex = 'Male',
    this.height = 175.0,
    this.weight = 70.0,
    required this.fitnessLevel,
    required this.primaryGoal,
    required this.frequency,
    this.trackMenstrualCycle = false,
    this.cycleLengthDays = 28,
    this.periodDurationDays = 5,
    this.lastPeriodStartDate,
  });

  double get bmi => (height > 0) ? weight / ((height / 100) * (height / 100)) : 0.0;

  String get bmiCategory {
    final b = bmi;
    if (b < 18.5) return 'Underweight';
    if (b < 25.0) return 'Normal weight';
    if (b < 30.0) return 'Overweight';
    return 'Obese';
  }

  int? get currentCycleDay {
    if (sex != 'Female' || !trackMenstrualCycle || lastPeriodStartDate == null) return null;
    final diff = DateTime.now().difference(lastPeriodStartDate!).inDays;
    if (diff < 0) return 1;
    return (diff % cycleLengthDays) + 1;
  }

  String? get currentMenstrualPhase {
    final day = currentCycleDay;
    if (day == null) return null;

    if (day <= periodDurationDays) {
      return 'Menstrual Phase 🩸';
    } else if (day <= (cycleLengthDays ~/ 2) - 2) {
      return 'Follicular Phase 🌿';
    } else if (day <= (cycleLengthDays ~/ 2) + 2) {
      return 'Ovulatory Phase ⚡';
    } else {
      return 'Luteal Phase 🌙';
    }
  }

  int? get daysUntilNextPeriod {
    final day = currentCycleDay;
    if (day == null) return null;
    return cycleLengthDays - day + 1;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'sex': sex,
      'height': height,
      'weight': weight,
      'fitnessLevel': fitnessLevel,
      'primaryGoal': primaryGoal,
      'frequency': frequency,
      'trackMenstrualCycle': trackMenstrualCycle,
      'cycleLengthDays': cycleLengthDays,
      'periodDurationDays': periodDurationDays,
      'lastPeriodStartDate': lastPeriodStartDate?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? 'User',
      age: json['age'] as int? ?? 24,
      sex: json['sex'] as String? ?? 'Male',
      height: (json['height'] as num?)?.toDouble() ?? 175.0,
      weight: (json['weight'] as num?)?.toDouble() ?? 70.0,
      fitnessLevel: json['fitnessLevel'] as String? ?? 'Intermediate',
      primaryGoal: json['primaryGoal'] as String? ?? 'Strength',
      frequency: json['frequency'] as String? ?? '4 days/week',
      trackMenstrualCycle: json['trackMenstrualCycle'] as bool? ?? false,
      cycleLengthDays: json['cycleLengthDays'] as int? ?? 28,
      periodDurationDays: json['periodDurationDays'] as int? ?? 5,
      lastPeriodStartDate: json['lastPeriodStartDate'] != null
          ? DateTime.tryParse(json['lastPeriodStartDate'] as String)
          : null,
    );
  }
}

