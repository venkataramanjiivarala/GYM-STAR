import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/exercise_model.dart';
import 'exercise_illustration_widget.dart';

class ExerciseDetailSheet extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onStartWorkout;

  const ExerciseDetailSheet({
    super.key,
    required this.exercise,
    required this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 1. Large Exercise Demonstration Hero Banner
            ExerciseIllustrationWidget(
              exerciseKey: exercise.key,
              exerciseName: exercise.name,
              category: exercise.category,
              equipment: exercise.equipment,
              imageUrl: exercise.imageUrl,
              height: 175,
              borderRadius: 20,
              isHero: true,
              showBadge: true,
            ),
            const SizedBox(height: 18),

            // 2. Muscles & Difficulty Tag Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target: ${exercise.primaryMuscles}',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      if (exercise.secondaryMuscles.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Secondary: ${exercise.secondaryMuscles}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: exercise.isAiSupported
                        ? const Color(0xFF059669).withValues(alpha: 0.20)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: exercise.isAiSupported
                          ? AppColors.accentNeon.withValues(alpha: 0.6)
                          : AppColors.borderDark,
                    ),
                  ),
                  child: Text(
                    exercise.isAiSupported ? 'AI READY' : exercise.difficulty.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: exercise.isAiSupported ? AppColors.accentNeon : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Quick Specs Grid (Sets, Reps, Duration, Equipment)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _specItem('SETS', exercise.recommendedSets, Icons.repeat_rounded, AppColors.primary),
                  _specDivider(),
                  _specItem('REPS', exercise.recommendedReps, Icons.fitness_center_rounded, AppColors.accentNeon),
                  _specDivider(),
                  _specItem('TIME', exercise.estimatedDuration, Icons.timer_outlined, AppColors.streakOrange),
                  _specDivider(),
                  _specItem('GEAR', exercise.equipment, Icons.handyman_outlined, AppColors.purple),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 4. Starting Position Guide
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.violet.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.violet.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.accessibility_new_rounded, color: AppColors.violet, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Starting Position & Setup',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.violet),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          exercise.startingPosition,
                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 5. Correct Execution & Breathing Guide
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified_rounded, color: AppColors.primary, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Movement Technique & Execution',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.executionTechnique,
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.35),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(Icons.air_rounded, color: Color(0xFF38BDF8), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Breathing Cadence',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF38BDF8)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.breathingTechnique,
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 6. Step-by-Step Instructions
            const Text(
              'Step-by-Step Instructions',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            ...exercise.instructions.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final text = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$idx',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 14),

            // 7. Common Mistakes to Avoid
            if (exercise.commonMistakes.isNotEmpty) ...[
              const Text(
                'Common Biomechanical Mistakes to Avoid',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.warningOrange),
              ),
              const SizedBox(height: 8),
              ...exercise.commonMistakes.map((mistake) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.cancel_rounded, color: AppColors.warningOrange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          mistake,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],

            // 8. Safety Instructions
            if (exercise.safetyInstructions.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.health_and_safety_outlined, color: Color(0xFFF87171), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        exercise.safetyInstructions,
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFFFCA5A5), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 9. Start AI Workout Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onStartWorkout();
                },
                icon: const Icon(Icons.videocam_rounded, color: Colors.white, size: 22),
                label: Text(
                  exercise.isAiSupported ? 'Start AI Workout Coach' : 'Start Workout Session',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _specItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _specDivider() {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.borderDark,
    );
  }
}
