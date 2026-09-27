import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

enum JointFormStatus {
  good,
  warning,
  incorrect,
  neutral,
}

class JointEvaluation {
  final String landmarkName; // e.g. 'LEFT_KNEE', 'RIGHT_KNEE', 'LEFT_ELBOW'
  final double angle; // Measured angle in degrees
  final JointFormStatus status;
  final String feedback;
  final String? label; // e.g. "Knee 88°"

  const JointEvaluation({
    required this.landmarkName,
    required this.angle,
    required this.status,
    required this.feedback,
    this.label,
  });
}

class BiometricPoint {
  final double x;
  final double y;
  final double confidence;

  const BiometricPoint({
    required this.x,
    required this.y,
    this.confidence = 1.0,
  });

  factory BiometricPoint.fromPoseLandmark(PoseLandmark lm) {
    return BiometricPoint(
      x: lm.x,
      y: lm.y,
      confidence: lm.likelihood,
    );
  }
}

class PoseAnalysisResult {
  final int repCount;
  final double formScore;
  final String status; // "GOOD", "WARNING", "INCORRECT"
  final String feedbackMessage;
  final String repState;
  final String activeJointName;
  final double activeJointAngle;
  final bool repCompletedJustNow;
  final String? voiceCue;
  final int holdSeconds;
  final Map<String, JointEvaluation> jointEvaluations;
  final Map<String, JointFormStatus> boneEvaluations;

  PoseAnalysisResult({
    required this.repCount,
    required this.formScore,
    required this.status,
    required this.feedbackMessage,
    required this.repState,
    required this.activeJointName,
    required this.activeJointAngle,
    this.repCompletedJustNow = false,
    this.voiceCue,
    this.holdSeconds = 0,
    this.jointEvaluations = const {},
    this.boneEvaluations = const {},
  });
}

class PoseAnalyzerEngine {
  int _repCount = 0;
  String _repState = "READY"; // READY, DOWN, UP, HOLDING
  double _formScore = 95.0;
  String _status = "GOOD";
  String _feedbackMessage = "Ready - Stand in camera view";
  String _activeJointName = "Knee Angle";
  double _activeJointAngle = 180.0;
  int _holdTicks = 0;

  Map<String, JointEvaluation> _jointEvaluations = {};
  Map<String, JointFormStatus> _boneEvaluations = {};

  DateTime _lastVoiceTime = DateTime.now().subtract(const Duration(seconds: 10));
  String _lastVoiceMsg = '';

  int get repCount => _repCount;
  double get formScore => _formScore;

  void reset() {
    _repCount = 0;
    _repState = "READY";
    _formScore = 95.0;
    _status = "GOOD";
    _feedbackMessage = "Ready - Stand in camera view";
    _activeJointAngle = 180.0;
    _holdTicks = 0;
    _lastVoiceMsg = '';
    _jointEvaluations = {};
    _boneEvaluations = {};
  }

  /// Calculates 2D angle (in degrees) between three points with vertex at `b`.
  static double calculateAngle(
    PoseLandmark a,
    PoseLandmark b,
    PoseLandmark c,
  ) {
    return calculatePointAngle(
      BiometricPoint.fromPoseLandmark(a),
      BiometricPoint.fromPoseLandmark(b),
      BiometricPoint.fromPoseLandmark(c),
    );
  }

  /// Calculates 2D angle (in degrees) between three biometric points with vertex at `b`.
  static double calculatePointAngle(
    BiometricPoint a,
    BiometricPoint b,
    BiometricPoint c,
  ) {
    final double baX = a.x - b.x;
    final double baY = a.y - b.y;
    final double bcX = c.x - b.x;
    final double bcY = c.y - b.y;

    final double dot = (baX * bcX) + (baY * bcY);
    final double magBA = math.sqrt(baX * baX + baY * baY);
    final double magBC = math.sqrt(bcX * bcX + bcY * bcY);

    if (magBA * magBC == 0) return 0.0;

    final double cosine = (dot / (magBA * magBC)).clamp(-1.0, 1.0);
    final double radians = math.acos(cosine);
    return (radians * 180.0 / math.pi);
  }

  /// Analyzes a detected pose from MediaPipe / ML Kit
  PoseAnalysisResult analyzePose({
    required Pose pose,
    required String exerciseKey,
    required bool isYoga,
  }) {
    final lm = pose.landmarks;

    BiometricPoint? getPt(PoseLandmarkType type, {double minLikelihood = 0.45}) {
      final p = lm[type];
      if (p == null || p.likelihood < minLikelihood) return null;
      return BiometricPoint.fromPoseLandmark(p);
    }

    return _evaluateBiometrics(
      exerciseKey: exerciseKey,
      isYoga: isYoga,
      nose: getPt(PoseLandmarkType.nose, minLikelihood: 0.25),
      lShoulder: getPt(PoseLandmarkType.leftShoulder),
      rShoulder: getPt(PoseLandmarkType.rightShoulder),
      lElbow: getPt(PoseLandmarkType.leftElbow),
      rElbow: getPt(PoseLandmarkType.rightElbow),
      lWrist: getPt(PoseLandmarkType.leftWrist),
      rWrist: getPt(PoseLandmarkType.rightWrist),
      lHip: getPt(PoseLandmarkType.leftHip),
      rHip: getPt(PoseLandmarkType.rightHip),
      lKnee: getPt(PoseLandmarkType.leftKnee),
      rKnee: getPt(PoseLandmarkType.rightKnee),
      lAnkle: getPt(PoseLandmarkType.leftAnkle),
      rAnkle: getPt(PoseLandmarkType.rightAnkle),
    );
  }

