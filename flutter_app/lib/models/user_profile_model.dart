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

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'focus': focus,
      'duration': duration,
      'exercises': exercises,
      'type': type,
    };
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
  int age;
  double heightCm;
  double weightKg;
  String fitnessLevel;
  String primaryGoal;
  int preferredDurationMin;
  String availableEquipment;
  String workoutPreferences;
  bool voiceCoaching;
  String? avatarUrl;

  UserProfile({
    this.name = 'Ramanji',
    this.email = 'raman@gymstar.ai',
    this.age = 26,
    this.heightCm = 175.0,
    this.weightKg = 72.0,
    this.fitnessLevel = 'Intermediate',
    this.primaryGoal = 'Strength & Muscle Tone',
    this.preferredDurationMin = 30,
    this.availableEquipment = 'Bodyweight & Dumbbells',
    this.workoutPreferences = 'High Accuracy Form Tracking',
    this.voiceCoaching = true,
    this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'Ramanji',
      email: json['email'] ?? 'raman@gymstar.ai',
      age: json['age'] ?? 26,
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 175.0,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 72.0,
      fitnessLevel: json['fitness_level'] ?? 'Intermediate',
      primaryGoal: json['primary_goal'] ?? 'Strength & Muscle Tone',
      preferredDurationMin: json['preferred_duration_min'] ?? 30,
      availableEquipment: json['available_equipment'] ?? 'Bodyweight & Dumbbells',
      workoutPreferences: json['workout_preferences'] ?? 'High Accuracy Form Tracking',
      voiceCoaching: json['voice_coaching'] ?? true,
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'fitness_level': fitnessLevel,
      'primary_goal': primaryGoal,
      'preferred_duration_min': preferredDurationMin,
      'available_equipment': availableEquipment,
      'workout_preferences': workoutPreferences,
      'voice_coaching': voiceCoaching,
      'avatar_url': avatarUrl,
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    int? age,
    double? heightCm,
    double? weightKg,
    String? fitnessLevel,
    String? primaryGoal,
    int? preferredDurationMin,
    String? availableEquipment,
    String? workoutPreferences,
    bool? voiceCoaching,
    String? avatarUrl,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      preferredDurationMin: preferredDurationMin ?? this.preferredDurationMin,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      workoutPreferences: workoutPreferences ?? this.workoutPreferences,
      voiceCoaching: voiceCoaching ?? this.voiceCoaching,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
