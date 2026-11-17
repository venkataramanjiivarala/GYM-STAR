import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ExerciseIllustrationWidget extends StatelessWidget {
  final String exerciseKey;
  final String exerciseName;
  final String category;
  final String equipment;
  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final bool isHero;
  final bool showBadge;

  const ExerciseIllustrationWidget({
    super.key,
    required this.exerciseKey,
    required this.exerciseName,
    required this.category,
    this.equipment = 'Bodyweight',
    this.imageUrl,
    this.width = double.infinity,
    this.height = 160,
    this.borderRadius = 18,
    this.isHero = false,
    this.showBadge = true,
  });

  // Dedicated Theme per Muscle Group
  Map<String, dynamic> _getMuscleTheme() {
    switch (category.toLowerCase()) {
      case 'chest':
        return {
          'colors': [const Color(0xFFEF4444), const Color(0xFF991B1B)],
          'accent': const Color(0xFFF87171),
          'icon': Icons.fitness_center_rounded,
          'glyph': 'PECTORALS',
        };
      case 'back':
        return {
          'colors': [const Color(0xFF2563EB), const Color(0xFF1E3A8A)],
          'accent': const Color(0xFF60A5FA),
          'icon': Icons.accessibility_new_rounded,
          'glyph': 'LATS & TRAPS',
        };
      case 'shoulders':
        return {
          'colors': [const Color(0xFFF59E0B), const Color(0xFFB45309)],
          'accent': const Color(0xFFFCD34D),
          'icon': Icons.arrow_upward_rounded,
          'glyph': 'DELTOIDS 3D',
        };
      case 'biceps':
        return {
          'colors': [const Color(0xFF8B5CF6), const Color(0xFF5B21B6)],
          'accent': const Color(0xFFA78BFA),
          'icon': Icons.sports_gymnastics_rounded,
          'glyph': 'BICEPS BRACHII',
        };
      case 'triceps':
        return {
          'colors': [const Color(0xFF06B6D4), const Color(0xFF0E7490)],
          'accent': const Color(0xFF67E8F9),
          'icon': Icons.offline_bolt_rounded,
          'glyph': 'TRICEPS HORSESHOE',
        };
      case 'legs':
        return {
          'colors': [const Color(0xFF10B981), const Color(0xFF065F46)],
          'accent': const Color(0xFF34D399),
          'icon': Icons.directions_walk_rounded,
          'glyph': 'QUADS & GLUTES',
        };
      case 'abs and core':
      case 'core':
        return {
          'colors': [const Color(0xFFF97316), const Color(0xFFC2410C)],
          'accent': const Color(0xFFFB923C),
          'icon': Icons.shield_rounded,
          'glyph': 'CORE STABILITY',
        };
      case 'forearms':
        return {
          'colors': [const Color(0xFF64748B), const Color(0xFF334155)],
          'accent': const Color(0xFF94A3B8),
          'icon': Icons.front_hand_rounded,
          'glyph': 'GRIP & FLEXORS',
        };
      case 'glutes':
        return {
          'colors': [const Color(0xFFEC4899), const Color(0xFF9D174D)],
          'accent': const Color(0xFFF472B6),
          'icon': Icons.adjust_rounded,
          'glyph': 'GLUTEUS MAXIMUS',
        };
      case 'cardio':
        return {
          'colors': [const Color(0xFFE11D48), const Color(0xFF881337)],
          'accent': const Color(0xFFFB7185),
          'icon': Icons.flash_on_rounded,
          'glyph': 'HIGH CADENCE',
        };
      case 'full body':
      default:
        return {
          'colors': [const Color(0xFF7C3AED), const Color(0xFF4C1D95)],
          'accent': const Color(0xFFA78BFA),
          'icon': Icons.sports_kabaddi_rounded,
          'glyph': 'FULL COMPOUND',
        };
    }
  }

  IconData _getEquipmentIcon() {
    final eq = equipment.toLowerCase();
    if (eq.contains('barbell') || eq.contains('ez-bar')) {
      return Icons.line_weight_rounded;
    } else if (eq.contains('dumbbell') || eq.contains('kettlebell')) {
      return Icons.fitness_center_rounded;
    } else if (eq.contains('cable') || eq.contains('pulley')) {
      return Icons.alt_route_rounded;
    } else if (eq.contains('machine') || eq.contains('press')) {
      return Icons.settings_suggest_rounded;
    } else if (eq.contains('bench')) {
      return Icons.weekend_rounded;
    } else if (eq.contains('bar') || eq.contains('pull-up')) {
      return Icons.horizontal_rule_rounded;
    } else if (eq.contains('mat')) {
      return Icons.crop_landscape_rounded;
    }
    return Icons.accessibility_new_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getMuscleTheme();
    final List<Color> gradientColors = theme['colors'] as List<Color>;
    final Color accentColor = theme['accent'] as Color;
    final IconData categoryIcon = theme['icon'] as IconData;
    final String anatomicalGlyph = theme['glyph'] as String;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.borderDark, width: 1),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Procedural Background Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    gradientColors[0].withValues(alpha: 0.35),
                    gradientColors[1].withValues(alpha: 0.75),
                    const Color(0xFF0F172A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Network Image if available with graceful fade and fallback
            if (imageUrl != null && imageUrl!.isNotEmpty)
              Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => _buildProceduralVectorArtwork(
                  accentColor,
                  categoryIcon,
                  anatomicalGlyph,
                ),
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        child,
                        // Subtle darkening scrim for high readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.75),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return _buildProceduralVectorArtwork(
                    accentColor,
                    categoryIcon,
                    anatomicalGlyph,
                  );
                },
              )
            else
              _buildProceduralVectorArtwork(
                accentColor,
                categoryIcon,
                anatomicalGlyph,
              ),

            // Top Badges Row
            if (showBadge)
              Positioned(
                top: 10,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(categoryIcon, size: 12, color: accentColor),
                          const SizedBox(width: 4),
                          Text(
                            category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Equipment Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getEquipmentIcon(), size: 11, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            equipment,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Bottom Title & Anatomical Target Callout (In Hero Mode)
            if (isHero)
              Positioned(
                bottom: 12,
                left: 14,
                right: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      anatomicalGlyph,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      exerciseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.3,
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

  Widget _buildProceduralVectorArtwork(
    Color accentColor,
    IconData categoryIcon,
    String anatomicalGlyph,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isHero ? 64 : 44,
              height: isHero ? 64 : 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.18),
                border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Icon(
                categoryIcon,
                size: isHero ? 32 : 22,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              exerciseName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isHero ? 14 : 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              anatomicalGlyph,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: accentColor.withValues(alpha: 0.8),
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

