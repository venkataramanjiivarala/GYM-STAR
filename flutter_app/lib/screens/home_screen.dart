import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/api_service.dart';
import '../models/analytics_model.dart';
import '../models/user_profile_model.dart';
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

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    ApiService().workoutCompletedNotifier.addListener(_onWorkoutCompleted);
  }

  @override
  void dispose() {
    ApiService().workoutCompletedNotifier.removeListener(_onWorkoutCompleted);
    super.dispose();
  }

  void _onWorkoutCompleted() {
    if (mounted) _loadDashboard();
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

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _showExerciseDetail(Exercise ex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExerciseDetailSheet(
        exercise: ex,
        onStartWorkout: () => widget.onStartCamera(ex.key, false),
      ),
    );
  }

  // Compute today's stats from real sessions
  _TodayStats _getTodayStats() {
    int reps = 0;
    double calories = 0;
    int minutes = 0;
    int sessions = 0;
    for (final s in _dashboard.recentSessions) {
      if (s.isToday) {
        reps += s.totalReps;
        calories += s.totalCalories;
        minutes += (s.totalDurationSec ~/ 60);
        sessions++;
      }
    }
    return _TodayStats(
      reps: reps,
      calories: calories,
      minutes: minutes,
      sessions: sessions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getTimeGreeting();
    final today = _getTodayStats();
    final hasActivity = today.sessions > 0;

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
              child: const Icon(Icons.fitness_center_rounded,
                  color: Colors.white, size: 18),
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
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: AppColors.primary, size: 18),
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
              child: const Icon(Icons.person_outline_rounded,
                  color: AppColors.textPrimary, size: 18),
            ),
            tooltip: 'Profile & Goals',
            onPressed: widget.onOpenProfile,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
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
                    // ── Greeting Card ─────────────────────────────────
                    _GreetingCard(
                      greeting: greeting,
                      profile: widget.profile,
                      onStartWorkout: () =>
                          widget.onStartCamera('squat', false),
                    ),
                    const SizedBox(height: 16),

                    // ── Today's Live Stats ─────────────────────────────
                    const _SectionLabel(label: "TODAY'S WORKOUT"),
                    const SizedBox(height: 10),
                    _TodayStatsRow(today: today, hasActivity: hasActivity),
                    const SizedBox(height: 20),

                    // ── Quick Start Exercises ──────────────────────────
                    const _SectionLabel(label: 'QUICK START — AI WORKOUTS'),
                    const SizedBox(height: 10),
                    _QuickStartGrid(onStartCamera: widget.onStartCamera,
                        onViewDetails: _showExerciseDetail),
                    const SizedBox(height: 20),

                    // ── Recent Sessions ────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _SectionLabel(label: 'RECENT SESSIONS'),
                        if (_dashboard.recentSessions.isNotEmpty)
                          Text(
                            '${_dashboard.recentSessions.length} logged',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _RecentSessionsList(sessions: _dashboard.recentSessions,
                        onStartCamera: widget.onStartCamera),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onOpenCoachChat,
        backgroundColor: AppColors.primary,
        elevation: 6,
        icon: const Icon(Icons.chat_bubble_rounded,
            color: Colors.white, size: 20),
        label: const Text('Ask AI Coach',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.3)),
      ),
    );
  }
}

// ─── Today stats data class ───────────────────────────────────────────────────
class _TodayStats {
  final int reps;
  final double calories;
  final int minutes;
  final int sessions;
  const _TodayStats(
      {required this.reps,
      required this.calories,
      required this.minutes,
      required this.sessions});
}

// ─── Greeting Card ────────────────────────────────────────────────────────────
class _GreetingCard extends StatelessWidget {
  final String greeting;
  final UserProfile profile;
  final VoidCallback onStartWorkout;

  const _GreetingCard({
    required this.greeting,
    required this.profile,
    required this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, ${profile.name} 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.primaryGoal,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.80),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: onStartWorkout,
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text('Start AI Workout',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Text(
              profile.fitnessLevel.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: AppColors.textMuted,
      ),
    );
  }
}

// ─── Today Stats Row ──────────────────────────────────────────────────────────
class _TodayStatsRow extends StatelessWidget {
  final _TodayStats today;
  final bool hasActivity;
  const _TodayStatsRow({required this.today, required this.hasActivity});