  /// Analyzes normalized landmark dictionary (used for simulation and custom inputs)
  PoseAnalysisResult analyzeLandmarkPoints({
    required Map<String, dynamic> points,
    required String exerciseKey,
    required bool isYoga,
  }) {
    BiometricPoint? getPt(String key) {
      final p = points[key];
      if (p == null) return null;
      if (p is BiometricPoint) return p;
      return BiometricPoint(
        x: (p.x as num).toDouble(),
        y: (p.y as num).toDouble(),
        confidence: (p.confidence as num?)?.toDouble() ?? 1.0,
      );
    }

    return _evaluateBiometrics(
      exerciseKey: exerciseKey,
      isYoga: isYoga,
      nose: getPt('NOSE'),
      lShoulder: getPt('LEFT_SHOULDER'),
      rShoulder: getPt('RIGHT_SHOULDER'),
      lElbow: getPt('LEFT_ELBOW'),
      rElbow: getPt('RIGHT_ELBOW'),
      lWrist: getPt('LEFT_WRIST'),
      rWrist: getPt('RIGHT_WRIST'),
      lHip: getPt('LEFT_HIP'),
      rHip: getPt('RIGHT_HIP'),
      lKnee: getPt('LEFT_KNEE'),
      rKnee: getPt('RIGHT_KNEE'),
      lAnkle: getPt('LEFT_ANKLE'),
      rAnkle: getPt('RIGHT_ANKLE'),
    );
  }

  PoseAnalysisResult _evaluateBiometrics({
    required String exerciseKey,
    required bool isYoga,
    BiometricPoint? nose,
    BiometricPoint? lShoulder,
    BiometricPoint? rShoulder,
    BiometricPoint? lElbow,
    BiometricPoint? rElbow,
    BiometricPoint? lWrist,
    BiometricPoint? rWrist,
    BiometricPoint? lHip,
    BiometricPoint? rHip,
    BiometricPoint? lKnee,
    BiometricPoint? rKnee,
    BiometricPoint? lAnkle,
    BiometricPoint? rAnkle,
  }) {
    _jointEvaluations = {};
    _boneEvaluations = {};
    bool repCompleted = false;
    String? voiceCue;

    if (isYoga) {
      _analyzeYogaPose(
        exerciseKey: exerciseKey,
        nose: nose,
        lShoulder: lShoulder,
        rShoulder: rShoulder,
        lElbow: lElbow,
        rElbow: rElbow,
        lWrist: lWrist,
        rWrist: rWrist,
        lHip: lHip,
        rHip: rHip,
        lKnee: lKnee,
        rKnee: rKnee,
        lAnkle: lAnkle,
        rAnkle: rAnkle,
      );
    } else {
      switch (exerciseKey) {
        case 'squat':
          repCompleted = _analyzeSquat(
            lHip: lHip,
            rHip: rHip,
            lKnee: lKnee,
            rKnee: rKnee,
            lAnkle: lAnkle,
            rAnkle: rAnkle,
            lShoulder: lShoulder,
            rShoulder: rShoulder,
          );
          break;

        case 'pushup':
          repCompleted = _analyzePushup(
            lShoulder: lShoulder,
            rShoulder: rShoulder,
            lElbow: lElbow,
            rElbow: rElbow,
            lWrist: lWrist,
            rWrist: rWrist,
            lHip: lHip,
            rHip: rHip,
            lAnkle: lAnkle,
            rAnkle: rAnkle,
          );
          break;

        case 'bicep_curl':
          repCompleted = _analyzeBicepCurl(
            lShoulder: lShoulder,
            rShoulder: rShoulder,
            lElbow: lElbow,
            rElbow: rElbow,
            lWrist: lWrist,
            rWrist: rWrist,
            lHip: lHip,
            rHip: rHip,
          );
          break;

        case 'lunge':
          repCompleted = _analyzeLunge(
            lHip: lHip,
            rHip: rHip,
            lKnee: lKnee,
            rKnee: rKnee,
            lAnkle: lAnkle,
            rAnkle: rAnkle,
            lShoulder: lShoulder,
            rShoulder: rShoulder,
          );
          break;

        case 'plank':
          _analyzePlank(
            lShoulder: lShoulder,
            rShoulder: rShoulder,
            lHip: lHip,
            rHip: rHip,
            lAnkle: lAnkle,
            rAnkle: rAnkle,
          );
          break;

        default:
          _activeJointName = "Posture Tracking";
          _status = "GOOD";
          _feedbackMessage = "Tracking active";
      }
    }

    if (repCompleted) {
      voiceCue = "Rep $_repCount! Good form.";
    } else {
      // Throttle form alerts to voice every 4 seconds
      final now = DateTime.now();
      if (_status != "GOOD" &&
          _feedbackMessage != _lastVoiceMsg &&
          now.difference(_lastVoiceTime).inSeconds >= 4) {
        voiceCue = _feedbackMessage;
        _lastVoiceTime = now;
        _lastVoiceMsg = _feedbackMessage;
      }
    }

    return PoseAnalysisResult(
      repCount: _repCount,
      formScore: _formScore,
      status: _status,
      feedbackMessage: _feedbackMessage,
      repState: _repState,
      activeJointName: _activeJointName,
      activeJointAngle: _activeJointAngle,
      repCompletedJustNow: repCompleted,
      voiceCue: voiceCue,
      holdSeconds: (_holdTicks ~/ 15),
      jointEvaluations: _jointEvaluations,
      boneEvaluations: _boneEvaluations,
    );
  }

