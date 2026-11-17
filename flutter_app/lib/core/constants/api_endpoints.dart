class ApiEndpoints {
  // Using 127.0.0.1 works for Web, Desktop, and physical Android devices
  // when connected via USB with 'adb reverse tcp:8000 tcp:8000'.
  static String get baseUrl => 'http://127.0.0.1:8000/api/v1';
  static String get wsBaseUrl => 'ws://127.0.0.1:8000/api/v1/ws/pose-stream';

  static const String exercises = '/exercises';
  static const String yoga = '/yoga';
  static const String analytics = '/analytics/dashboard';
  static const String workoutComplete = '/workouts/complete';
  static const String workoutHistory = '/workouts/history';
  static const String userProfile = '/users/me';
  static const String aiPlan = '/users/me/ai-plan';
  static const String aiChat = '/ai/chat';
  static const String poseAnalyze = '/pose/analyze';
}
