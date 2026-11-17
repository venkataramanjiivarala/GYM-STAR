import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../../models/exercise_model.dart';
import '../../models/yoga_pose_model.dart';
import '../../models/analytics_model.dart';
import '../../models/user_profile_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  final Duration _timeout = const Duration(seconds: 5);

  // In-memory cache for ultra-fast UI rendering & offline fallback
  List<Exercise>? _cachedExercises;
  List<YogaPose>? _cachedYogaPoses;
  ProgressDashboard? _cachedDashboard;
  UserProfile? _cachedProfile;

  /// Global notifier that fires whenever a workout is recorded
  final ValueNotifier<int> workoutCompletedNotifier = ValueNotifier<int>(0);

  /// Fetch Exercise Library from backend with client-side fallback
  Future<List<Exercise>> fetchExercises({String? category, String? query}) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.exercises}');
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final list = data.map((e) => Exercise.fromJson(e)).toList();
        if (list.isNotEmpty) {
          _cachedExercises = list;
        }
      }
    } catch (e) {
      debugPrint("API fetchExercises error: $e, using local repository.");
    }

    List<Exercise> results = _cachedExercises ?? Exercise.fallbackExercises;

    // Filter by Category
    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
      results = results.where((e) => e.category.toLowerCase().contains(category.toLowerCase())).toList();
    }

    // Filter by Search Query
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((e) =>
        e.name.toLowerCase().contains(q) ||
        e.targetMuscles.toLowerCase().contains(q) ||
        e.category.toLowerCase().contains(q) ||
        e.description.toLowerCase().contains(q)
      ).toList();
    }

    return results;
  }

  /// Fetch Yoga Poses from backend with fallback
  Future<List<YogaPose>> fetchYogaPoses({String? category, String? query}) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.yoga}');
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final list = data.map((e) => YogaPose.fromJson(e)).toList();
        if (list.isNotEmpty) {
          _cachedYogaPoses = list;
        }
      }
    } catch (e) {
      debugPrint("API fetchYogaPoses error: $e, using local repository.");
    }

    List<YogaPose> results = _cachedYogaPoses ?? YogaPose.fallbackYogaPoses;

    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
      results = results.where((y) => y.category.toLowerCase().contains(category.toLowerCase())).toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((y) =>
        y.name.toLowerCase().contains(q) ||
        y.sanskritName.toLowerCase().contains(q) ||
        y.category.toLowerCase().contains(q) ||
        y.description.toLowerCase().contains(q)
      ).toList();
    }

    return results;
  }

  /// Fetch Progress Analytics Dashboard
  Future<ProgressDashboard> fetchDashboardAnalytics({String timeframe = '7d'}) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.analytics}?timeframe=$timeframe');
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cachedDashboard = ProgressDashboard.fromJson(data);
        return _cachedDashboard!;
      }
    } catch (e) {
      debugPrint("API fetchDashboardAnalytics error: $e, using cached/default.");
    }

    return _cachedDashboard ?? ProgressDashboard.defaultDashboard;
  }

  /// Fetch User Profile
  Future<UserProfile> fetchUserProfile() async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.userProfile}');
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profData = data['profile'] ?? data;
        _cachedProfile = UserProfile(
          name: data['name'] ?? 'Ramanji',
          email: data['email'] ?? 'raman@gymstar.ai',
          age: profData['age'] ?? 26,
          heightCm: (profData['height_cm'] as num?)?.toDouble() ?? 175.0,
          weightKg: (profData['weight_kg'] as num?)?.toDouble() ?? 72.0,
          fitnessLevel: profData['fitness_level'] ?? 'Intermediate',
          primaryGoal: profData['primary_goal'] ?? 'Strength & Muscle Tone',
          availableEquipment: profData['equipment'] ?? 'Bodyweight & Dumbbells',
          voiceCoaching: profData['voice_coaching'] ?? true,
        );
        return _cachedProfile!;
      }
    } catch (e) {
      debugPrint("API fetchUserProfile error: $e, using cached profile.");
    }
    return _cachedProfile ?? UserProfile();
  }

  /// Update User Profile
  Future<bool> updateUserProfile(UserProfile profile) async {
    _cachedProfile = profile;
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/users/me/profile');
      final response = await _client.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'age': profile.age,
          'gender': 'unspecified',
          'height_cm': profile.heightCm,
          'weight_kg': profile.weightKg,
          'fitness_level': profile.fitnessLevel,
          'primary_goal': profile.primaryGoal,
          'workout_frequency': 4,
          'equipment': profile.availableEquipment,
          'voice_coaching': profile.voiceCoaching,
        }),
      ).timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("API updateUserProfile error: $e, saved locally.");
      return true;
    }
  }

  /// Send query to AI Fitness Coach
  Future<String> sendChatMessage(String message, {String userName = 'Athlete', UserProfile? profile}) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.aiChat}');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'user_name': userName,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['reply'] != null && data['reply'].toString().isNotEmpty) {
          return data['reply'];
        }
      }
    } catch (e) {
      debugPrint("API sendChatMessage error: $e, using dynamic coaching intelligence.");
    }

    return _generateContextualAiReply(message, userName, profile ?? _cachedProfile ?? UserProfile());
  }

  /// Intelligent contextual coaching assistant with full awareness of profile and progress
  String _generateContextualAiReply(String query, String userName, UserProfile profile) {
    final q = query.toLowerCase();

    if (q.contains('create') || q.contains('daily workout') || q.contains('routine') || q.contains('today')) {
      final goal = profile.primaryGoal;
      final level = profile.fitnessLevel;
      final equip = profile.availableEquipment;

      return "**Personalized Daily Workout for $userName** 🏋️\n\n"
          "• **Profile:** $level Tier | Goal: $goal\n"
          "• **Equipment:** $equip\n\n"
          "**Target Routine (30 min):**\n"
          "1. **Dynamic Warmup (4 min):** Arm circles, hip openers & light high knees.\n"
          "2. **Bodyweight Squats (4 Sets × 15 Reps):** Focus on 90° knee flexion.\n"
          "3. **Classic Push-Ups (3 Sets × 12 Reps):** 45° tucked elbows, straight line spine.\n"
          "4. **Forearm Plank (3 Sets × 45s Hold):** Anti-extension core engagement.\n"
          "5. **Cool-down (3 min):** Downward Dog & Child's Pose.\n\n"
          "Tap **Start AI Workout** whenever you're ready for real-time camera coaching!";
    } else if (q.contains('squat') && (q.contains('improve') || q.contains('form') || q.contains('depth'))) {
      return "**Squat Form Mastery for $userName:** 🦵\n\n"
          "• **Stance:** Feet shoulder-width apart, toes flared outward 15–25°.\n"
          "• **Hips First:** Initiate the movement by unlocking hips backward before bending knees.\n"
          "• **Depth Target:** Lower until hip crease drops just below parallel (≤ 90° knee bend).\n"
          "• **Knee Tracking:** Forcefully push knees out over 2nd toes to prevent valgus collapse.\n"
          "• **Drive:** Explode upward pushing directly through your heels while exhaling!";
    } else if (q.contains('progress') || q.contains('analyze') || q.contains('weekly')) {
      final dash = _cachedDashboard ?? ProgressDashboard.defaultDashboard;
      return "**Progress Analysis for $userName** 📊\n\n"
          "• **Total Workouts:** ${dash.totalWorkouts} sessions recorded\n"
          "• **Active Streak:** ${dash.streakDays} consecutive days 🔥\n"
          "• **Total Reps:** ${dash.totalReps} biomechanically verified reps\n"
          "• **Calorie Burn:** ${dash.totalCalories.toInt()} kcal\n"
          "• **Average Posture Accuracy:** ${dash.avgFormScore.toStringAsFixed(1)}%\n\n"
          "**Coach Insight:** Your movement consistency is outstanding! Aim to maintain your Form Score above 88% on compound sets.";
    } else if (q.contains('beginner')) {
      return "**Beginner AI Foundation Circuit:** 🌟\n\n"
          "• **Exercise 1:** Bodyweight Squats (3 sets of 10)\n"
          "• **Exercise 2:** Incline Push-Ups on bench (3 sets of 8)\n"
          "• **Exercise 3:** Forearm Plank (3 sets of 30 seconds)\n"
          "• **Exercise 4:** Tree Pose (2 holds of 20 seconds each leg)\n\n"
          "Take 60 seconds rest between rounds. Use our live camera AI to verify your joint angles!";
    } else if (q.contains('muscle') || q.contains('train today') || q.contains('split')) {
      return "**Muscle Recommendation for Today:** 💪\n\n"
          "Based on your goal (*${profile.primaryGoal}*), today is optimal for **Legs & Core Stability**.\n\n"
          "• **Primary Movers:** Quadriceps & Gluteus Maximus\n"
          "• **Stabilizers:** Transverse Abdominis & Hamstrings\n"
          "• **Recommended Exercises:** Bodyweight Squats, Forward Lunges, and Plank Hold.";
    } else if (q.contains('pushup') || q.contains('push up') || q.contains('chest')) {
      return "**Push-Up Technique Blueprint:** 🛡️\n\n"
          "• **Hand Placement:** Slightly wider than shoulders, fingers spread flat.\n"
          "• **Elbow Flare:** Angle elbows at 45° relative to your torso (arrow shape, never a 90° T).\n"
          "• **Core Rigid:** Squeeze glutes and quads to eliminate hip sagging.\n"
          "• **Full ROM:** Lower chest until it hovers 1 inch above mat, then press firmly up.";
    } else if (q.contains('yoga') || q.contains('tree') || q.contains('balance')) {
      return "**Yoga & Balance Hold Guidance:** 🧘\n\n"
          "• **Drishti (Focus):** Fix your gaze on an unmoving spot directly ahead.\n"
          "• **Foot Rooting:** Spread all 5 toes to form a wide stability tripod on the floor.\n"
          "• **Breath Control:** Deep 4-second nasal inhale, 4-second exhale to regulate parasympathetic tone.";
    } else {
      return "Hello $userName! 🌟 I'm your GYM STAR AI Fitness Coach.\n\n"
          "I can assist you with:\n"
          "• **Personalized Daily Workout Creation**\n"
          "• **Biometric Form Correction & Joint Angles**\n"
          "• **Weekly Analytics & Streak Analysis**\n"
          "• **Target Muscle Splits & Progressive Overload**\n\n"
          "What fitness milestone are we targeting today?";
    }
  }

  /// Generate Personalized 7-day AI Plan based on user profile
  Future<AiPersonalizedPlan> generateAiPlan(UserProfile profile) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.aiPlan}');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AiPersonalizedPlan.fromJson(data);
      }
    } catch (e) {
      debugPrint("API generateAiPlan error: $e, generating local AI plan.");
    }

    final goal = profile.primaryGoal.toLowerCase();
    List<ScheduleDay> days;
    if (goal.contains('weight') || goal.contains('fat') || goal.contains('cardio')) {
      days = [
        ScheduleDay(day: 'Monday', focus: 'HIIT Lower Body & Core', duration: '30 min', exercises: ['Bodyweight Squat', 'Forward Lunge', 'Plank'], type: 'HIIT'),
        ScheduleDay(day: 'Tuesday', focus: 'Upper Body & Cardio Core', duration: '25 min', exercises: ['Classic Push-Up', 'Overhead Press', 'Plank'], type: 'HIIT'),
        ScheduleDay(day: 'Wednesday', focus: 'Active Recovery Flow', duration: '20 min', exercises: ['Downward Dog', 'Child\'s Pose'], type: 'Yoga'),
        ScheduleDay(day: 'Thursday', focus: 'Total Body Circuit', duration: '30 min', exercises: ['Squat', 'Push-Up', 'Bicep Curl', 'Lunge'], type: 'Circuit'),
        ScheduleDay(day: 'Friday', focus: 'Core Endurance & Balance', duration: '25 min', exercises: ['Plank', 'Tree Pose', 'Warrior II'], type: 'Yoga/Core'),
        ScheduleDay(day: 'Saturday', focus: 'High Intensity Flow', duration: '25 min', exercises: ['Squat', 'Lateral Raise'], type: 'HIIT'),
        ScheduleDay(day: 'Sunday', focus: 'Full Rest & Regeneration', duration: '0 min', exercises: [], type: 'Rest'),
      ];
    } else if (goal.contains('yoga') || goal.contains('flexibility')) {
      days = [
        ScheduleDay(day: 'Monday', focus: 'Morning Vinyasa Alignment', duration: '25 min', exercises: ['Tree Pose', 'Warrior II', 'Downward Dog'], type: 'Yoga'),
        ScheduleDay(day: 'Tuesday', focus: 'Spine & Core Mobility', duration: '20 min', exercises: ['Cobra Pose', 'Child\'s Pose', 'Plank'], type: 'Yoga'),
        ScheduleDay(day: 'Wednesday', focus: 'Balance & Stability', duration: '25 min', exercises: ['Tree Pose', 'Triangle Pose'], type: 'Yoga'),
        ScheduleDay(day: 'Thursday', focus: 'Posterior Chain Stretch', duration: '30 min', exercises: ['Downward Dog', 'Bridge Pose'], type: 'Yoga'),
        ScheduleDay(day: 'Friday', focus: 'Chest Openers & Breath', duration: '20 min', exercises: ['Cobra Pose', 'Child\'s Pose'], type: 'Yoga'),
        ScheduleDay(day: 'Saturday', focus: 'Deep Hip Restoration', duration: '30 min', exercises: ['Warrior II', 'Triangle Pose', 'Bridge Pose'], type: 'Yoga'),
        ScheduleDay(day: 'Sunday', focus: 'Mindful Meditation & Rest', duration: '0 min', exercises: [], type: 'Rest'),
      ];
    } else {
      days = [
        ScheduleDay(day: 'Monday', focus: 'Full Body Power Blast', duration: '30 min', exercises: ['Bodyweight Squat', 'Classic Push-Up', 'Plank'], type: 'Strength'),
        ScheduleDay(day: 'Tuesday', focus: 'Legs & Core Hypertrophy', duration: '30 min', exercises: ['Forward Lunge', 'Squat', 'Plank'], type: 'Strength'),
        ScheduleDay(day: 'Wednesday', focus: 'Mobility & Active Recovery', duration: '20 min', exercises: ['Downward Dog', 'Cobra Pose'], type: 'Yoga'),
        ScheduleDay(day: 'Thursday', focus: 'Chest & Arms Sculpt', duration: '35 min', exercises: ['Push-Up', 'Bicep Curl', 'Overhead Press'], type: 'Strength'),
        ScheduleDay(day: 'Friday', focus: 'Shoulders & Core Stability', duration: '25 min', exercises: ['Lateral Raise', 'Overhead Press', 'Plank'], type: 'Strength'),
        ScheduleDay(day: 'Saturday', focus: 'Total Body Burnout', duration: '30 min', exercises: ['Squat', 'Push-Up', 'Warrior II'], type: 'Hybrid'),
        ScheduleDay(day: 'Sunday', focus: 'Nutritional Recovery & Rest', duration: '0 min', exercises: [], type: 'Rest'),
      ];
    }

    return AiPersonalizedPlan(
      title: '${profile.fitnessLevel} • ${profile.primaryGoal} Pathway',
      fitnessLevel: profile.fitnessLevel,
      primaryGoal: profile.primaryGoal,
      coachTip: 'Prioritize joint stability over tempo. Keep Form Score > 85% for maximum strength development!',
      weeklySchedule: days,
    );
  }

  /// Log completed workout session
  Future<bool> completeWorkoutSession({
    required String workoutType,
    required int totalDurationSec,
    required double totalCalories,
    required double avgFormScore,
    required int totalReps,
  }) async {
    // 1. Update in-memory dashboard immediately with actual recorded numbers
    final current = _cachedDashboard ?? ProgressDashboard.defaultDashboard;
    final updatedSessions = [
      RecentSession(
        id: (current.recentSessions.length + 1).toString(),
        workoutType: workoutType,
        totalDurationSec: totalDurationSec,
        totalCalories: totalCalories,
        avgFormScore: avgFormScore,
        totalReps: totalReps,
        completedAt: 'Just now',
      ),
      ...current.recentSessions,
    ];

    final newTotalWorkouts = current.totalWorkouts + 1;
    final newTotalReps = current.totalReps + totalReps;
    final newTotalCalories = current.totalCalories + totalCalories;
    final newAvgScore = current.totalWorkouts > 0
        ? ((current.avgFormScore * current.totalWorkouts + avgFormScore) / newTotalWorkouts).roundToDouble()
        : avgFormScore;

    _cachedDashboard = ProgressDashboard(
      totalWorkouts: newTotalWorkouts,
      totalReps: newTotalReps,
      totalCalories: newTotalCalories,
      avgFormScore: newAvgScore,
      streakDays: current.streakDays > 0 ? current.streakDays : 1,
      totalActiveMinutes: current.totalActiveMinutes + (totalDurationSec ~/ 60),
      weeklyFormTrend: current.weeklyFormTrend,
      recentSessions: updatedSessions,
    );

    // 2. Notify all listening UI screens to reload
    workoutCompletedNotifier.value++;

    // 3. Persist to FastAPI Backend
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.workoutComplete}');
      await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'workout_type': workoutType,
          'total_duration_sec': totalDurationSec,
          'total_calories': totalCalories,
          'avg_form_score': avgFormScore,
          'exercises': [
            {
              'exercise_key': 'active_exercise',
              'exercise_name': workoutType,
              'total_reps': totalReps,
              'correct_reps': (totalReps * (avgFormScore / 100.0)).round(),
              'incorrect_reps': (totalReps * (1.0 - (avgFormScore / 100.0))).round(),
              'avg_form_score': avgFormScore,
            }
          ]
        }),
      ).timeout(_timeout);

      // Re-fetch genuine calculated dashboard from server
      await fetchDashboardAnalytics();
      workoutCompletedNotifier.value++;
      return true;
    } catch (e) {
      debugPrint("API completeWorkoutSession error: $e, saved locally.");
      return true;
    }
  }
}