  // ===================== SQUAT ANALYSIS =====================
  bool _analyzeSquat({
    BiometricPoint? lHip,
    BiometricPoint? rHip,
    BiometricPoint? lKnee,
    BiometricPoint? rKnee,
    BiometricPoint? lAnkle,
    BiometricPoint? rAnkle,
    BiometricPoint? lShoulder,
    BiometricPoint? rShoulder,
  }) {
    if ((lHip == null || lKnee == null || lAnkle == null) &&
        (rHip == null || rKnee == null || rAnkle == null)) {
      _feedbackMessage = "Step back so legs are visible in camera";
      _status = "WARNING";
      return false;
    }

    double? lKneeAngle;
    double? rKneeAngle;
    if (lHip != null && lKnee != null && lAnkle != null) {
      lKneeAngle = calculatePointAngle(lHip, lKnee, lAnkle);
    }
    if (rHip != null && rKnee != null && rAnkle != null) {
      rKneeAngle = calculatePointAngle(rHip, rKnee, rAnkle);
    }

    double avgKneeAngle = 180.0;
    if (lKneeAngle != null && rKneeAngle != null) {
      avgKneeAngle = (lKneeAngle + rKneeAngle) / 2.0;
    } else {
      avgKneeAngle = lKneeAngle ?? rKneeAngle ?? 180.0;
    }

    _activeJointName = "Knee Flexion";
    _activeJointAngle = avgKneeAngle;

    // Check Torso angle (back rounding / folding)
    bool isBackRounding = false;
    final shoulder = lShoulder ?? rShoulder;
    final hip = lHip ?? rHip;
    final knee = lKnee ?? rKnee;
    if (shoulder != null && hip != null && knee != null) {
      final torsoAngle = calculatePointAngle(shoulder, hip, knee);
      if (torsoAngle < 55.0 && avgKneeAngle < 130.0) {
        isBackRounding = true;
      }
    }

    // Check knee caving (valgus) if both knees and hips are visible
    bool isKneesCaving = false;
    if (lKnee != null && rKnee != null && lHip != null && rHip != null) {
      final kneeDistance = (lKnee.x - rKnee.x).abs();
      final hipDistance = (lHip.x - rHip.x).abs();
      if (kneeDistance < hipDistance * 0.72 && avgKneeAngle < 125.0) {
        isKneesCaving = true;
      }
    }

    bool repScored = false;

    // Evaluate knee status
    JointFormStatus kneeStatus;
    String kneeFeedback;
    if (avgKneeAngle > 155.0) {
      kneeStatus = JointFormStatus.good;
      kneeFeedback = "Standing - Ready";
      if (_repState == "DOWN") {
        _repCount++;
        _repState = "UP";
        _status = "GOOD";
        _formScore = (_formScore * 0.85 + 98.0 * 0.15).clamp(70.0, 100.0);
        _feedbackMessage = "✓ Rep $_repCount complete! Great depth.";
        repScored = true;
      } else {
        _repState = "READY";
        _status = "GOOD";
        _feedbackMessage = "Squat down by pushing hips back";
      }
    } else if (avgKneeAngle <= 98.0) {
      _repState = "DOWN";
      if (isBackRounding) {
        kneeStatus = JointFormStatus.warning;
        kneeFeedback = "Good depth, but chest leaning forward";
        _status = "INCORRECT";
        _formScore = (_formScore - 1.5).clamp(50.0, 100.0);
        _feedbackMessage = "⚠️ Keep chest up! Don't round your lower back.";
      } else if (isKneesCaving) {
        kneeStatus = JointFormStatus.incorrect;
        kneeFeedback = "Knees caving inward!";
        _status = "WARNING";
        _formScore = (_formScore - 1.0).clamp(50.0, 100.0);
        _feedbackMessage = "⚠️ Push knees outward! Keep in line with toes.";
      } else {
        kneeStatus = JointFormStatus.good;
        kneeFeedback = "✓ Optimal 90° depth! Drive up.";
        _status = "GOOD";
        _feedbackMessage = "✓ Excellent depth! Now drive up through heels.";
      }
    } else if (avgKneeAngle < 140.0) {
      if (isBackRounding) {
        kneeStatus = JointFormStatus.warning;
        kneeFeedback = "Spine leaning forward";
        _status = "INCORRECT";
        _feedbackMessage = "⚠️ Keep chest proud and spine neutral.";
      } else {
        kneeStatus = JointFormStatus.neutral;
        kneeFeedback = "Descend lower to parallel";
        _status = "GOOD";
        _feedbackMessage = "Go a bit lower until thighs are parallel.";
      }
    } else {
      kneeStatus = JointFormStatus.neutral;
      kneeFeedback = "Initiate squat";
    }

    // Register joint evaluations
    if (lKneeAngle != null) {
      _jointEvaluations['LEFT_KNEE'] = JointEvaluation(
        landmarkName: 'LEFT_KNEE',
        angle: lKneeAngle,
        status: isKneesCaving ? JointFormStatus.incorrect : kneeStatus,
        feedback: kneeFeedback,
        label: "Knee ${lKneeAngle.toInt()}°",
      );
    }
    if (rKneeAngle != null) {
      _jointEvaluations['RIGHT_KNEE'] = JointEvaluation(
        landmarkName: 'RIGHT_KNEE',
        angle: rKneeAngle,
        status: isKneesCaving ? JointFormStatus.incorrect : kneeStatus,
        feedback: kneeFeedback,
        label: "Knee ${rKneeAngle.toInt()}°",
      );
    }

    if (hip != null) {
      _jointEvaluations['LEFT_HIP'] = JointEvaluation(
        landmarkName: 'LEFT_HIP',
        angle: avgKneeAngle,
        status: isBackRounding ? JointFormStatus.incorrect : JointFormStatus.good,
        feedback: isBackRounding ? "Hips hinged too low / chest collapsed" : "Hips hinged",
        label: "Hip",
      );
    }

    // Register bone statuses
    final legBoneStatus = isKneesCaving ? JointFormStatus.incorrect : kneeStatus;
    _boneEvaluations['LEFT_HIP_LEFT_KNEE'] = legBoneStatus;
    _boneEvaluations['LEFT_KNEE_LEFT_ANKLE'] = legBoneStatus;
    _boneEvaluations['RIGHT_HIP_RIGHT_KNEE'] = legBoneStatus;
    _boneEvaluations['RIGHT_KNEE_RIGHT_ANKLE'] = legBoneStatus;
    _boneEvaluations['LEFT_SHOULDER_LEFT_HIP'] = isBackRounding ? JointFormStatus.incorrect : JointFormStatus.good;
    _boneEvaluations['RIGHT_SHOULDER_RIGHT_HIP'] = isBackRounding ? JointFormStatus.incorrect : JointFormStatus.good;

    return repScored;
  }

