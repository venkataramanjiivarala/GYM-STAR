class ScheduleDay {
  final String day;
  final String focus;
  final String duration;
  final List<String> exercises;
  final String type;

  ScheduleDay({
    required this.day,
    required this.focus,
    required this.duration,
    required this.exercises,
    required this.type,
  });

  factory ScheduleDay.fromJson(Map<String, dynamic> json) {
    return ScheduleDay(
      day: json['day'] ?? '',
      focus: json['focus'] ?? '',
      duration: json['duration'] ?? '20 min',
      exercises: json['exercises'] != null ? List<String>.from(json['exercises']) : [],
      type: json['type'] ?? 'Workout',
    );
  }
}

class AiPersonalizedPlan {
  final String title;
  final String fitnessLevel;
  final String primaryGoal;
  final String coachTip;
  final List<ScheduleDay> weeklySchedule;

  AiPersonalizedPlan({
    required this.title,
    required this.fitnessLevel,
    required this.primaryGoal,
    required this.coachTip,
    required this.weeklySchedule,
  });

  factory AiPersonalizedPlan.fromJson(Map<String, dynamic> json) {
    return AiPersonalizedPlan(
      title: json['title'] ?? 'AI Training Pathway',
      fitnessLevel: json['fitness_level'] ?? 'Beginner',
      primaryGoal: json['primary_goal'] ?? 'Strength & Form',
      coachTip: json['coach_tip'] ?? '',
      weeklySchedule: json['weekly_schedule'] != null
          ? (json['weekly_schedule'] as List)
              .map((e) => ScheduleDay.fromJson(e))
              .toList()
          : [],
    );
  }
}

class UserProfile {
  String name;
  String email;
  String fitnessLevel;
  String primaryGoal;
  double weightKg;
  double heightCm;

  UserProfile({
    this.name = 'Ramanji',
    this.email = 'raman@gymstar.ai',
    this.fitnessLevel = 'Beginner',
    this.primaryGoal = 'Strength & Muscle Tone',
    this.weightKg = 72.0,
    this.heightCm = 175.0,
  });
}
