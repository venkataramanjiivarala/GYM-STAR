import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/exercise_image_registry.dart';
import 'exercise_illustration_widget.dart';

/// Dedicated Exercise Demonstration Image Component
/// Ensures every exercise displays an authentic, verified photographic demonstration
/// with graceful fallback to technical biomechanical illustrations.
class ExerciseDemonstrationImage extends StatelessWidget {
  final String exerciseKey;
  final String exerciseName;
  final String category;
  final String equipment;
  final String? imageUrl;
  final double height;
  final double borderRadius;
  final bool isAiSupported;
  final bool showBadges;
  final BoxFit fit;

  const ExerciseDemonstrationImage({
    super.key,
    required this.exerciseKey,
    required this.exerciseName,
    required this.category,
    this.equipment = 'Bodyweight',
    this.imageUrl,
    this.height = 160,
    this.borderRadius = 20,
    this.isAiSupported = false,
    this.showBadges = true,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = (imageUrl != null && imageUrl!.trim().isNotEmpty)
        ? imageUrl!
        : ExerciseImageRegistry.getImage(exerciseKey);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        width: double.infinity,
        color: AppColors.surfaceElevated,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Primary Network Demonstration Photograph
            Image.network(
              effectiveUrl,
              fit: fit,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppColors.surfaceDark,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                // Graceful fallback to rich technical illustration
                return ExerciseIllustrationWidget(
                  exerciseKey: exerciseKey,
                  exerciseName: exerciseName,
                  category: category,
                  equipment: equipment,
                  height: height,
                  borderRadius: borderRadius,
                  showBadge: false,
                );
              },
            ),

            // 2. High-end Vignette / Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.10),
                    Colors.black.withValues(alpha: 0.70),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // 3. Badges (Apparatus & AI Vision)
            if (showBadges) ...[
              // Top-Left Apparatus Badge
              Positioned(
                top: 10,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.fitness_center_rounded, size: 10, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        equipment.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Top-Right AI Support Indicator
              Positioned(
                top: 10,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAiSupported
                        ? const Color(0xFF059669).withValues(alpha: 0.90)
                        : Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isAiSupported
                          ? AppColors.accentNeon.withValues(alpha: 0.8)
                          : Colors.white24,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAiSupported ? AppColors.accentNeon : Colors.white54,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isAiSupported ? 'AI MONITORED' : 'GUIDED',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

