import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../provider/adaptive_app_provider.dart';

class RecoveryCheckScreen extends StatefulWidget {
  const RecoveryCheckScreen({super.key});

  @override
  State<RecoveryCheckScreen> createState() => _RecoveryCheckScreenState();
}

class _RecoveryCheckScreenState extends State<RecoveryCheckScreen> {
  double _sleepHours = 7.5;
  int _energyRating = 4; // Normal to High
  String _discomfortLevel = 'None';

  bool _isProcessing = false;

  Future<void> _submit() async {
    setState(() => _isProcessing = true);
    final provider = context.read<AdaptiveAppProvider>();

    provider.submitRecoveryCheck(_sleepHours, _energyRating, _discomfortLevel);
    await provider.finalizeWorkout();

    if (mounted) {
      context.go('/workout/summary');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Post-Workout Recovery Check'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recovery & Fatigue Signals',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(),

              const SizedBox(height: 6),
              const Text(
                'Sleep, energy, and discomfort inputs refine the adaptive readiness model.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 28),

              // Sleep Hours Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.bedtime_rounded, color: AppColors.primary),
                              SizedBox(width: 10),
                              Text('Hours Slept Last Night', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                          Text(
                            '${_sleepHours.toStringAsFixed(1)} h',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.progress),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: _sleepHours,
                        min: 3.0,
                        max: 12.0,
                        divisions: 18,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => _sleepHours = val),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 18),

              // Energy Rating Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: AppColors.maintain),
                          SizedBox(width: 10),
                          Text('Perceived Energy Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [1, 2, 3, 4, 5].map((level) {
                          final isSelected = _energyRating == level;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Text('$level'),
                                selected: isSelected,
                                onSelected: (_) => setState(() => _energyRating = level),
                                selectedColor: AppColors.maintain,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                backgroundColor: AppColors.surface,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 18),

              // Discomfort Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.healing_rounded, color: AppColors.regress),
                          SizedBox(width: 10),
                          Text('Joint / Muscle Discomfort', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Training signal for load management (not medical advice).',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: ['None', 'Mild', 'Significant'].map((disc) {
                          final isSelected = _discomfortLevel == disc;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Text(disc, textAlign: TextAlign.center),
                                selected: isSelected,
                                onSelected: (_) => setState(() => _discomfortLevel = disc),
                                selectedColor: disc == 'Significant' ? AppColors.regress : AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                                backgroundColor: AppColors.surface,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _submit,
                  icon: _isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.auto_awesome_rounded),
                  label: Text(_isProcessing ? 'RUNNING ADAPTIVE ENGINE...' : 'RUN ADAPTIVE ENGINE'),
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
