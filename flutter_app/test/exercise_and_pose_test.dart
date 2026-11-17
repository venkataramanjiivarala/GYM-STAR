import 'package:flutter_test/flutter_test.dart';
import 'package:gymstar_mobile/models/exercise_model.dart';
import 'package:gymstar_mobile/core/services/pose_analyzer.dart';

void main() {
  group('Centralized Exercise Registry Tests', () {
    test('Verify all 77+ exercises have unique keys and valid configurations', () {
      final exercises = Exercise.fallbackExercises;
      expect(exercises.length, greaterThanOrEqualTo(50));

      final keys = <String>{};
      for (final ex in exercises) {
        expect(ex.key.isNotEmpty, true, reason: 'Exercise key should not be empty');
        expect(keys.contains(ex.key), false, reason: 'Duplicate exercise key found: ${ex.key}');
        keys.add(ex.key);

        expect(ex.name.isNotEmpty, true);
        expect(ex.category.isNotEmpty, true);
        expect(ex.primaryMuscles.isNotEmpty, true);
        expect(ex.instructions.isNotEmpty, true);
      }

      // Check category coverage
      final categories = exercises.map((e) => e.category).toSet();
      expect(categories.contains('Chest'), true);
      expect(categories.contains('Back'), true);
      expect(categories.contains('Shoulders'), true);
      expect(categories.contains('Biceps'), true);
      expect(categories.contains('Triceps'), true);
      expect(categories.contains('Legs'), true);
      expect(categories.contains('Abs and Core'), true);
      expect(categories.contains('Forearms'), true);
      expect(categories.contains('Glutes'), true);
    });

    test('Verify Preacher Curl exercise record is distinct from standard bicep curl', () {
      final exercises = Exercise.fallbackExercises;
      final preacher = exercises.firstWhere((e) => e.key == 'preacher_curl');
      final curl = exercises.firstWhere((e) => e.key == 'bicep_curl');

      expect(preacher.name, 'Preacher Curl');
      expect(preacher.equipment.toLowerCase().contains('preacher'), true);
      expect(preacher.key, isNot(equals(curl.key)));
      expect(preacher.rulesConfig?['pad_angle_check'], true);
    });
  });

  group('Exercise-Specific AI Pose Analyzer Tests', () {
    late PoseAnalyzerEngine engine;

    setUp(() {
      engine = PoseAnalyzerEngine();
      engine.reset();
    });

    test('Squat state machine counts valid reps on STANDING -> DOWN -> UP', () {
      // 1. Initial Standing position (Knee angle ~ 170 deg)
      final pStanding = {
        'NOSE': const BiometricPoint(x: 0.5, y: 0.2),
        'LEFT_SHOULDER': const BiometricPoint(x: 0.45, y: 0.3),
        'LEFT_HIP': const BiometricPoint(x: 0.45, y: 0.5),
        'LEFT_KNEE': const BiometricPoint(x: 0.45, y: 0.7),
        'LEFT_ANKLE': const BiometricPoint(x: 0.45, y: 0.9),
      };

      var res = engine.analyzeLandmarkPoints(points: pStanding, exerciseKey: 'squat', isYoga: false);
      expect(res.repCount, 0);
      expect(res.repState, 'READY');

      // 2. Deep Squat position (Knee angle < 98 deg)
      final pDown = {
        'NOSE': const BiometricPoint(x: 0.5, y: 0.35),
        'LEFT_SHOULDER': const BiometricPoint(x: 0.45, y: 0.45),
        'LEFT_HIP': const BiometricPoint(x: 0.45, y: 0.65),
        'LEFT_KNEE': const BiometricPoint(x: 0.30, y: 0.66), // bent forward
        'LEFT_ANKLE': const BiometricPoint(x: 0.45, y: 0.9),
      };

      res = engine.analyzeLandmarkPoints(points: pDown, exerciseKey: 'squat', isYoga: false);
      expect(res.repState, 'DOWN');
      expect(res.repCount, 0);

      // 3. Return to Standing position (Knee angle > 155 deg)
      res = engine.analyzeLandmarkPoints(points: pStanding, exerciseKey: 'squat', isYoga: false);
      expect(res.repCount, 1);
      expect(res.repState, 'UP');
      expect(res.repCompletedJustNow, true);
      expect(res.formScore, greaterThan(80.0));
      expect(res.repHistory.length, 1);
      expect(res.repHistory.first.accuracyScore, greaterThan(70.0));
    });

    test('Mismatch detection: Horizontal posture during Squat triggers alert', () {
      // Horizontal pushup-like posture
      final pHorizontal = {
        'NOSE': const BiometricPoint(x: 0.2, y: 0.5),
        'LEFT_SHOULDER': const BiometricPoint(x: 0.3, y: 0.5),
        'LEFT_HIP': const BiometricPoint(x: 0.6, y: 0.52), // deltaY is tiny, deltaX is large
        'LEFT_KNEE': const BiometricPoint(x: 0.75, y: 0.52),
        'LEFT_ANKLE': const BiometricPoint(x: 0.9, y: 0.52),
      };

      // Send 7 consecutive frames to trigger debounced mismatch alert
      PoseAnalysisResult? lastRes;
      for (int i = 0; i < 7; i++) {
        lastRes = engine.analyzeLandmarkPoints(points: pHorizontal, exerciseKey: 'squat', isYoga: false);
      }

      expect(lastRes != null, true);
      expect(lastRes!.isMismatch, true);
      expect(lastRes.status, 'INCORRECT');
      expect(lastRes.mismatchAlert!.contains('Mismatch Alert'), true);
    });

    test('Preacher Curl tracks elbow angle and requires arm stability', () {
      // Preacher curl position on pad
      final pCurled = {
        'NOSE': const BiometricPoint(x: 0.5, y: 0.2),
        'LEFT_SHOULDER': const BiometricPoint(x: 0.45, y: 0.32),
        'LEFT_ELBOW': const BiometricPoint(x: 0.42, y: 0.50),
        'LEFT_WRIST': const BiometricPoint(x: 0.44, y: 0.33), // flexed up
        'LEFT_HIP': const BiometricPoint(x: 0.45, y: 0.58),
      };

      final res = engine.analyzeLandmarkPoints(points: pCurled, exerciseKey: 'preacher_curl', isYoga: false);
      expect(res.activeJointName, 'Preacher Elbow Angle');
      expect(res.isPersonDetected, true);
      expect(res.activeJointAngle, lessThan(60.0));
    });
  });
}

