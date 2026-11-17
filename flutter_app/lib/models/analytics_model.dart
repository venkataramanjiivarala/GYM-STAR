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
      formScore: (json['form_score'] as num?)?.toDouble() ?? 0.0,
      reps: (json['reps'] as num?)?.toInt() ?? 0,
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RecentSession {
  final String id;
  final String workoutType;
  final int totalDurationSec;
  final double totalCalories;
  final double avgFormScore;
  final int totalReps;
  final String completedAt;
  final DateTime? rawCompletedAt;

  RecentSession({
    required this.id,
    required this.workoutType,
    required this.totalDurationSec,
    required this.totalCalories,
    required this.avgFormScore,
    this.totalReps = 0,
    required this.completedAt,
    this.rawCompletedAt,
  });

  bool get isToday {
    if (rawCompletedAt != null) {
      final now = DateTime.now();
      return rawCompletedAt!.year == now.year &&
          rawCompletedAt!.month == now.month &&
          rawCompletedAt!.day == now.day;
    }
    final lower = completedAt.toLowerCase();
    return lower.contains('today') ||
        lower.contains('just now') ||
        lower.contains('m ago') ||
        lower.contains('h ago');
  }

  factory RecentSession.fromJson(Map<String, dynamic> json) {
    int parsedReps = 0;
    if (json['total_reps'] != null) {
      parsedReps = (json['total_reps'] as num).toInt();
    } else if (json['exercise_sessions'] is List && (json['exercise_sessions'] as List).isNotEmpty) {
      for (var es in (json['exercise_sessions'] as List)) {
        if (es is Map && es['total_reps'] != null) {
          parsedReps += (es['total_reps'] as num).toInt();
        }
      }
    }

    DateTime? rawDate;
    String displayDate = json['completed_at']?.toString() ?? 'Recent';
    try {
      if (displayDate.contains('T') || displayDate.contains('-')) {
        rawDate = DateTime.parse(displayDate).toLocal();
        final now = DateTime.now();
        final diff = now.difference(rawDate);
        if (diff.inMinutes < 60) {
          displayDate = diff.inMinutes <= 1 ? 'Just now' : '${diff.inMinutes}m ago';
        } else if (diff.inHours < 24 && rawDate.day == now.day) {
          displayDate = '${diff.inHours}h ago';
        } else if (diff.inDays <= 1 || (now.day - rawDate.day == 1 && diff.inHours < 48)) {
          displayDate = 'Yesterday';
        } else {
          displayDate = '${rawDate.month}/${rawDate.day}';
        }
      }
    } catch (_) {}

    return RecentSession(
      id: json['id']?.toString() ?? '0',
      workoutType: json['workout_type'] ?? 'Gym Workout',
      totalDurationSec: (json['total_duration_sec'] as num?)?.toInt() ?? 0,
      totalCalories: (json['total_calories'] as num?)?.toDouble() ?? 0.0,
      avgFormScore: (json['avg_form_score'] as num?)?.toDouble() ?? 0.0,
      totalReps: parsedReps,
      completedAt: displayDate,
      rawCompletedAt: rawDate,
    );
  }
}

class ProgressDashboard {
  final int totalWorkouts;
  final int totalReps;
  final double totalCalories;
  final double avgFormScore;
  final int streakDays;
  final int totalActiveMinutes;
  final List<DailyTrend> weeklyFormTrend;
  final List<RecentSession> recentSessions;

  ProgressDashboard({
    required this.totalWorkouts,
    required this.totalReps,
    required this.totalCalories,
    required this.avgFormScore,
    required this.streakDays,
    this.totalActiveMinutes = 0,
    required this.weeklyFormTrend,
    required this.recentSessions,
  });

  factory ProgressDashboard.fromJson(Map<String, dynamic> json) {
    final sessions = json['recent_sessions'] != null
        ? (json['recent_sessions'] as List)
            .map((e) => RecentSession.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <RecentSession>[];

    int activeMins = 0;
    for (var s in sessions) {
      activeMins += (s.totalDurationSec ~/ 60);
    }

    return ProgressDashboard(
      totalWorkouts: (json['total_workouts'] as num?)?.toInt() ?? 0,
      totalReps: (json['total_reps'] as num?)?.toInt() ?? 0,
      totalCalories: (json['total_calories'] as num?)?.toDouble() ?? 0.0,
      avgFormScore: (json['avg_form_score'] as num?)?.toDouble() ?? 0.0,
      streakDays: (json['streak_days'] as num?)?.toInt() ?? 0,
      totalActiveMinutes: activeMins,
      weeklyFormTrend: json['weekly_form_trend'] != null
          ? (json['weekly_form_trend'] as List)
              .map((e) => DailyTrend.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : emptyWeeklyTrends,
      recentSessions: sessions,
    );
  }

  static List<DailyTrend> get emptyWeeklyTrends {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.map((d) => DailyTrend(day: d, formScore: 0.0, reps: 0, calories: 0.0)).toList();
  }

  static List<RecentSession> get defaultRecentSessions => [];

  static ProgressDashboard get emptyDashboard => ProgressDashboard(
    totalWorkouts: 0,
    totalReps: 0,
    totalCalories: 0.0,
    avgFormScore: 0.0,
    streakDays: 0,
    totalActiveMinutes: 0,
    weeklyFormTrend: emptyWeeklyTrends,
    recentSessions: [],
  );

  static ProgressDashboard get defaultDashboard => emptyDashboard;
}
