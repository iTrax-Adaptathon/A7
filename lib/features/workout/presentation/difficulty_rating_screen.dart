import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../provider/adaptive_app_provider.dart';

class DifficultyRatingScreen extends StatefulWidget {
  const DifficultyRatingScreen({super.key});

  @override
  State<DifficultyRatingScreen> createState() => _DifficultyRatingScreenState();
}

class _DifficultyRatingScreenState extends State<DifficultyRatingScreen> {
  int _selectedRating = 3; // Default Moderate

  final List<Map<String, dynamic>> _options = [
    {'rating': 1, 'label': '1 — Very Easy', 'desc': 'Light load, felt like warmup', 'color': AppColors.progress},
    {'rating': 2, 'label': '2 — Easy', 'desc': 'Controlled, 3+ reps left in tank', 'color': AppColors.progress},
    {'rating': 3, 'label': '3 — Moderate', 'desc': 'Challenging but clean form', 'color': AppColors.maintain},
    {'rating': 4, 'label': '4 — Hard', 'desc': 'Near max effort, 1 rep left', 'color': AppColors.maintain},
    {'rating': 5, 'label': '5 — Extremely Hard', 'desc': 'Total muscle failure / strain', 'color': AppColors.regress},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdaptiveAppProvider>();
    final activeWorkout = provider.activeWorkout;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Subjective Effort Rating'),
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
                'How did that feel?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(),

              const SizedBox(height: 6),
              const Text(
                'Rate the overall physical effort of your primary exercise session.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 28),

              ..._options.map((opt) {
                final rating = opt['rating'] as int;
                final isSelected = _selectedRating == rating;
                final color = opt['color'] as Color;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      setState(() => _selectedRating = rating);
                      if (activeWorkout != null) {
                        for (final ex in activeWorkout.exerciseSessions) {
                          provider.setExerciseDifficulty(ex.exerciseId, rating);
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withAlpha(25) : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? color : AppColors.cardBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? color : AppColors.surface,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$rating',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opt['label'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? color : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  opt['desc'] as String,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded, color: color),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 150 + (rating * 50)));
              }),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/workout/recovery'),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('PROCEED TO RECOVERY CHECK'),
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
