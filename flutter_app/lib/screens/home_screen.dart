import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/api_service.dart';
import '../models/analytics_model.dart';
import '../models/user_profile_model.dart';
import '../widgets/stat_card.dart';
import '../widgets/workout_card.dart';
import '../widgets/activity_rings_card.dart';
import '../widgets/exercise_detail_sheet.dart';
import '../models/exercise_model.dart';

class HomeScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(String exerciseKey, bool isYoga) onStartCamera;
  final VoidCallback onOpenCoachChat;
  final VoidCallback onOpenProfile;

  const HomeScreen({
    super.key,
    required this.profile,
    required this.onStartCamera,
    required this.onOpenCoachChat,
    required this.onOpenProfile,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ProgressDashboard _dashboard = ProgressDashboard.emptyDashboard;
  bool _isLoading = true;
  String _selectedMuscleFilter = 'All';

  final List<String> _muscleFilters = [
    'All',
    'Chest',
    'Biceps',
    'Legs',
    'Shoulders',
    'Abs & Core',
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    // Auto-update dashboard when a workout is completed anywhere in app
    ApiService().workoutCompletedNotifier.addListener(_onWorkoutCompleted);
  }

  @override
  void dispose() {
    ApiService().workoutCompletedNotifier.removeListener(_onWorkoutCompleted);
    super.dispose();
  }

  void _onWorkoutCompleted() {
    if (mounted) {
      _loadDashboard();
    }
  }

  Future<void> _loadDashboard() async {
    final data = await ApiService().fetchDashboardAnalytics();
    if (mounted) {
      setState(() {
        _dashboard = data;
        _isLoading = false;
      });
    }
  }

  List<Exercise> _getRecommendedGymExercises() {
    return Exercise.fallbackExercises.where((e) {
      final cat = e.category.toLowerCase();
      // Exclude yoga or non-gym exercises entirely from gym home screen
      if (cat.contains('yoga') || cat.contains('flexibility')) return false;

      if (_selectedMuscleFilter == 'All') return e.isAiSupported;
      if (_selectedMuscleFilter == 'Chest') {
        return cat.contains('chest') || e.primaryMuscles.toLowerCase().contains('chest') || e.primaryMuscles.toLowerCase().contains('pectoral');
      }
      if (_selectedMuscleFilter == 'Biceps') {
        return cat.contains('bicep') || e.primaryMuscles.toLowerCase().contains('bicep') || e.name.toLowerCase().contains('curl');
      }
      if (_selectedMuscleFilter == 'Legs') {
        return cat.contains('leg') || e.primaryMuscles.toLowerCase().contains('quad') || e.primaryMuscles.toLowerCase().contains('glute') || e.name.toLowerCase().contains('squat');
      }
      if (_selectedMuscleFilter == 'Shoulders') {
        return cat.contains('shoulder') || e.primaryMuscles.toLowerCase().contains('deltoid') || e.name.toLowerCase().contains('raise') || e.name.toLowerCase().contains('press');
      }
      if (_selectedMuscleFilter == 'Abs & Core') {
        return cat.contains('abs') || cat.contains('core') || e.primaryMuscles.toLowerCase().contains('core') || e.name.toLowerCase().contains('plank');
      }
      return true;
    }).toList();
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _showExerciseDetail(String key, String name) {
    final ex = Exercise.fallbackExercises.firstWhere(
      (e) => e.key == key,
      orElse: () => Exercise.fallbackExercises.first,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExerciseDetailSheet(
        exercise: ex,
        onStartWorkout: () => widget.onStartCamera(key, false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getTimeGreeting();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'GYM STAR',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: AppColors.primary, size: 18),
            ),
            tooltip: 'AI Fitness Coach',
            onPressed: widget.onOpenCoachChat,
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderDark),
              ),
              child: const Icon(Icons.person_outline_rounded, color: AppColors.textPrimary, size: 18),
            ),
            tooltip: 'Profile & Goals',
            onPressed: widget.onOpenProfile,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onOpenCoachChat,
        backgroundColor: AppColors.primary,
        elevation: 6,
        icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
        label: const Text(
          'Ask AI Coach',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.3),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceDark,
              child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Welcome Card with Gradient & Profile Level
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22.0),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.32),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$greeting, ${widget.profile.name} 👋',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${widget.profile.primaryGoal} Pathway',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            widget.profile.fitnessLevel.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Ready to verify joint angles and master your form with live AI voice feedback today?',
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.35),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: () => widget.onStartCamera('squat', false),
                      icon: const Icon(Icons.play_arrow_rounded, size: 22),
                      label: const Text('Start Daily AI Workout', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Apple Fitness+ Style Concentric Activity Rings Card
              ActivityRingsCard(
                dashboard: _dashboard,
                onStartDailyWorkout: () => widget.onStartCamera('squat', false),
              ),
              const SizedBox(height: 18),

              // Activity Stats Grid
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'STREAK',
                      value: '${_dashboard.streakDays} ${_dashboard.streakDays == 1 ? 'Day' : 'Days'}',
                      subtitle: _dashboard.streakDays > 0 ? 'Consecutive active' : 'Start streak today',
                      color: AppColors.streakOrange,
                      icon: Icons.local_fire_department_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      title: 'FORM ACCURACY',
                      value: _dashboard.avgFormScore > 0 ? '${_dashboard.avgFormScore.toStringAsFixed(1)}%' : '0%',
                      subtitle: _dashboard.avgFormScore > 0 ? 'Biometric score' : 'No sets tracked yet',
                      color: AppColors.accentNeon,
                      icon: Icons.verified_user_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'CALORIES BURNED',
                      value: '${_dashboard.totalCalories.toInt()} kcal',
                      subtitle: 'Energy output',
                      color: AppColors.purple,
                      icon: Icons.bolt_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      title: 'TOTAL REPS',
                      value: '${_dashboard.totalReps}',
                      subtitle: 'Verified gym reps',
                      color: AppColors.primary,
                      icon: Icons.fitness_center_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Weekly Activity Overview (Mini Visualizer)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'WEEKLY ACTIVITY OVERVIEW',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          'Last 7 Days',
                          style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _dashboard.weeklyFormTrend.map((d) {
                        final bool hasActivity = d.reps > 0 || d.calories > 0;
                        return Column(
                          children: [
                            Container(
                              width: 32,
                              height: 54,
                              decoration: BoxDecoration(
                                color: hasActivity
                                    ? AppColors.primary.withValues(alpha: 0.2)
                                    : AppColors.surfaceElevated.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                                border: hasActivity
                                    ? Border.all(color: AppColors.primary.withValues(alpha: 0.5))
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (hasActivity)
                                    Container(
                                      width: 24,
                                      height: (d.reps.clamp(8, 44)).toDouble(),
                                      decoration: BoxDecoration(
                                        gradient: AppColors.primaryGradient,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              d.day,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: hasActivity ? FontWeight.w800 : FontWeight.w500,
                                color: hasActivity ? AppColors.textPrimary : AppColors.textMuted,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recommendations Section — Gym Focus Only
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      "Gym AI Workouts",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: widget.onOpenCoachChat,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'AI Coach Plan →',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Muscle Category Filter Pills for Gym Workouts
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _muscleFilters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, idx) {
                    final filter = _muscleFilters[idx];
                    final isSelected = _selectedMuscleFilter == filter;
                    return ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedMuscleFilter = filter);
                      },
                      labelStyle: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      backgroundColor: AppColors.surfaceElevated,
                      selectedColor: AppColors.primary,
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.borderDark,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // Dynamic Gym Workout Cards
              ..._getRecommendedGymExercises().map((ex) {
                return WorkoutCard(
                  exerciseKey: ex.key,
                  title: ex.name,
                  category: ex.category,
                  primaryMuscles: ex.primaryMuscles,
                  secondaryMuscles: ex.secondaryMuscles,
                  difficulty: ex.difficulty,
                  equipment: ex.equipment,
                  setsAndReps: '${ex.recommendedSets} Sets • ${ex.recommendedReps} Reps',
                  description: ex.instructions.isNotEmpty ? ex.instructions.first : ex.description,
                  imageUrl: ex.imageUrl,
                  isAiSupported: ex.isAiSupported,
                  onViewDetails: () => _showExerciseDetail(ex.key, ex.name),
                  onStartWorkout: () => widget.onStartCamera(ex.key, false),
                );
              }),

              // Recent Gym Workout History
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Gym Workouts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (_dashboard.recentSessions.isNotEmpty)
                    Text(
                      '${_dashboard.recentSessions.length} logged',
                      style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (_dashboard.recentSessions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.fitness_center_rounded, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No Gym Sessions Recorded Yet',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Start a live AI coached workout above to begin recording real reps, joint angles, and calories.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => widget.onStartCamera('squat', false),
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: const Text('Start First Workout', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ..._dashboard.recentSessions.take(5).map((s) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: s.avgFormScore >= 90
                                ? AppColors.accentNeon.withValues(alpha: 0.16)
                                : AppColors.primary.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.fitness_center_rounded,
                            color: s.avgFormScore >= 90 ? AppColors.accentNeon : AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.workoutType,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (s.totalReps > 0) ...[
                                    Text(
                                      '${s.totalReps} Reps',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const Text(' • ', style: TextStyle(color: AppColors.textMuted)),
                                  ],
                                  Text(
                                    '${s.totalDurationSec ~/ 60}m ${s.totalDurationSec % 60}s',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                  const Text(' • ', style: TextStyle(color: AppColors.textMuted)),
                                  Text(
                                    '${s.totalCalories.toInt()} kcal',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                  const Text(' • ', style: TextStyle(color: AppColors.textMuted)),
                                  Text(
                                    s.completedAt,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: s.avgFormScore >= 90
                                ? AppColors.accentNeon.withValues(alpha: 0.14)
                                : AppColors.streakOrange.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: (s.avgFormScore >= 90 ? AppColors.accentNeon : AppColors.streakOrange)
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            '${s.avgFormScore.toInt()}% Form',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: s.avgFormScore >= 90 ? AppColors.accentNeon : AppColors.streakOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
