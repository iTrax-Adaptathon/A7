import 'package:adaptathon/data/models/adaptation_result.dart';
import 'package:adaptathon/data/models/exercise_session.dart';
import 'package:adaptathon/data/models/recovery_record.dart';
import 'package:adaptathon/data/models/set_record.dart';
import 'package:adaptathon/data/models/workout_session.dart';
import 'package:adaptathon/domain/analyzers/trend_analyzer.dart';
import 'package:adaptathon/domain/analyzers/signal_normalizer.dart';
import 'package:adaptathon/domain/engines/adaptive_engine.dart';
import 'package:adaptathon/domain/strategies/adjustment_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final stableTrend = TrendAnalysis(
    direction: TrendDirection.stable,
    averagePerformance: 80,
    averageReadiness: 80,
    slope: 0,
  );
  final improvingTrend = TrendAnalysis(
    direction: TrendDirection.improving,
    averagePerformance: 85,
    averageReadiness: 84,
    slope: 6,
  );
  final decliningTrend = TrendAnalysis(
    direction: TrendDirection.declining,
    averagePerformance: 55,
    averageReadiness: 54,
    slope: -8,
  );

  group('AdaptiveEngine strategy boundaries', () {
    test('progress starts at the exact readiness threshold', () {
      expect(
        AdaptiveEngine.selectAdaptationType(
          readinessScore: 75,
          performanceScore: 75,
          recoveryScore: 65,
          trend: improvingTrend,
          historyCount: 2,
        ),
        AdaptationType.progress,
      );
      expect(
        AdaptiveEngine.selectAdaptationType(
          readinessScore: 74.99,
          performanceScore: 100,
          recoveryScore: 100,
          trend: improvingTrend,
          historyCount: 2,
        ),
        AdaptationType.maintain,
      );
    });

    test('regression is below, not at, the readiness threshold', () {
      expect(
        AdaptiveEngine.selectAdaptationType(
          readinessScore: 55,
          performanceScore: 20,
          recoveryScore: 20,
          trend: decliningTrend,
          historyCount: 2,
        ),
        AdaptationType.maintain,
      );
      expect(
        AdaptiveEngine.selectAdaptationType(
          readinessScore: 54.99,
          performanceScore: 20,
          recoveryScore: 20,
          trend: decliningTrend,
          historyCount: 2,
        ),
        AdaptationType.regress,
      );
    });

    test('a noisy current outlier cannot override a stable history', () {
      expect(
        AdaptiveEngine.selectAdaptationType(
          readinessScore: 45,
          performanceScore: 40,
          recoveryScore: 30,
          trend: stableTrend,
          historyCount: 3,
        ),
        AdaptationType.maintain,
      );
      expect(
        AdaptiveEngine.selectAdaptationType(
          readinessScore: 90,
          performanceScore: 95,
          recoveryScore: 90,
          trend: stableTrend,
          historyCount: 3,
        ),
        AdaptationType.maintain,
      );
    });

    test('sustained direction enables the matching adjustment', () {
      expect(
        AdaptiveEngine.selectAdaptationType(
          readinessScore: 80,
          performanceScore: 85,
          recoveryScore: 80,
          trend: improvingTrend,
          historyCount: 3,
        ),
        AdaptationType.progress,
      );
      expect(
        AdaptiveEngine.selectAdaptationType(
          readinessScore: 50,
          performanceScore: 45,
          recoveryScore: 45,
          trend: decliningTrend,
          historyCount: 3,
        ),
        AdaptationType.regress,
      );
    });

    test('significant discomfort remains a safety override', () {
      expect(
        AdaptiveEngine.selectAdaptationType(
          readinessScore: 90,
          performanceScore: 95,
          recoveryScore: 90,
          trend: improvingTrend,
          historyCount: 3,
          discomfortLevel: 'Significant',
        ),
        AdaptationType.regress,
      );
    });
  });

  group('AdaptiveEngine signals', () {
    test('least-squares trend treats zigzag performance as stable', () {
      final history = [80.0, 60.0, 80.0, 60.0, 80.0]
          .asMap()
          .entries
          .map(
            (entry) => WorkoutSession(
              id: 'zigzag-${entry.key}',
              title: 'Zigzag',
              timestamp: DateTime(2026, 1, entry.key + 1),
              exerciseSessions: [_exercise(actualReps: 8, difficulty: 3)],
              performanceScore: entry.value,
              readinessScore: 70,
              adaptationType: 'maintain',
              adaptationExplanation: '',
            ),
          )
          .toList();

      final trend = TrendAnalyzer.analyze(history);

      expect(trend.slope, closeTo(0, 0.01));
      expect(trend.direction, TrendDirection.stable);
    });

    test('strategy reasons describe mediocre recovery honestly', () {
      final result = ProgressStrategy().computeAdjustment(
        readinessScore: 80,
        performanceScore: 85,
        confidence: 60,
        currentWeight: 50,
        currentReps: 8,
        currentSets: 3,
        baseFactors: const [],
        signals: NormalizedSignals(
          repCompletionRatio: 1,
          loadComplianceRatio: 1,
          difficultyFactor: 0.5,
          sleepFactor: 0.6,
          energyFactor: 0.6,
          discomfortFactor: 1,
        ),
      );

      expect(result.reasons, contains('Reported difficulty was moderate'));
      expect(result.reasons, contains('Recovery signals were mixed'));
      expect(result.reasons.join(' '), isNot(contains('optimal')));
    });

    test(
      'strong performance with poor recovery does not automatically progress',
      () {
        final result = AdaptiveEngine.process(
          exerciseSessions: [_exercise(actualReps: 10, difficulty: 1)],
          recovery: RecoveryRecord(
            sleepHours: 3.0,
            energyRating: 1,
            discomfortLevel: 'Mild',
          ),
          history: [],
        );
        expect(result.type, isNot(AdaptationType.progress));
      },
    );

    test(
      'missing recovery uses documented neutral defaults without crashing',
      () {
        final result = AdaptiveEngine.process(
          exerciseSessions: [_exercise(actualReps: 8, difficulty: 3)],
          recovery: null,
          history: [],
        );
        expect(result.readinessScore, inInclusiveRange(0, 100));
        expect(result.confidence, 50);
      },
    );

    test('readiness is smoothed against a multi-session baseline', () {
      final history = List.generate(3, (index) => _historySession(index));
      final result = AdaptiveEngine.process(
        exerciseSessions: [_exercise(actualReps: 0, difficulty: 5)],
        recovery: RecoveryRecord(
          sleepHours: 3,
          energyRating: 1,
          discomfortLevel: 'Mild',
        ),
        history: history,
      );
      expect(result.readinessScore, greaterThan(45));
      expect(result.type, AdaptationType.maintain);
    });
  });
}

ExerciseSession _exercise({required int actualReps, required int difficulty}) {
  return ExerciseSession(
    exerciseId: 'ex-bench-press',
    exerciseName: 'Bench Press',
    difficultyRating: difficulty,
    sets: [
      SetRecord(
        setNumber: 1,
        targetWeight: 50,
        actualWeight: 50,
        targetReps: 8,
        actualReps: actualReps,
        completed: true,
      ),
    ],
  );
}

WorkoutSession _historySession(int index) => WorkoutSession(
  id: 'history-$index',
  title: 'History',
  timestamp: DateTime(2026, 1, index + 1),
  exerciseSessions: [_exercise(actualReps: 8, difficulty: 3)],
  performanceScore: 80,
  readinessScore: 80,
  adaptationType: 'maintain',
  adaptationExplanation: '',
);