  // ===================== PUSHUP ANALYSIS =====================
  bool _analyzePushup({
    BiometricPoint? lShoulder,
    BiometricPoint? rShoulder,
    BiometricPoint? lElbow,
    BiometricPoint? rElbow,
    BiometricPoint? lWrist,
    BiometricPoint? rWrist,
    BiometricPoint? lHip,
    BiometricPoint? rHip,
    BiometricPoint? lAnkle,
    BiometricPoint? rAnkle,
  }) {
    if ((lShoulder == null || lElbow == null || lWrist == null) &&
        (rShoulder == null || rElbow == null || rWrist == null)) {
      _feedbackMessage = "Ensure upper body & arms are visible";
      _status = "WARNING";
      return false;
    }

    double? lElbowAngle;
    double? rElbowAngle;
    if (lShoulder != null && lElbow != null && lWrist != null) {
      lElbowAngle = calculatePointAngle(lShoulder, lElbow, lWrist);
    }
    if (rShoulder != null && rElbow != null && rWrist != null) {
      rElbowAngle = calculatePointAngle(rShoulder, rElbow, rWrist);
    }

    final double avgElbowAngle = (lElbowAngle != null && rElbowAngle != null)
        ? (lElbowAngle + rElbowAngle) / 2.0
        : (lElbowAngle ?? rElbowAngle ?? 180.0);

    _activeJointName = "Elbow Flexion";
    _activeJointAngle = avgElbowAngle;

    // Check Plank Line / Sagging Hips (Shoulder-Hip-Ankle collinearity)
    bool isHipSagging = false;
    bool isHipPiking = false;
    final shoulder = lShoulder ?? rShoulder;
    final hip = lHip ?? rHip;
    final ankle = lAnkle ?? rAnkle;
    if (shoulder != null && hip != null && ankle != null) {
      final spineAngle = calculatePointAngle(shoulder, hip, ankle);
      if (spineAngle < 150.0) {
        isHipSagging = true;
      } else if (spineAngle > 195.0) {
        isHipPiking = true;
      }
    }

    bool repScored = false;
    JointFormStatus armStatus;
    String armFeedback;

    if (avgElbowAngle > 155.0) {
      armStatus = JointFormStatus.good;
      armFeedback = "Arms extended";
      if (_repState == "DOWN") {
        _repCount++;
        _repState = "UP";
        _status = "GOOD";
        _formScore = (_formScore * 0.85 + 96.0 * 0.15).clamp(70.0, 100.0);
        _feedbackMessage = "✓ Pushup rep $_repCount logged! Full lockout.";
        repScored = true;
      } else {
        _repState = "READY";
        _status = "GOOD";
        _feedbackMessage = "Lower chest toward floor";
      }
    } else if (avgElbowAngle <= 92.0) {
      _repState = "DOWN";
      if (isHipSagging) {
        armStatus = JointFormStatus.warning;
        armFeedback = "Elbow 90° reached, but hips sagging!";
        _status = "INCORRECT";
        _formScore = (_formScore - 2.0).clamp(50.0, 100.0);
        _feedbackMessage = "⚠️ Core tight! Don't let your hips sag down.";
      } else if (isHipPiking) {
        armStatus = JointFormStatus.warning;
        armFeedback = "Elbow 90° reached, but hips too high";
        _status = "WARNING";
        _feedbackMessage = "⚠️ Lower hips into straight plank position.";
      } else {
        armStatus = JointFormStatus.good;
        armFeedback = "✓ 90° elbow depth reached!";
        _status = "GOOD";
        _feedbackMessage = "✓ 90° elbow depth reached! Push back up.";
      }
    } else {
      armStatus = JointFormStatus.neutral;
      armFeedback = "Descending - Lower chest";
    }

    // Register joint evaluations
    if (lElbowAngle != null) {
      _jointEvaluations['LEFT_ELBOW'] = JointEvaluation(
        landmarkName: 'LEFT_ELBOW',
        angle: lElbowAngle,
        status: armStatus,
        feedback: armFeedback,
        label: "Elbow ${lElbowAngle.toInt()}°",
      );
    }
    if (rElbowAngle != null) {
      _jointEvaluations['RIGHT_ELBOW'] = JointEvaluation(
        landmarkName: 'RIGHT_ELBOW',
        angle: rElbowAngle,
        status: armStatus,
        feedback: armFeedback,
        label: "Elbow ${rElbowAngle.toInt()}°",
      );
    }

    final spineStatus = (isHipSagging || isHipPiking)
        ? JointFormStatus.incorrect
        : JointFormStatus.good;

    if (hip != null) {
      _jointEvaluations['LEFT_HIP'] = JointEvaluation(
        landmarkName: 'LEFT_HIP',
        angle: 180.0,
        status: spineStatus,
        feedback: isHipSagging ? "Hips sagging" : (isHipPiking ? "Hips piking" : "Spine locked"),
        label: "Core",
      );
    }

    _boneEvaluations['LEFT_SHOULDER_LEFT_ELBOW'] = armStatus;
    _boneEvaluations['LEFT_ELBOW_LEFT_WRIST'] = armStatus;
    _boneEvaluations['RIGHT_SHOULDER_RIGHT_ELBOW'] = armStatus;
    _boneEvaluations['RIGHT_ELBOW_RIGHT_WRIST'] = armStatus;
    _boneEvaluations['LEFT_SHOULDER_LEFT_HIP'] = spineStatus;
    _boneEvaluations['LEFT_HIP_LEFT_ANKLE'] = spineStatus;

    return repScored;
  }

