import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/api_service.dart';
import '../models/analytics_model.dart';
import '../models/user_profile_model.dart';
import '../widgets/stat_card.dart';
import '../widgets/workout_card.dart';
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
  ProgressDashboard _dashboard = ProgressDashboard.defaultDashboard;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() async {
    final data = await ApiService().fetchDashboardAnalytics();
    if (mounted) {
      setState(() {
        _dashboard = data;
      });
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🏋️ ', style: TextStyle(fontSize: 22)),
            Text(
              'GYM STAR',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_outlined, color: AppColors.primary, size: 20),
            ),
            tooltip: 'AI Coach Chat',
            onPressed: widget.onOpenCoachChat,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.textPrimary),
            tooltip: 'Athlete Profile',
            onPressed: widget.onOpenProfile,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onOpenCoachChat,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: const Text('Ask AI Coach', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadDashboard(),
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceDark,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22.0),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hello, ${widget.profile.name} 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.profile.fitnessLevel,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ready to master joint accuracy with AI voice posture feedback today?',
                      style: TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.3),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: () => widget.onStartCamera('squat', false),
                      icon: const Icon(Icons.play_arrow_rounded, size: 22),
                      label: const Text('Start Daily AI Workout', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'STREAK',
                      value: '${_dashboard.streakDays} Days',
                      subtitle: 'Daily active',
                      color: AppColors.warningOrange,
                      icon: Icons.local_fire_department,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      title: 'FORM SCORE',
                      value: '${_dashboard.avgFormScore.toStringAsFixed(1)}%',
                      subtitle: 'AI Biometrics',
                      color: AppColors.accentNeon,
                      icon: Icons.verified_user_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      title: 'CALORIES',
                      value: '${_dashboard.totalCalories.toInt()}',
                      subtitle: 'kcal burned',
                      color: AppColors.primary,
                      icon: Icons.bolt,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recommendations Header
              const Text(
                "Today's AI Recommendations",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              WorkoutCard(
                title: 'Bodyweight Squat Blast',
                subtitle: 'Legs & Core • Real-Time Knee Angle Tracker',
                icon: Icons.fitness_center,
                tag: 'High Form Focus',
                onTap: () => _showExerciseDetail('squat', 'Bodyweight Squat'),
                onStart: () => widget.onStartCamera('squat', false),
              ),

              WorkoutCard(
                title: 'Tree Pose Balance & Stability',
                subtitle: '15 min • Yoga • Postural Hold Focus',
                icon: Icons.self_improvement,
                tag: 'Yoga Flow',
                onTap: () => widget.onStartCamera('tree_pose', true),
                onStart: () => widget.onStartCamera('tree_pose', true),
              ),

              WorkoutCard(
                title: 'Classic Push-Up Depth Mastery',
                subtitle: 'Chest & Triceps • 90° Elbow Flare Guard',
                icon: Icons.sports_gymnastics,
                tag: 'Strength',
                onTap: () => _showExerciseDetail('pushup', 'Classic Push-Up'),
                onStart: () => widget.onStartCamera('pushup', false),
              ),

              WorkoutCard(
                title: 'Warrior II Stamina Hold',
                subtitle: '30 min • Strength & Hip Openness',
                icon: Icons.spa,
                tag: 'Balance',
                onTap: () => widget.onStartCamera('warrior_2', true),
                onStart: () => widget.onStartCamera('warrior_2', true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
