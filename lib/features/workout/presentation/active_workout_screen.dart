import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/exercise_session.dart';
import '../../provider/adaptive_app_provider.dart';

class ActiveWorkoutScreen extends StatelessWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdaptiveAppProvider>();
    final activeWorkout = provider.activeWorkout;

    if (activeWorkout == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text("Today's Workout")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fitness_center_rounded,
                size: 64,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 16),
              const Text(
                'No Active Workout Session',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Start a workout from your dashboard to begin logging.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  provider.startNewWorkout();
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('START SESSION NOW'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(activeWorkout.title),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (provider.lastError != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.regress.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.regress),
                ),
                child: Text(
                  provider.lastError!,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: activeWorkout.exerciseSessions.length,
                itemBuilder: (context, index) {
                  final ex = activeWorkout.exerciseSessions[index];
                  return _buildExerciseCard(context, provider, ex)
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: index * 100))
                      .slideY(begin: 0.05, end: 0);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.cardBorder)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/workout/difficulty'),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('PROCEED TO DIFFICULTY RATING'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    AdaptiveAppProvider provider,
    ExerciseSession ex,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ex.exerciseName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Target: ${ex.sets.length} Sets × ${ex.sets.first.targetReps} Reps @ ${ex.sets.first.targetWeight} kg',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.cardBorder),
            const SizedBox(height: 8),

            // Header row
            const Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    'SET',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'WEIGHT (KG)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'REPS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    'DONE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Sets rows
            ...ex.sets.asMap().entries.map((entry) {
              final idx = entry.key;
              final set = entry.value;
              return _buildSetRow(context, provider, ex.exerciseId, idx, set);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(
    BuildContext context,
    AdaptiveAppProvider provider,
    String exerciseId,
    int setIdx,
    dynamic set,
  ) {
    final weightController = TextEditingController(text: '${set.actualWeight}');
    final repsController = TextEditingController(text: '${set.actualReps}');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '#${set.setNumber}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextFormField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
                onChanged: (val) {
                  final w = double.tryParse(val);
                  provider.updateSetRecord(
                    exerciseId,
                    setIdx,
                    w ?? -1,
                    set.actualReps,
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextFormField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
                onChanged: (val) {
                  final r = int.tryParse(val);
                  provider.updateSetRecord(
                    exerciseId,
                    setIdx,
                    set.actualWeight,
                    r ?? -1,
                  );
                },
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Checkbox(
              value: set.completed,
              activeColor: AppColors.progress,
              onChanged: (val) {
                provider.updateSetRecord(
                  exerciseId,
                  setIdx,
                  set.actualWeight,
                  set.actualReps,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