  // ===================== BICEP CURL ANALYSIS =====================
  bool _analyzeBicepCurl({
    BiometricPoint? lShoulder,
    BiometricPoint? rShoulder,
    BiometricPoint? lElbow,
    BiometricPoint? rElbow,
    BiometricPoint? lWrist,
    BiometricPoint? rWrist,
    BiometricPoint? lHip,
    BiometricPoint? rHip,
  }) {
    double? lElbowAngle;
    double? rElbowAngle;

    if (lShoulder != null && lElbow != null && lWrist != null) {
      lElbowAngle = calculatePointAngle(lShoulder, lElbow, lWrist);
    }
    if (rShoulder != null && rElbow != null && rWrist != null) {
      rElbowAngle = calculatePointAngle(rShoulder, rElbow, rWrist);
    }

    if (lElbowAngle == null && rElbowAngle == null) {
      _feedbackMessage = "Keep arms visible to track curls";
      _status = "WARNING";
      return false;
    }

    // Choose lead arm (most active / lowest angle)
    final double minAngle = math.min(lElbowAngle ?? 180.0, rElbowAngle ?? 180.0);
    _activeJointName = "Elbow Flexion";
    _activeJointAngle = minAngle;

    // Check elbow flare / swinging (shoulder angle opening)
    bool isElbowSwinging = false;
    final shoulder = lShoulder ?? rShoulder;
    final elbow = lElbow ?? rElbow;
    final hip = lHip ?? rHip;
    if (shoulder != null && elbow != null && hip != null) {
      final shoulderFlare = calculatePointAngle(hip, shoulder, elbow);
      if (shoulderFlare > 38.0) {
        isElbowSwinging = true;
      }
    }

    bool repScored = false;
    JointFormStatus curlStatus;
    String curlFeedback;

    if (minAngle > 145.0) {
      curlStatus = JointFormStatus.good;
      curlFeedback = "Full extension";
      if (_repState == "DOWN") {
        _repCount++;
        _repState = "UP";
        _status = "GOOD";
        _formScore = (_formScore * 0.85 + 97.0 * 0.15).clamp(70.0, 100.0);
        _feedbackMessage = "✓ Curl rep $_repCount complete!";
        repScored = true;
      } else {
        _repState = "READY";
        _status = "GOOD";
        _feedbackMessage = "Curl weights upward smoothly";
      }
    } else if (minAngle <= 55.0) {
      _repState = "DOWN";
      if (isElbowSwinging) {
        curlStatus = JointFormStatus.warning;
        curlFeedback = "Elbows flaring / swinging!";
        _status = "WARNING";
        _formScore = (_formScore - 1.0).clamp(50.0, 100.0);
        _feedbackMessage = "⚠️ Keep elbows pinned to your sides!";
      } else {
        curlStatus = JointFormStatus.good;
        curlFeedback = "✓ Peak bicep contraction!";
        _status = "GOOD";
        _feedbackMessage = "✓ Peak squeeze! Lower weights under control.";
      }
    } else {
      curlStatus = JointFormStatus.neutral;
      curlFeedback = "Curling";
    }

    if (lElbowAngle != null) {
      _jointEvaluations['LEFT_ELBOW'] = JointEvaluation(
        landmarkName: 'LEFT_ELBOW',
        angle: lElbowAngle,
        status: isElbowSwinging ? JointFormStatus.warning : curlStatus,
        feedback: curlFeedback,
        label: "Curl ${lElbowAngle.toInt()}°",
      );
      _boneEvaluations['LEFT_SHOULDER_LEFT_ELBOW'] = isElbowSwinging ? JointFormStatus.warning : curlStatus;
      _boneEvaluations['LEFT_ELBOW_LEFT_WRIST'] = curlStatus;
    }

    if (rElbowAngle != null) {
      _jointEvaluations['RIGHT_ELBOW'] = JointEvaluation(
        landmarkName: 'RIGHT_ELBOW',
        angle: rElbowAngle,
        status: isElbowSwinging ? JointFormStatus.warning : curlStatus,
        feedback: curlFeedback,
        label: "Curl ${rElbowAngle.toInt()}°",
      );
      _boneEvaluations['RIGHT_SHOULDER_RIGHT_ELBOW'] = isElbowSwinging ? JointFormStatus.warning : curlStatus;
      _boneEvaluations['RIGHT_ELBOW_RIGHT_WRIST'] = curlStatus;
    }

    return repScored;
  }

