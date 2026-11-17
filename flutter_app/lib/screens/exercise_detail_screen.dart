import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/exercise_model.dart';
import '../widgets/exercise_demonstration_image.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onStartWorkout;
  final bool initialIsFavorite;
  final ValueChanged<bool>? onFavoriteChanged;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    required this.onStartWorkout,
    this.initialIsFavorite = false,
    this.onFavoriteChanged,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    widget.onFavoriteChanged?.call(_isFavorite);
  }

  Color _getDifficultyColor(String diff) {
    switch (diff.toLowerCase()) {
      case 'beginner':
        return AppColors.accentNeon;
      case 'intermediate':
        return const Color(0xFF38BDF8);
      case 'advanced':
      default:
        return const Color(0xFFF97316);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final diffColor = _getDifficultyColor(ex.difficulty);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          ex.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: _isFavorite ? const Color(0xFFFBBF24) : Colors.white70,
              size: 24,
            ),
            onPressed: _toggleFavorite,
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          border: const Border(top: BorderSide(color: AppColors.borderDark, width: 1.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: widget.onStartWorkout,
          icon: const Icon(Icons.videocam_rounded, size: 22),
          label: Text(
            ex.isAiSupported ? 'Start AI Workout Coach' : 'Start Workout Session',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.3),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Large Exercise Demonstration Photograph Banner
            ExerciseDemonstrationImage(
              exerciseKey: ex.key,
              exerciseName: ex.name,
              category: ex.category,
              equipment: ex.equipment,
              imageUrl: ex.imageUrl,
              height: 220,
              borderRadius: 24,
              isAiSupported: ex.isAiSupported,
              showBadges: true,
            ),
            const SizedBox(height: 18),

            // 2. Exercise Title, Difficulty & Category Badges
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ex.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ex.category} • ${ex.equipment}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: diffColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: diffColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    ex.difficulty.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: diffColor,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick Spec Badges Row (Sets, Reps, Calorie Pace, Duration)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _specColumn('TARGET SETS', ex.recommendedSets, Icons.format_list_numbered_rounded),
                  _specDivider(),
                  _specColumn('TARGET REPS', ex.recommendedReps, Icons.repeat_rounded),
                  _specDivider(),
                  _specColumn('EST. DURATION', ex.estimatedDuration, Icons.timer_outlined),
                  _specDivider(),
                  _specColumn('CALORIES', '${ex.caloriesPerRep * 10} kcal/10', Icons.local_fire_department_rounded),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Muscles Activated Section with Visual Diagram Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.accessibility_new_rounded, color: AppColors.accentNeon, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'MUSCLES ACTIVATED',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Primary Target Muscle
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentNeon.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.accentNeon.withValues(alpha: 0.4)),
                        ),
                        child: const Text(
                          'PRIMARY',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.accentNeon),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ex.primaryMuscles.isNotEmpty ? ex.primaryMuscles : ex.targetMuscles,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (ex.secondaryMuscles.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                          ),
                          child: const Text(
                            'SECONDARY',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF38BDF8)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ex.secondaryMuscles,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Technique Breakdown & Execution Guidance
            _guidanceSection(
              title: 'STARTING POSITION',
              icon: Icons.flag_rounded,
              color: const Color(0xFF38BDF8),
              content: ex.startingPosition,
            ),
            const SizedBox(height: 12),

            _guidanceSection(
              title: 'EXECUTION TECHNIQUE',
              icon: Icons.play_circle_outline_rounded,
              color: AppColors.accentNeon,
              content: ex.executionTechnique,
            ),
            const SizedBox(height: 12),

            _guidanceSection(
              title: 'BREATHING CADENCE',
              icon: Icons.air_rounded,
              color: const Color(0xFFA78BFA),
              content: ex.breathingTechnique,
            ),
            const SizedBox(height: 12),

            // Step-by-Step Instructions
            if (ex.instructions.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.format_list_numbered_rounded, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'STEP-BY-STEP INSTRUCTIONS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...ex.instructions.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Common Mistakes (with Orange/Red Warning Styling)
            if (ex.commonMistakes.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF450A0A).withValues(alpha: 0.40),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'COMMON MISTAKES TO AVOID',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: Color(0xFFFCA5A5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...ex.commonMistakes.map((mistake) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('⚠️ ', style: TextStyle(fontSize: 12)),
                            Expanded(
                              child: Text(
                                mistake,
                                style: const TextStyle(fontSize: 12.5, height: 1.35, color: Color(0xFFFECACA)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Safety Guidance
            _guidanceSection(
              title: 'SAFETY & JOINT INTEGRITY',
              icon: Icons.shield_rounded,
              color: const Color(0xFF10B981),
              content: ex.safetyInstructions,
            ),
          ],
        ),
      ),
    );
  }

  Widget _specColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Colors.white),
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

  Widget _guidanceSection({
    required String title,
    required IconData icon,
    required Color color,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

