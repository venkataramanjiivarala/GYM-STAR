import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'exercise_demonstration_image.dart';

class WorkoutCard extends StatelessWidget {
  final String? exerciseKey;
  final String title;
  final String? subtitle;
  final String category;
  final String primaryMuscles;
  final String secondaryMuscles;
  final String difficulty;
  final String equipment;
  final String setsAndReps;
  final String description;
  final String? imageUrl;
  final bool isAiSupported;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onViewDetails;
  final VoidCallback? onStartWorkout;

  // Legacy/Flexible fallbacks
  final IconData? icon;
  final String? tag;
  final VoidCallback? onTap;
  final VoidCallback? onStart;

  const WorkoutCard({
    super.key,
    this.exerciseKey,
    required this.title,
    this.subtitle,
    this.category = 'General',
    this.primaryMuscles = '',
    this.secondaryMuscles = '',
    this.difficulty = 'Beginner',
    this.equipment = 'Bodyweight',
    this.setsAndReps = '3 Sets • 10-12 Reps',
    this.description = '',
    this.imageUrl,
    this.isAiSupported = false,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.onViewDetails,
    this.onStartWorkout,
    this.icon,
    this.tag,
    this.onTap,
    this.onStart,
  });

  Color _getDifficultyColor() {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppColors.accentNeon;
      case 'intermediate':
        return const Color(0xFF38BDF8); // Sky blue
      case 'advanced':
      default:
        return const Color(0xFFF97316); // Orange
    }
  }

  @override
  Widget build(BuildContext context) {
    final diffColor = _getDifficultyColor();
    final effectiveViewDetails = onViewDetails ?? onTap ?? () {};
    final effectiveStartWorkout = onStartWorkout ?? onStart ?? () {};
    final effectiveKey = exerciseKey ?? title.toLowerCase().replaceAll(' ', '_');
    final effectiveMuscles = primaryMuscles.isNotEmpty
        ? (secondaryMuscles.isNotEmpty ? '$primaryMuscles • $secondaryMuscles' : primaryMuscles)
        : (subtitle ?? category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderDark, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: effectiveViewDetails,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Dedicated Exercise Image / Demonstration Banner
              Stack(
                children: [
                  ExerciseDemonstrationImage(
                    exerciseKey: effectiveKey,
                    exerciseName: title,
                    category: category,
                    equipment: equipment,
                    imageUrl: imageUrl,
                    height: 155,
                    borderRadius: 22,
                    isAiSupported: isAiSupported,
                    showBadges: true,
                  ),

                  // Favorite Button (Top-Right under AI badge or Top-Left)
                  if (onToggleFavorite != null)
                    Positioned(
                      top: 10,
                      left: 12,
                      child: InkWell(
                        onTap: onToggleFavorite,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.70),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 1),
                          ),
                          child: Icon(
                            isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                            size: 16,
                            color: isFavorite ? const Color(0xFFFBBF24) : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // 2. Card Content & Metadata
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise Name & Difficulty
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: diffColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: diffColor.withValues(alpha: 0.4), width: 1),
                          ),
                          child: Text(
                            difficulty,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: diffColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Primary & Secondary Muscles / Subtitle
                    Row(
                      children: [
                        const Icon(Icons.fitness_center_rounded, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            effectiveMuscles,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Sets, Reps & Equipment
                    Row(
                      children: [
                        const Icon(Icons.repeat_rounded, size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          setsAndReps,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('•', style: TextStyle(color: AppColors.textMuted)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            equipment,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          height: 1.35,
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // 9 & 10. View Details & Start Workout Action Buttons
                    Row(
                      children: [
                        // View Details Button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: effectiveViewDetails,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: AppColors.borderDark),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'View Details',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Start Workout Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: effectiveStartWorkout,
                            icon: const Icon(Icons.play_arrow_rounded, size: 18),
                            label: Text(
                              isAiSupported ? 'Start AI' : 'Start',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAiSupported ? AppColors.primary : AppColors.surfaceElevated,
                              foregroundColor: Colors.white,
                              elevation: isAiSupported ? 4 : 0,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