  // ===================== LUNGE ANALYSIS =====================
  bool _analyzeLunge({
    BiometricPoint? lHip,
    BiometricPoint? rHip,
    BiometricPoint? lKnee,
    BiometricPoint? rKnee,
    BiometricPoint? lAnkle,
    BiometricPoint? rAnkle,
    BiometricPoint? lShoulder,
    BiometricPoint? rShoulder,
  }) {
    if (lHip == null || lKnee == null || lAnkle == null ||
        rHip == null || rKnee == null || rAnkle == null) {
      _feedbackMessage = "Position whole body side-on to camera";
      _status = "WARNING";
      return false;
    }

    final lKneeAngle = calculatePointAngle(lHip, lKnee, lAnkle);
    final rKneeAngle = calculatePointAngle(rHip, rKnee, rAnkle);
    final isLeftLead = lKneeAngle < rKneeAngle;
    final leadAngle = isLeftLead ? lKneeAngle : rKneeAngle;

    _activeJointName = "Lead Knee Angle";
    _activeJointAngle = leadAngle;

    bool repScored = false;
    JointFormStatus lungeStatus;
    String lungeFeedback;

    if (leadAngle > 145.0) {
      lungeStatus = JointFormStatus.good;
      lungeFeedback = "Standing upright";
      if (_repState == "DOWN") {
        _repCount++;
        _repState = "UP";
        _status = "GOOD";
        _feedbackMessage = "✓ Lunge rep $_repCount complete!";
        repScored = true;
      } else {
        _repState = "READY";
        _status = "GOOD";
        _feedbackMessage = "Step forward and lower hips into lunge";
      }
    } else if (leadAngle <= 95.0) {
      _repState = "DOWN";
      lungeStatus = JointFormStatus.good;
      lungeFeedback = "✓ 90° optimal lunge depth!";
      _status = "GOOD";
      _feedbackMessage = "✓ 90° lunge depth! Push back through lead heel.";
    } else {
      lungeStatus = JointFormStatus.neutral;
      lungeFeedback = "Lower hips into 90° angle";
    }

    _jointEvaluations[isLeftLead ? 'LEFT_KNEE' : 'RIGHT_KNEE'] = JointEvaluation(
      landmarkName: isLeftLead ? 'LEFT_KNEE' : 'RIGHT_KNEE',
      angle: leadAngle,
      status: lungeStatus,
      feedback: lungeFeedback,
      label: "Lead ${leadAngle.toInt()}°",
    );

    _boneEvaluations['LEFT_HIP_LEFT_KNEE'] = lungeStatus;
    _boneEvaluations['LEFT_KNEE_LEFT_ANKLE'] = lungeStatus;
    _boneEvaluations['RIGHT_HIP_RIGHT_KNEE'] = lungeStatus;
    _boneEvaluations['RIGHT_KNEE_RIGHT_ANKLE'] = lungeStatus;

    return repScored;
  }

