import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'pose_painter.dart';

class AngleCalculator {
  /// Calculates the interior angle (in degrees) formed by three 2D points (A-B-C) with B as vertex.
  static double calculateAngle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final double radians = math.atan2(c.y - b.y, c.x - b.x) - math.atan2(a.y - b.y, a.x - b.x);
    double angle = radians.abs() * 180.0 / math.pi;
    if (angle > 180.0) {
      angle = 360.0 - angle;
    }
    return angle;
  }

  /// Calculates the angle formed by three CustomLandmarkPoint objects.
  static double calculateCustomAngle(CustomLandmarkPoint a, CustomLandmarkPoint b, CustomLandmarkPoint c) {
    final double radians = math.atan2(c.y - b.y, c.x - b.x) - math.atan2(a.y - b.y, a.x - b.x);
    double angle = radians.abs() * 180.0 / math.pi;
    if (angle > 180.0) {
      angle = 360.0 - angle;
    }
    return angle;
  }

  /// Extracts key biometric joint angles from a PoseLandmark map.
  static Map<String, double> extractKeyAngles(Map<String, PoseLandmark> lm) {
    final Map<String, double> angles = {};

    // Left knee angle (HIP - KNEE - ANKLE)
    if (lm.containsKey('LEFT_HIP') && lm.containsKey('LEFT_KNEE') && lm.containsKey('LEFT_ANKLE')) {
      angles['left_knee_angle'] = calculateAngle(lm['LEFT_HIP']!, lm['LEFT_KNEE']!, lm['LEFT_ANKLE']!);
    }

    // Right knee angle
    if (lm.containsKey('RIGHT_HIP') && lm.containsKey('RIGHT_KNEE') && lm.containsKey('RIGHT_ANKLE')) {
      angles['right_knee_angle'] = calculateAngle(lm['RIGHT_HIP']!, lm['RIGHT_KNEE']!, lm['RIGHT_ANKLE']!);
    }

    // Left elbow angle (SHOULDER - ELBOW - WRIST)
    if (lm.containsKey('LEFT_SHOULDER') && lm.containsKey('LEFT_ELBOW') && lm.containsKey('LEFT_WRIST')) {
      angles['left_elbow_angle'] = calculateAngle(lm['LEFT_SHOULDER']!, lm['LEFT_ELBOW']!, lm['LEFT_WRIST']!);
    }

    // Right elbow angle
    if (lm.containsKey('RIGHT_SHOULDER') && lm.containsKey('RIGHT_ELBOW') && lm.containsKey('RIGHT_WRIST')) {
      angles['right_elbow_angle'] = calculateAngle(lm['RIGHT_SHOULDER']!, lm['RIGHT_ELBOW']!, lm['RIGHT_WRIST']!);
    }

    // Left hip angle (SHOULDER - HIP - KNEE)
    if (lm.containsKey('LEFT_SHOULDER') && lm.containsKey('LEFT_HIP') && lm.containsKey('LEFT_KNEE')) {
      angles['left_hip_angle'] = calculateAngle(lm['LEFT_SHOULDER']!, lm['LEFT_HIP']!, lm['LEFT_KNEE']!);
    }

    // Left shoulder angle (ELBOW - SHOULDER - HIP)
    if (lm.containsKey('LEFT_ELBOW') && lm.containsKey('LEFT_SHOULDER') && lm.containsKey('LEFT_HIP')) {
      angles['left_shoulder_angle'] = calculateAngle(lm['LEFT_ELBOW']!, lm['LEFT_SHOULDER']!, lm['LEFT_HIP']!);
    }

    // Default primary angle shortcuts
    angles['knee_angle'] = angles['left_knee_angle'] ?? angles['right_knee_angle'] ?? 180.0;
    angles['elbow_angle'] = angles['left_elbow_angle'] ?? angles['right_elbow_angle'] ?? 180.0;
    angles['hip_angle'] = angles['left_hip_angle'] ?? 180.0;
    angles['shoulder_angle'] = angles['left_shoulder_angle'] ?? 0.0;

    return angles;
  }

  /// Extracts key biometric joint angles from a CustomLandmarkPoint map.
  static Map<String, double> extractCustomKeyAngles(Map<String, CustomLandmarkPoint> lm) {
    final Map<String, double> angles = {};

    if (lm.containsKey('LEFT_HIP') && lm.containsKey('LEFT_KNEE') && lm.containsKey('LEFT_ANKLE')) {
      angles['left_knee_angle'] = calculateCustomAngle(lm['LEFT_HIP']!, lm['LEFT_KNEE']!, lm['LEFT_ANKLE']!);
    }

    if (lm.containsKey('RIGHT_HIP') && lm.containsKey('RIGHT_KNEE') && lm.containsKey('RIGHT_ANKLE')) {
      angles['right_knee_angle'] = calculateCustomAngle(lm['RIGHT_HIP']!, lm['RIGHT_KNEE']!, lm['RIGHT_ANKLE']!);
    }

    if (lm.containsKey('LEFT_SHOULDER') && lm.containsKey('LEFT_ELBOW') && lm.containsKey('LEFT_WRIST')) {
      angles['left_elbow_angle'] = calculateCustomAngle(lm['LEFT_SHOULDER']!, lm['LEFT_ELBOW']!, lm['LEFT_WRIST']!);
    }

    if (lm.containsKey('RIGHT_SHOULDER') && lm.containsKey('RIGHT_ELBOW') && lm.containsKey('RIGHT_WRIST')) {
      angles['right_elbow_angle'] = calculateCustomAngle(lm['RIGHT_SHOULDER']!, lm['RIGHT_ELBOW']!, lm['RIGHT_WRIST']!);
    }

    if (lm.containsKey('LEFT_SHOULDER') && lm.containsKey('LEFT_HIP') && lm.containsKey('LEFT_KNEE')) {
      angles['left_hip_angle'] = calculateCustomAngle(lm['LEFT_SHOULDER']!, lm['LEFT_HIP']!, lm['LEFT_KNEE']!);
    }

    if (lm.containsKey('LEFT_ELBOW') && lm.containsKey('LEFT_SHOULDER') && lm.containsKey('LEFT_HIP')) {
      angles['left_shoulder_angle'] = calculateCustomAngle(lm['LEFT_ELBOW']!, lm['LEFT_SHOULDER']!, lm['LEFT_HIP']!);
    }

    angles['knee_angle'] = angles['left_knee_angle'] ?? angles['right_knee_angle'] ?? 180.0;
    angles['elbow_angle'] = angles['left_elbow_angle'] ?? angles['right_elbow_angle'] ?? 180.0;
    angles['hip_angle'] = angles['left_hip_angle'] ?? 180.0;
    angles['shoulder_angle'] = angles['left_shoulder_angle'] ?? 0.0;

    return angles;
  }
}
