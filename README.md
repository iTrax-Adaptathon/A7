# ADAPTIVE Fitness Coach

ADAPTIVE is a local-first Flutter MVP that records workout performance and
self-reported recovery, then suggests whether the next workout should progress,
maintain, or reduce load. It is a training aid, not medical advice or an
individualized training prescription.

## What it does

- Logs set weight and repetitions, plus perceived difficulty.
- Captures post-workout sleep, energy, and discomfort signals.
- Scores performance and recovery, assesses a recent trend, and generates a
  readiness score and confidence level.
- Recommends a next session with exercise-specific compound/accessory load
  adjustments.
- Saves profiles, history, and demo-mode preference on the device using
  `shared_preferences`.

## Architecture

| Layer | Location | Responsibility |
| --- | --- | --- |
| Presentation | `lib/features` | Onboarding, dashboard, workout, history, progress, and profile screens. |
| State | `lib/features/provider` | `AdaptiveAppProvider` coordinates initialization, active workouts, persistence, and engine execution. |
| Domain | `lib/domain` | Signal normalization, performance/recovery/trend analysis, readiness evaluation, and adjustment strategies. |
| Data | `lib/data` | Typed models, local storage service, and seeded demo data. |
| Core | `lib/core` | Theme, router, and app constants. |

## How adaptation works

Performance is based on rep completion (50%), load compliance (30%), and
manageable difficulty (20%). Recovery is based on sleep (40%), subjective
energy (30%), and discomfort (30%), with an optional menstrual-cycle modifier.

Readiness starts from performance (40%), recovery (35%), and a five-session
performance trend (25%). After at least two prior sessions, the current score is
blended 60/40 with the recent readiness baseline. This reduces the impact of a
single unusually good or bad session.

The app progresses only when readiness, performance, and recovery meet the
required levels *and* the recent trend is improving. It regresses below the
readiness threshold only when the trend is declining. Significant discomfort is
a conservative safety override. Otherwise it maintains the current workload.
Confidence grows from 50 to 95 as workout history accumulates.

For the next session, compound exercises receive a larger load adjustment than
accessory exercises: +5%/-10% for compounds and +2.5%/-5% for accessories.
Loads are rounded to the nearest 0.5 kg.

## Setup and run

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) and
   ensure `flutter` is on your `PATH`.
2. From the repository root, run:

   ```powershell
   flutter pub get
   flutter analyze
   flutter test
   flutter run
   ```

Use a connected device or an enabled desktop/web target for `flutter run`.

## Scope boundaries

The following are intentionally outside this MVP:

- Authentication and accounts
- Cloud synchronization or backend APIs
- Health-device integrations

## Testing

Domain tests cover adaptation boundaries, conflicting and missing recovery
signals, outlier-versus-trend behavior, and exercise-specific next-workout
recommendations. The existing widget smoke test remains in `test/widget_test.dart`.