  // ===================== PLANK ANALYSIS =====================
  void _analyzePlank({
    BiometricPoint? lShoulder,
    BiometricPoint? rShoulder,
    BiometricPoint? lHip,
    BiometricPoint? rHip,
    BiometricPoint? lAnkle,
    BiometricPoint? rAnkle,
  }) {
    _activeJointName = "Spine Alignment";
    _repState = "HOLDING";

    final shoulder = lShoulder ?? rShoulder;
    final hip = lHip ?? rHip;
    final ankle = lAnkle ?? rAnkle;

    if (shoulder == null || hip == null || ankle == null) {
      _feedbackMessage = "Position whole body in camera frame";
      _status = "WARNING";
      return;
    }

    final spineAngle = calculatePointAngle(shoulder, hip, ankle);
    _activeJointAngle = spineAngle;
    _holdTicks++;

    JointFormStatus plankStatus;
    String plankFeedback;

    if (spineAngle < 152.0) {
      plankStatus = JointFormStatus.incorrect;
      plankFeedback = "Hips sagging!";
      _status = "INCORRECT";
      _formScore = (_formScore - 0.5).clamp(50.0, 100.0);
      _feedbackMessage = "⚠️ Hips sagging! Engage abs and squeeze glutes.";
    } else if (spineAngle > 195.0) {
      plankStatus = JointFormStatus.warning;
      plankFeedback = "Hips too high";
      _status = "WARNING";
      _feedbackMessage = "⚠️ Hips too high! Lower slightly into straight line.";
    } else {
      plankStatus = JointFormStatus.good;
      plankFeedback = "✓ Perfect straight spine";
      _status = "GOOD";
      _feedbackMessage = "✓ Perfect straight line plank! Hold steady.";
    }

    _jointEvaluations['LEFT_HIP'] = JointEvaluation(
      landmarkName: 'LEFT_HIP',
      angle: spineAngle,
      status: plankStatus,
      feedback: plankFeedback,
      label: "Spine ${spineAngle.toInt()}°",
    );

    _boneEvaluations['LEFT_SHOULDER_LEFT_HIP'] = plankStatus;
    _boneEvaluations['RIGHT_SHOULDER_RIGHT_HIP'] = plankStatus;
    _boneEvaluations['LEFT_HIP_LEFT_ANKLE'] = plankStatus;
    _boneEvaluations['RIGHT_HIP_RIGHT_ANKLE'] = plankStatus;
  }

