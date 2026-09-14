import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../provider/adaptive_app_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdaptiveAppProvider>();
    final history = provider.workoutHistory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Performance & Visualizations'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Training Progress Analytics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(),

              const SizedBox(height: 6),
              const Text(
                'Long-term trends generated from objective workout logs.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 24),

              // Overview Metric Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricBox(
                      'TOTAL SESSIONS',
                      '${history.length}',
                      Icons.fitness_center_rounded,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricBox(
                      'AVG READINESS',
                      '${provider.currentReadinessScore.toInt()}%',
                      Icons.bolt_rounded,
                      AppColors.progress,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 20),

              // Weight Progression Visual Chart Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('BENCH PRESS LOAD TREND', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                          Text('Last 5 Sessions', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 140,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: _buildBarChartItems(history),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05, end: 0),

              const SizedBox(height: 20),

              // Recovery & Energy Consistency Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('RECOVERY & HYGIENE INDEX', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 12),
                      _buildProgressBar('Average Sleep Quality (7.8h optimal)', 0.85, AppColors.progress),
                      const SizedBox(height: 12),
                      _buildProgressBar('Energy Consistency', 0.75, AppColors.maintain),
                      const SizedBox(height: 12),
                      _buildProgressBar('Low Discomfort Score', 0.90, AppColors.primary),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricBox(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  List<Widget> _buildBarChartItems(List<dynamic> history) {
    if (history.isEmpty) {
      return [
        _buildSingleBar('S1', 45.0, 50.0, AppColors.maintain),
        _buildSingleBar('S2', 45.0, 50.0, AppColors.maintain),
        _buildSingleBar('S3', 50.0, 50.0, AppColors.progress),
      ];
    }

    final items = history.take(5).toList().reversed.toList();
    return items.map((s) {
      final double weight = (s.exerciseSessions.isNotEmpty && s.exerciseSessions.first.sets.isNotEmpty)
          ? s.exerciseSessions.first.sets.first.actualWeight
          : 50.0;
      Color col = AppColors.maintain;
      if (s.adaptationType == 'progress') col = AppColors.progress;
      if (s.adaptationType == 'regress') col = AppColors.regress;

      return _buildSingleBar('S${s.id.substring(s.id.length - 1)}', weight, 60.0, col);
    }).toList();
  }

  Widget _buildSingleBar(String label, double val, double maxVal, Color color) {
    final heightRatio = (val / maxVal).clamp(0.2, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('${val.toInt()}kg', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Container(
          width: 32,
          height: 90 * heightRatio,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildProgressBar(String title, double pct, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text('${(pct * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: pct,
          backgroundColor: AppColors.cardBorder,
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