  @override
  Widget build(BuildContext context) {
    if (!hasActivity) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: const Column(
          children: [
            Icon(Icons.fitness_center_rounded,
                size: 32, color: AppColors.textMuted),
            SizedBox(height: 8),
            Text(
              'No workout recorded today',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            SizedBox(height: 4),
            Text(
              'Start a live AI workout to begin tracking your reps, calories, and form accuracy.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        _StatTile(
          icon: Icons.fitness_center_rounded,
          value: '${today.reps}',
          label: 'Reps',
          color: AppColors.primary,
        ),
        const SizedBox(width: 10),
        _StatTile(
          icon: Icons.local_fire_department_rounded,
          value: '${today.calories.toInt()}',
          label: 'kcal',
          color: AppColors.streakOrange,
        ),
        const SizedBox(width: 10),
        _StatTile(
          icon: Icons.timer_outlined,
          value: '${today.minutes}',
          label: 'min',
          color: AppColors.accentNeon,
        ),
        const SizedBox(width: 10),
        _StatTile(
          icon: Icons.check_circle_rounded,
          value: '${today.sessions}',
          label: today.sessions == 1 ? 'Session' : 'Sessions',
          color: AppColors.violet,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatTile(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Start Grid ─────────────────────────────────────────────────────────
class _QuickStartGrid extends StatelessWidget {
  final Function(String, bool) onStartCamera;
  final Function(Exercise) onViewDetails;

  const _QuickStartGrid(
      {required this.onStartCamera, required this.onViewDetails});

  static const _exercises = [
    {'key': 'squat', 'name': 'Squat', 'icon': Icons.accessibility_new_rounded, 'muscle': 'Legs'},
    {'key': 'pushup', 'name': 'Push-Up', 'icon': Icons.sports_gymnastics_rounded, 'muscle': 'Chest'},
    {'key': 'bicep_curl', 'name': 'Bicep Curl', 'icon': Icons.fitness_center_rounded, 'muscle': 'Biceps'},
    {'key': 'lateral_raise', 'name': 'Lateral Raise', 'icon': Icons.expand_rounded, 'muscle': 'Shoulders'},
    {'key': 'lunge', 'name': 'Lunge', 'icon': Icons.directions_walk_rounded, 'muscle': 'Legs'},
    {'key': 'plank', 'name': 'Plank', 'icon': Icons.horizontal_rule_rounded, 'muscle': 'Core'},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: _exercises.length,
      itemBuilder: (ctx, i) {
        final e = _exercises[i];
        return _QuickExerciseCard(
          exerciseKey: e['key'] as String,
          name: e['name'] as String,
          icon: e['icon'] as IconData,
          muscle: e['muscle'] as String,
          onStart: () => onStartCamera(e['key'] as String, false),
        );
      },
    );
  }
}

class _QuickExerciseCard extends StatelessWidget {
  final String exerciseKey;
  final String name;
  final IconData icon;
  final String muscle;
  final VoidCallback onStart;

  const _QuickExerciseCard({
    required this.exerciseKey,
    required this.name,
    required this.icon,
    required this.muscle,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onStart,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              muscle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent Sessions List ─────────────────────────────────────────────────────
class _RecentSessionsList extends StatelessWidget {
  final List<RecentSession> sessions;
  final Function(String, bool) onStartCamera;

  const _RecentSessionsList(
      {required this.sessions, required this.onStartCamera});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          children: [
            const Icon(Icons.history_rounded,
                size: 32, color: AppColors.textMuted),
            const SizedBox(height: 8),
            const Text(
              'No sessions yet',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Complete your first AI-coached workout and your session history will appear here.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => onStartCamera('squat', false),
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('Start First Workout',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: sessions.take(5).map((s) {
        final isGood = s.avgFormScore >= 85;
        final color = isGood ? AppColors.accentNeon : AppColors.streakOrange;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.fitness_center_rounded,
                    color: color, size: 18),
              ),
              const SizedBox(width: 12),
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
                          fontSize: 14,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 6,
                      children: [
                        if (s.totalReps > 0)
                          _Chip(
                              label: '${s.totalReps} reps',
                              color: AppColors.primary),
                        _Chip(
                            label:
                                '${s.totalDurationSec ~/ 60}m ${s.totalDurationSec % 60}s',
                            color: AppColors.textSecondary),
                        _Chip(
                            label: '${s.totalCalories.toInt()} kcal',
                            color: AppColors.textSecondary),
                        _Chip(
                            label: s.completedAt,
                            color: AppColors.textMuted),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${s.avgFormScore.toInt()}%',
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600, color: color),
    );
  }
}