  // ===================== YOGA POSES =====================
  void _analyzeYogaPose({
    required String exerciseKey,
    BiometricPoint? nose,
    BiometricPoint? lShoulder,
    BiometricPoint? rShoulder,
    BiometricPoint? lElbow,
    BiometricPoint? rElbow,
    BiometricPoint? lWrist,
    BiometricPoint? rWrist,
    BiometricPoint? lHip,
    BiometricPoint? rHip,
    BiometricPoint? lKnee,
    BiometricPoint? rKnee,
    BiometricPoint? lAnkle,
    BiometricPoint? rAnkle,
  }) {
    _holdTicks++;
    _repState = "HOLDING";

    switch (exerciseKey) {
      case 'tree_pose':
        _activeJointName = "Balance & Knee Flare";
        if (lKnee != null && rKnee != null && lHip != null && rHip != null && lAnkle != null && rAnkle != null) {
          final lAngle = calculatePointAngle(lHip, lKnee, lAnkle);
          final rAngle = calculatePointAngle(rHip, rKnee, rAnkle);
          final isLeftStanding = lAngle > rAngle;
          final standingAngle = isLeftStanding ? lAngle : rAngle;
          final bentAngle = isLeftStanding ? rAngle : lAngle;

          _activeJointAngle = bentAngle;

          final bool isBalanceGood = standingAngle > 155.0 && bentAngle < 110.0;
          final status = isBalanceGood ? JointFormStatus.good : JointFormStatus.warning;

          _jointEvaluations[isLeftStanding ? 'RIGHT_KNEE' : 'LEFT_KNEE'] = JointEvaluation(
            landmarkName: isLeftStanding ? 'RIGHT_KNEE' : 'LEFT_KNEE',
            angle: bentAngle,
            status: status,
            feedback: isBalanceGood ? "Good knee flare" : "Place foot on inner thigh",
            label: "Flare ${bentAngle.toInt()}°",
          );

          _jointEvaluations[isLeftStanding ? 'LEFT_KNEE' : 'RIGHT_KNEE'] = JointEvaluation(
            landmarkName: isLeftStanding ? 'LEFT_KNEE' : 'RIGHT_KNEE',
            angle: standingAngle,
            status: standingAngle > 155.0 ? JointFormStatus.good : JointFormStatus.warning,
            feedback: "Standing pillar",
            label: "Base ${standingAngle.toInt()}°",
          );

          if (isBalanceGood) {
            _status = "GOOD";
            _formScore = (_formScore * 0.9 + 98.0 * 0.1).clamp(70.0, 100.0);
            _feedbackMessage = "✓ Tree Pose: Excellent balance and hip opening!";
          } else {
            _status = "WARNING";
            _feedbackMessage = "Place foot on inner calf/thigh and steady focus";
          }

          _boneEvaluations['LEFT_HIP_LEFT_KNEE'] = status;
          _boneEvaluations['RIGHT_HIP_RIGHT_KNEE'] = status;
        }
        break;

      case 'warrior_2':
        _activeJointName = "Lead Knee & Arm Span";
        if (lKnee != null && rKnee != null && lHip != null && rHip != null && lAnkle != null && rAnkle != null) {
          final lAngle = calculatePointAngle(lHip, lKnee, lAnkle);
          final rAngle = calculatePointAngle(rHip, rKnee, rAnkle);
          final minKnee = math.min(lAngle, rAngle);
          final maxKnee = math.max(lAngle, rAngle);
          final isLeftFront = lAngle < rAngle;

          _activeJointAngle = minKnee;

          final bool isKneeDepthGood = minKnee <= 105.0;
          final bool isBackLegStraight = maxKnee >= 155.0;

          _jointEvaluations[isLeftFront ? 'LEFT_KNEE' : 'RIGHT_KNEE'] = JointEvaluation(
            landmarkName: isLeftFront ? 'LEFT_KNEE' : 'RIGHT_KNEE',
            angle: minKnee,
            status: isKneeDepthGood ? JointFormStatus.good : JointFormStatus.warning,
            feedback: isKneeDepthGood ? "Front knee 90°" : "Sink deeper into front knee",
            label: "Front ${minKnee.toInt()}°",
          );

          _jointEvaluations[isLeftFront ? 'RIGHT_KNEE' : 'LEFT_KNEE'] = JointEvaluation(
            landmarkName: isLeftFront ? 'RIGHT_KNEE' : 'LEFT_KNEE',
            angle: maxKnee,
            status: isBackLegStraight ? JointFormStatus.good : JointFormStatus.warning,
            feedback: "Back leg straight",
            label: "Back ${maxKnee.toInt()}°",
          );

          if (isKneeDepthGood && isBackLegStraight) {
            _status = "GOOD";
            _formScore = (_formScore * 0.9 + 97.0 * 0.1).clamp(70.0, 100.0);
            _feedbackMessage = "✓ Warrior II: Deep stance, arms parallel to floor!";
          } else {
            _status = "WARNING";
            _feedbackMessage = "Sink deeper into front knee (aim for 90°)";
          }

          _boneEvaluations['LEFT_HIP_LEFT_KNEE'] = isKneeDepthGood ? JointFormStatus.good : JointFormStatus.warning;
          _boneEvaluations['RIGHT_HIP_RIGHT_KNEE'] = isBackLegStraight ? JointFormStatus.good : JointFormStatus.warning;
        }
        break;

      case 'downward_dog':
        _activeJointName = "Inverted V Apex";
        if (lShoulder != null && lHip != null && lAnkle != null) {
          final hipAngle = calculatePointAngle(lShoulder, lHip, lAnkle);
          _activeJointAngle = hipAngle;

          final bool isApexGood = hipAngle >= 60.0 && hipAngle <= 95.0;
          final status = isApexGood ? JointFormStatus.good : JointFormStatus.warning;

          _jointEvaluations['LEFT_HIP'] = JointEvaluation(
            landmarkName: 'LEFT_HIP',
            angle: hipAngle,
            status: status,
            feedback: isApexGood ? "Strong inverted V apex" : "Push hips back and up",
            label: "Apex ${hipAngle.toInt()}°",
          );

          if (isApexGood) {
            _status = "GOOD";
            _formScore = (_formScore * 0.9 + 98.0 * 0.1).clamp(70.0, 100.0);
            _feedbackMessage = "✓ Downward Dog: Press palms down, spine elongated.";
          } else {
            _status = "WARNING";
            _feedbackMessage = "Push hips back and up toward ceiling";
          }

          _boneEvaluations['LEFT_SHOULDER_LEFT_HIP'] = status;
          _boneEvaluations['LEFT_HIP_LEFT_ANKLE'] = status;
        }
        break;

      case 'cobra_pose':
      default:
        _activeJointName = "Chest & Spine Arc";
        if (lShoulder != null && lHip != null && lKnee != null) {
          final archAngle = calculatePointAngle(lShoulder, lHip, lKnee);
          _activeJointAngle = archAngle;
          _status = "GOOD";
          _feedbackMessage = "✓ Cobra Pose: Roll shoulders back, breathe deeply.";

          _jointEvaluations['LEFT_HIP'] = JointEvaluation(
            landmarkName: 'LEFT_HIP',
            angle: archAngle,
            status: JointFormStatus.good,
            feedback: "Spine arch",
            label: "Arch ${archAngle.toInt()}°",
          );

          _boneEvaluations['LEFT_SHOULDER_LEFT_HIP'] = JointFormStatus.good;
        }
    }
  }
}
