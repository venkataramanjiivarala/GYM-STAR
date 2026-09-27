import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    try {
      if (Platform.isAndroid) {
        // 10.0.2.2 for Android emulator, fallback to localhost for desktop/local port forwarding
        return 'http://10.0.2.2:8000/api/v1';
      }
    } catch (_) {}
    return 'http://127.0.0.1:8000/api/v1';
  }

  static String get wsBaseUrl {
    if (kIsWeb) {
      return 'ws://127.0.0.1:8000/api/v1/ws/pose-stream';
    }
    try {
      if (Platform.isAndroid) {
        return 'ws://10.0.2.2:8000/api/v1/ws/pose-stream';
      }
    } catch (_) {}
    return 'ws://127.0.0.1:8000/api/v1/ws/pose-stream';
  }

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
