import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../provider/adaptive_app_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdaptiveAppProvider>();
    final user = provider.userProfile;
    final isDemo = provider.isDemoMode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Athlete Profile & Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // User Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Sanjo',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${user?.fitnessLevel ?? 'Intermediate'} • ${user?.primaryGoal ?? 'Strength'}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              if (provider.calibration.difficultyRatings.count >=
                                  AppConstants.kCalibrationMinSessions) ...[
                                const SizedBox(height: 4),
                                const Text('Your ratings are now personalized based on your history.', style: TextStyle(color: AppColors.accent, fontSize: 11)),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => context.go('/onboarding'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.cardBorder),
                    const SizedBox(height: 16),
                    // Physical Metrics Grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricTile(
                          'SEX',
                          user?.sex ?? 'Male',
                          Icons.wc_rounded,
                        ),
                        _buildMetricTile(
                          'HEIGHT',
                          '${user?.height.toStringAsFixed(0) ?? '175'} cm',
                          Icons.height_rounded,
                        ),
                        _buildMetricTile(
                          'WEIGHT',
                          '${user?.weight.toStringAsFixed(0) ?? '70'} kg',
                          Icons.monitor_weight_outlined,
                        ),
                        _buildMetricTile(
                          'BMI',
                          '${user?.bmi.toStringAsFixed(1) ?? '22.9'} (${user?.bmiCategory ?? 'Normal'})',
                          Icons.speed_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(),

            if (user != null &&
                user.sex == 'Female' &&
                user.trackMenstrualCycle) ...[
              const SizedBox(height: 24),
              // Menstrual Cycle Tracking Insights Card
              Text(
                'CYCLE & HORMONAL INSIGHTS',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.accent,
                ),
              ).animate().fadeIn(delay: 50.ms),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withAlpha(38),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.water_drop_rounded,
                              color: AppColors.accent,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Phase',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.currentMenstrualPhase ?? 'Not set',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (user.daysUntilNextPeriod != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Text(
                                '${user.daysUntilNextPeriod} days to period',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: AppColors.cardBorder),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCycleDetailItem(
                              'Cycle Length',
                              '${user.cycleLengthDays} days',
                            ),
                          ),
                          Expanded(
                            child: _buildCycleDetailItem(
                              'Period Duration',
                              '${user.periodDurationDays} days',
                            ),
                          ),
                          Expanded(
                            child: _buildCycleDetailItem(
                              'Cycle Day',
                              user.currentCycleDay != null
                                  ? 'Day ${user.currentCycleDay}'
                                  : 'N/A',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms),
            ],

            const SizedBox(height: 24),

            // Judge Demo Mode Settings
            Text(
              'COMPETITION DEMO MODE',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.primary,
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 10),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    value: isDemo,
                    activeTrackColor: AppColors.primary,
                    title: const Text('Activate Demo Data'),
                    subtitle: const Text(
                      'Seeds 3 historical sessions (Regress, Maintain, Progress)',
                    ),
                    onChanged: (val) => provider.toggleDemoMode(val),
                  ),
                  const Divider(height: 1, color: AppColors.cardBorder),
                  ListTile(
                    leading: const Icon(
                      Icons.restart_alt_rounded,
                      color: AppColors.regress,
                    ),
                    title: const Text('Re-seed Demo Sessions'),
                    subtitle: const Text(
                      'Resets adaptive history to initial baseline',
                    ),
                    onTap: () {
                      provider.toggleDemoMode(true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Demo historical sessions re-seeded!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            // System Info Card
            Card(
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 10),
                        Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Version: ${AppConstants.version}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Modular Flutter adaptive engine built for Adaptathon. Domain layer handles Signal Normalization, Performance/Recovery Analysis, Readiness Modeling, and Strategy Generators.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCycleDetailItem(String title, String detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          detail,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
