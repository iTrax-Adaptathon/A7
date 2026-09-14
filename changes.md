# ADAPTIVE Change Record

## Project foundation

- Created a Flutter fitness-coach MVP with Android, iOS, web, Windows, macOS, and Linux targets.
- Added dark Material 3 styling, centralized app colors, Google Outfit typography, and animated UI elements.
- Added GoRouter navigation and Provider-based application state.
- Added splash, onboarding, dashboard, workout, difficulty-rating, recovery-check, summary, history, progress, and profile screens.

## Workout and data flow

- Added workout models for sessions, exercises, set records, recovery records, user profiles, and adaptation results.
- Added local persistence through `shared_preferences` for profiles, workout history, demo mode, and rating calibration data.
- Added seeded demo sessions representing regress, maintain, and progress scenarios.
- Added input validation for workout weight, repetitions, and difficulty ratings, with provider-level error messages.
- Added handling for local storage read, parse, and write failures so the app can fall back safely rather than crash.

## Adaptive engine

- Added signal normalization for rep completion, load compliance, perceived difficulty, sleep, energy, and discomfort.
- Added performance, recovery, trend, and readiness analyzers.
- Added progress, maintain, and regress strategies.
- Updated strategy reason strings to reflect actual normalized signals instead of static claims.
- Added readiness smoothing against recent readiness history to reduce the effect of a single noisy session.
- Added trend confirmation: ordinary progress/regress recommendations require the relevant recent trend to agree; significant discomfort remains a safety override.
- Replaced the original two-point performance slope with a least-squares regression slope across up to five sessions.
- Added deload detection: three consecutive maintain sessions without readiness improvement suggest a deload, using a 20% next-session load reduction.

## Exercise-specific recommendations

- Made `NextWorkoutGenerator` the single source of truth for final load magnitude.
- Removed misleading flat strategy-layer load values from user-facing recommendations.
- Added distinct compound and accessory adjustments:
  - Progress: compounds +5%, accessories +2.5%.
  - Regress: compounds -10%, accessories -5%.
  - Deload: -20%.
- Added `TrendAnalyzer.analyzeForExercise` so an individual lift’s trend can confirm or veto a session-level progress/regress decision.
- Preserved session-wide readiness and recovery because sleep, energy, and discomfort are session-level signals.
- Updated dashboard and workout summary recommendations to show generated exercise-specific targets.

## Explainability and UI improvements

- Added an expandable engine-breakdown section to the workout summary.
- The breakdown exposes performance score, recovery score, readiness score, confidence, trend direction, and trend slope.
- Added a purple deload suggestion callout to the workout summary.
- Added a profile-screen indicator once enough rating observations exist: “Your ratings are now personalized based on your history.”

## Per-user subjective-rating calibration

- Added `RunningStats`, using Welford’s online algorithm to track count, mean, and standard deviation without storing all historical ratings.
- Added `UserCalibrationProfile` with separate difficulty and energy rating trackers.
- Added persisted calibration storage using `adaptive_user_calibration_profile`.
- Added `AppConstants.kCalibrationMinSessions = 5`; the absolute 1-5 interpretation is retained until enough observations exist.
- Added partial z-score calibration wiring in `SignalNormalizer` and `AdaptiveEngine`:
  - z-scores are clamped to -2 to +2 standard deviations.
  - Personalized factors are blended 50/50 with the existing absolute factors.
  - Calibration is recorded after a completed workout using session-average difficulty and recovery energy.
- Note: the latest calibration wiring requires a final `flutter analyze` and `flutter test` run before it should be treated as verified.

## Tests and verification

- Added domain tests for strategy boundaries, noisy-session handling, missing recovery signals, reason-string accuracy, deload detection, least-squares trend behavior, and per-exercise recommendation confirmation.
- Added tests for compound/accessory loading behavior.
- Added tests for `RunningStats` and calibration-profile JSON persistence.
- Strengthened the original widget smoke test to cover splash-to-onboarding navigation.
- Before the most recent unverified calibration edits, Flutter analysis had no issues and the suite passed 18 tests.

## Documentation

- Replaced the starter README with product overview, architecture, adaptive-logic explanation, setup instructions, test instructions, and MVP scope boundaries.
- Added `status.md` as a project status snapshot.

## Remaining work

- Run final Flutter analysis and tests for the latest calibration changes.
- Add acute:chronic workload-ratio load-spike caution.
- Add readiness and performance line charts on the progress screen.
- Add explicit edit/remove controls for logged workout sets.
- Complete broader UI interactivity and polish work.
- Replace `status.md` with a formal `CHANGELOG.md`.
