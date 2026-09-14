import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/navigation/presentation/main_navigation_shell.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/workout/presentation/active_workout_screen.dart';
import '../../features/workout/presentation/difficulty_rating_screen.dart';
import '../../features/workout/presentation/recovery_check_screen.dart';
import '../../features/workout/presentation/workout_summary_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/onboarding',
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingScreen();
      },
    ),
    GoRoute(
      path: '/dashboard',
      builder: (BuildContext context, GoRouterState state) {
        return const MainNavigationShell(initialTab: 0);
      },
    ),
    GoRoute(
      path: '/workout/active',
      builder: (BuildContext context, GoRouterState state) {
        return const ActiveWorkoutScreen();
      },
    ),
    GoRoute(
      path: '/workout/difficulty',
      builder: (BuildContext context, GoRouterState state) {
        return const DifficultyRatingScreen();
      },
    ),
    GoRoute(
      path: '/workout/recovery',
      builder: (BuildContext context, GoRouterState state) {
        return const RecoveryCheckScreen();
      },
    ),
    GoRoute(
      path: '/workout/summary',
      builder: (BuildContext context, GoRouterState state) {
        return const WorkoutSummaryScreen();
      },
    ),
    GoRoute(
      path: '/history',
      builder: (BuildContext context, GoRouterState state) {
        return const MainNavigationShell(initialTab: 2);
      },
    ),
    GoRoute(
      path: '/progress',
      builder: (BuildContext context, GoRouterState state) {
        return const MainNavigationShell(initialTab: 3);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (BuildContext context, GoRouterState state) {
        return const MainNavigationShell(initialTab: 4);
      },
    ),
  ],
);
