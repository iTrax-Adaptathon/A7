# Project Status - ADAPTIVE

## Overall status

**MVP implementation: complete.** The repository contains a Flutter fitness app that records a workout, collects perceived difficulty and recovery inputs, calculates a readiness/adaptation result, and recommends the next session's load. It has not yet been verified locally because the Flutter SDK command is unavailable in this environment.

## Completed functionality

- App bootstrap with Material 3 dark theme, Provider state management, and GoRouter navigation.
- Splash and onboarding flow, including persisted user profiles and optional menstrual-cycle tracking inputs.
- Main navigation with dashboard, history, progress, and profile screens.
- Workout workflow: create a session, enter set weight/repetitions, rate exercise difficulty, enter sleep/energy/discomfort, then view a summary.
- Adaptive domain engine that normalizes workout/recovery signals, calculates performance and recovery scores, assesses short-term trends, derives readiness/confidence, and chooses progress, maintain, or regress strategies.
- Next-session generator with a starter exercise library and adaptive set/rep/load recommendations.
- Local persistence using `shared_preferences` for profile, workout history, and demo-mode preference.
- Seeded demo data covering regress, maintain, and progress scenarios.
- Android, iOS, Windows, macOS, Linux, and web Flutter platform scaffolding.
- One basic widget smoke test.

## Architecture

| Area | Status | Notes |
| --- | --- | --- |
| Presentation | Complete for MVP | Feature screens are organized by flow; shared app theme and router live in `lib/core`. |
| State | Complete for MVP | `AdaptiveAppProvider` owns initialization, active session state, persistence, and engine execution. |
| Domain logic | Complete for MVP | Signal normalizer, performance/recovery/trend analyzers, readiness model, and adjustment strategies are separated under `lib/domain`. |
| Data | Complete for MVP | Typed workout/profile models serialize to local JSON storage. |
| Documentation | Needs work | `README.md` remains the default Flutter starter README. |
| Automated verification | Pending | Test exists, but no local Flutter executable was available to run it. |

## Current limitations / recommended next work

- Install or add Flutter to `PATH`, then run `flutter analyze` and `flutter test`.
- Replace the starter README and package description with product setup, architecture, and run instructions.
- Add unit tests for the adaptive engine, particularly score boundaries and the three adjustment strategies; the current test only checks app rendering.
- Use exercise-specific recommendations: the next-workout generator currently applies one recommended load/reps/sets to every previously performed exercise.
- Add validation/error handling for workout entry and persistence failures.
- The app is local-only: no authentication, cloud sync, backend API, or health-device integration is implemented.
- Treat the readiness logic as an MVP heuristic, not medical or individualized training advice; validate the model before production use.
- Confirm UTF-8 handling for emoji and symbols in UI strings; the current terminal rendering did not display several of them reliably.

## Repository notes

- Last commit: `6c68d45 Init`.
- No uncommitted project changes were present before this status file was created.
- Binary app icons and image assets were inventoried; their source bytes were not interpreted as text.

## Verification record

| Check | Result |
| --- | --- |
| Source/configuration review | Completed |
| Flutter static analysis | Not run - `flutter` command not found |
| Flutter widget tests | Not run - `flutter` command not found |
