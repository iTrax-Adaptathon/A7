import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../provider/adaptive_app_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdaptiveAppProvider>();
    final user = provider.userProfile;
    final userName = user?.name ?? 'Athlete';
    final readiness = provider.currentReadinessScore;
    final statusTitle = provider.currentStatusTitle;
    final isDemo = provider.isDemoMode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(AppConstants.appName),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Profile Settings',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 72,
            right: -100,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.readinessGlow.withAlpha(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.readinessGlow.withAlpha(30),
                      blurRadius: 90,
                      spreadRadius: 28,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judge Demo Banner
                  _buildDemoBanner(
                    context,
                    provider,
                    isDemo,
                  ).animate().fadeIn().slideY(begin: -0.1, end: 0),

                  const SizedBox(height: 16),

                  // Header Greeting
                  Text(
                    '${_getGreeting()}, $userName',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 4),
                  const Text(
                    'Ready to train? Your adaptive engine is active.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: 24),

                  // Readiness Gauge Card
                  _buildReadinessCard(
                    context,
                    readiness,
                    statusTitle,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0),

                  const SizedBox(height: 20),

                  // Today's Workout Card
                  _buildTodaysWorkoutCard(
                    context,
                    provider,
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05, end: 0),

                  const SizedBox(height: 20),

                  // Adaptive Status Indicator Explanation
                  _buildAdaptiveStatusCard(
                    context,
                    statusTitle,
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoBanner(
    BuildContext context,
    AdaptiveAppProvider provider,
    bool isDemo,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDemo ? AppColors.primary.withAlpha(40) : AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDemo ? AppColors.primary : AppColors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isDemo ? Icons.science_rounded : Icons.tune_rounded,
            color: isDemo ? AppColors.primary : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDemo
                      ? 'COMPETITION DEMO MODE (ACTIVE)'
                      : 'Demo Mode (Judge Testing)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDemo ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  isDemo
                      ? 'Loaded historical session progression for live judging.'
                      : 'Toggle to seed historical sessions demonstrating adaptive transitions.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isDemo,
            activeTrackColor: AppColors.primary,
            onChanged: (val) => provider.toggleDemoMode(val),
          ),
        ],
      ),
    );
  }

  Widget _buildReadinessCard(
    BuildContext context,
    double score,
    String statusTitle,
  ) {
    Color badgeColor = AppColors.maintain;
    if (statusTitle.contains('PROGRESS')) {
      badgeColor = AppColors.progress;
    } else if (statusTitle.contains('RECOVERY')) {
      badgeColor = AppColors.regress;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            // Circular Ring Gauge
            SizedBox(
              width: 84,
              height: 84,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: score / 100.0,
                    strokeWidth: 8,
                    backgroundColor: AppColors.cardBorder,
                    color: badgeColor,
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${score.toInt()}%',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'READY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SYSTEM READINESS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: badgeColor.withAlpha(80)),
                    ),
                    child: Text(
                      statusTitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Generated continuously from load response, recovery & performance trends.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysWorkoutCard(
    BuildContext context,
    AdaptiveAppProvider provider,
  ) {
    final nextExercises = provider.nextWorkoutExercises;
    final substitutions = provider.suggestedSubstitutions;

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "TODAY'S WORKOUT",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Session 08 • Upper Body',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Generated values are exercise-specific, not a shared load.
            ...nextExercises
                .take(3)
                .expand(
                  (exercise) => [
                    _buildExercisePreviewRow(
                      exercise.exerciseName,
                      '${exercise.sets.length} × ${exercise.sets.first.targetReps}',
                      '${exercise.sets.first.targetWeight.toStringAsFixed(1)} kg',
                    ),
                    const Divider(height: 20, color: AppColors.cardBorder),
                  ],
                ),

            if (substitutions.isNotEmpty) ...[
              const SizedBox(height: 4),
              ...substitutions.map(
                (suggestion) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.secondary.withAlpha(120),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.swap_horiz_rounded,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          suggestion.reason,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.ctaGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(80),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  provider.startNewWorkout();
                  context.push('/workout/active');
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('START WORKOUT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisePreviewRow(String name, String setsReps, String load) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.fitness_center_rounded,
            color: AppColors.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                setsReps,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          load,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.progress,
          ),
        ),
      ],
    );
  }

  Widget _buildAdaptiveStatusCard(BuildContext context, String statusTitle) {
    String desc =
        'The user is performing adequately but should maintain load to consolidate strength.';
    if (statusTitle.contains('PROGRESS')) {
      desc =
          'The user is responding exceptionally well to recent training. Adaptive engine has increased training load.';
    } else if (statusTitle.contains('RECOVERY')) {
      desc =
          'Recent performance or recovery signals suggest reducing training stress to prevent fatigue.';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.psychology_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ADAPTIVE ENGINE STATUS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
