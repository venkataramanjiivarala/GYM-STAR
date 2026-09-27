class DailyTrend {
  final String day;
  final double formScore;
  final int reps;
  final double calories;

  DailyTrend({
    required this.day,
    required this.formScore,
    required this.reps,
    required this.calories,
  });

  factory DailyTrend.fromJson(Map<String, dynamic> json) {
    return DailyTrend(
      day: json['day'] ?? '',
      formScore: (json['form_score'] as num?)?.toDouble() ?? 90.0,
      reps: json['reps'] ?? 0,
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RecentSession {
  final int id;
  final String workoutType;
  final int totalDurationSec;
  final double totalCalories;
  final double avgFormScore;
  final String completedAt;

  RecentSession({
    required this.id,
    required this.workoutType,
    required this.totalDurationSec,
    required this.totalCalories,
    required this.avgFormScore,
    required this.completedAt,
  });

  factory RecentSession.fromJson(Map<String, dynamic> json) {
    return RecentSession(
      id: json['id'] ?? 0,
      workoutType: json['workout_type'] ?? 'Workout',
      totalDurationSec: json['total_duration_sec'] ?? 0,
      totalCalories: (json['total_calories'] as num?)?.toDouble() ?? 0.0,
      avgFormScore: (json['avg_form_score'] as num?)?.toDouble() ?? 90.0,
      completedAt: json['completed_at'] ?? 'Today',
    );
  }
}

class ProgressDashboard {
  final int totalWorkouts;
  final int totalReps;
  final double totalCalories;
  final double avgFormScore;
  final int streakDays;
  final List<DailyTrend> weeklyFormTrend;
  final List<RecentSession> recentSessions;

  ProgressDashboard({
    required this.totalWorkouts,
    required this.totalReps,
    required this.totalCalories,
    required this.avgFormScore,
    required this.streakDays,
    required this.weeklyFormTrend,
    required this.recentSessions,
  });

  factory ProgressDashboard.fromJson(Map<String, dynamic> json) {
    return ProgressDashboard(
      totalWorkouts: json['total_workouts'] ?? 14,
      totalReps: json['total_reps'] ?? 397,
      totalCalories: (json['total_calories'] as num?)?.toDouble() ?? 1850.0,
      avgFormScore: (json['avg_form_score'] as num?)?.toDouble() ?? 92.5,
      streakDays: json['streak_days'] ?? 7,
      weeklyFormTrend: json['weekly_form_trend'] != null
          ? (json['weekly_form_trend'] as List)
              .map((e) => DailyTrend.fromJson(e))
              .toList()
          : defaultWeeklyTrends,
      recentSessions: json['recent_sessions'] != null
          ? (json['recent_sessions'] as List)
              .map((e) => RecentSession.fromJson(e))
              .toList()
          : defaultRecentSessions,
    );
  }

  static List<DailyTrend> get defaultWeeklyTrends => [
    DailyTrend(day: 'Mon', formScore: 78, reps: 32, calories: 140),
    DailyTrend(day: 'Tue', formScore: 81, reps: 45, calories: 190),
    DailyTrend(day: 'Wed', formScore: 85, reps: 50, calories: 210),
    DailyTrend(day: 'Thu', formScore: 88, reps: 60, calories: 260),
    DailyTrend(day: 'Fri', formScore: 92, reps: 65, calories: 320),
    DailyTrend(day: 'Sat', formScore: 94, reps: 70, calories: 350),
    DailyTrend(day: 'Sun', formScore: 95, reps: 75, calories: 380),
  ];

  static List<RecentSession> get defaultRecentSessions => [
    RecentSession(
      id: 1,
      workoutType: 'Bodyweight Squat Blast',
      totalDurationSec: 640,
      totalCalories: 145.0,
      avgFormScore: 94.0,
      completedAt: 'Today, 8:30 AM',
    ),
    RecentSession(
      id: 2,
      workoutType: 'Tree Pose Stability Hold',
      totalDurationSec: 420,
      totalCalories: 85.0,
      avgFormScore: 91.5,
      completedAt: 'Yesterday, 6:00 PM',
    ),
    RecentSession(
      id: 3,
      workoutType: 'Push-Up & Core Sculpt',
      totalDurationSec: 900,
      totalCalories: 210.0,
      avgFormScore: 89.0,
      completedAt: '2 days ago',
    ),
  ];

  static ProgressDashboard get defaultDashboard => ProgressDashboard(
    totalWorkouts: 14,
    totalReps: 397,
    totalCalories: 1850.0,
    avgFormScore: 92.5,
    streakDays: 7,
    weeklyFormTrend: defaultWeeklyTrends,
    recentSessions: defaultRecentSessions,
  );
}
