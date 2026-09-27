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
  final Duration _timeout = const Duration(seconds: 4);

  // In-memory cache for fast responsive offline/online blending
  List<Exercise>? _cachedExercises;
  List<YogaPose>? _cachedYogaPoses;
  ProgressDashboard? _cachedDashboard;

  /// Fetch Exercise Library from backend with client-side fallback
  Future<List<Exercise>> fetchExercises({String? category, String? query}) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.exercises}');
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final list = data.map((e) => Exercise.fromJson(e)).toList();
        _cachedExercises = list;
      }
    } catch (e) {
      debugPrint("API fetchExercises error: $e, using local data.");
    }

    List<Exercise> results = _cachedExercises ?? Exercise.fallbackExercises;

    // Apply client-side filters if specified
    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
      results = results.where((e) => e.category.toLowerCase().contains(category.toLowerCase())).toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((e) =>
        e.name.toLowerCase().contains(q) ||
        e.targetMuscles.toLowerCase().contains(q) ||
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
        _cachedYogaPoses = list;
      }
    } catch (e) {
      debugPrint("API fetchYogaPoses error: $e, using local data.");
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
        y.description.toLowerCase().contains(q)
      ).toList();
    }

    return results;
  }

  /// Fetch Progress Analytics Dashboard
  Future<ProgressDashboard> fetchDashboardAnalytics() async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.analytics}');
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

  /// Send query to AI Fitness Coach
  Future<String> sendChatMessage(String message, {String userName = 'Athlete'}) async {
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
        return data['reply'] ?? _localAiChatReply(message, userName);
      }
    } catch (e) {
      debugPrint("API sendChatMessage error: $e, using local coaching engine.");
    }

    return _localAiChatReply(message, userName);
  }

  /// Local fallback for AI Coach responses
  String _localAiChatReply(String query, String userName) {
    final q = query.toLowerCase();
    if (q.contains('squat')) {
      return "**Hey $userName! Squat Form Blueprint:**\n\n• **Stance:** Feet shoulder-width apart, toes turned 15–30° outward.\n• **Descent:** Push hips back first, keep chest tall.\n• **Knee Angle:** Aim for ≤ 90° depth without knees collapsing inward (valgus).\n• **Ascent:** Drive firmly through heels & squeeze glutes!";
    } else if (q.contains('pushup') || q.contains('push up') || q.contains('chest')) {
      return "**Push-Up Technique for $userName:**\n\n• **Core:** Keep body in a straight plank line from head to heels.\n• **Elbows:** Tuck elbows at 45° (arrow shape, not flared 90° T-shape).\n• **Full Depth:** Lower chest until elbows reach 90°, then smoothly press up.";
    } else if (q.contains('bicep') || q.contains('curl') || q.contains('arm')) {
      return "**Bicep Curl Mastery:**\n\n• **Elbow Lock:** Pin upper arms stationary against your ribcage.\n• **Peak Squeeze:** Hold contraction at the top for 1 full second.\n• **Control:** Take 2 full seconds lowering down to maximize tension.";
    } else if (q.contains('plank') || q.contains('core') || q.contains('abs')) {
      return "**Plank Stability Rules:**\n\n• **Elbow Alignment:** Stack directly beneath shoulders.\n• **Neutral Spine:** Gaze down, hips in line with shoulders.\n• **Anti-Sag:** Tighten glutes and pull belly button to spine.";
    } else if (q.contains('yoga') || q.contains('tree') || q.contains('balance')) {
      return "**Yoga & Balance Tips:**\n\n• **Breath:** Inhale to expand/lengthen, exhale to deepen into posture.\n• **Rooting:** In Tree Pose, spread all 5 toes to stabilize your ankle.\n• **Focus:** Fix your gaze (Drishti) on a stationary point in front of you.";
    } else {
      return "Hey $userName! I'm your GYM STAR AI Fitness Coach. 🏋️\n\nI can help you with:\n• **Form Corrections & Biometric Angles**\n• **Yoga Postures & Balance Hold Guidance**\n• **Calorie & Progressive Overload Planning**\n\nAsk me any question about your workout!";
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

    // Local smart plan generator based on user goal
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
    // Update local dashboard immediately so progress is updated in real-time
    final current = _cachedDashboard ?? ProgressDashboard.defaultDashboard;
    final updatedSessions = [
      RecentSession(
        id: current.recentSessions.length + 1,
        workoutType: workoutType,
        totalDurationSec: totalDurationSec,
        totalCalories: totalCalories,
        avgFormScore: avgFormScore,
        completedAt: 'Just now',
      ),
      ...current.recentSessions,
    ];

    _cachedDashboard = ProgressDashboard(
      totalWorkouts: current.totalWorkouts + 1,
      totalReps: current.totalReps + totalReps,
      totalCalories: current.totalCalories + totalCalories,
      avgFormScore: ((current.avgFormScore + avgFormScore) / 2).roundToDouble(),
      streakDays: current.streakDays,
      weeklyFormTrend: current.weeklyFormTrend,
      recentSessions: updatedSessions,
    );

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
              'correct_reps': (totalReps * (avgFormScore / 100)).round(),
              'incorrect_reps': (totalReps * (1.0 - (avgFormScore / 100))).round(),
              'avg_form_score': avgFormScore,
            }
          ]
        }),
      ).timeout(_timeout);
      return true;
    } catch (_) {
      return true; // Saved locally
    }
  }
}
