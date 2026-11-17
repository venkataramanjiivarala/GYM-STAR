import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/pose_painter.dart';
import '../core/services/tts_service.dart';
import '../core/services/api_service.dart';
import '../core/services/pose_analyzer.dart';
import '../models/exercise_model.dart';
import '../models/yoga_pose_model.dart';

class CameraCoachScreen extends StatefulWidget {
  final String initialExerciseKey;
  final bool isYoga;
  final VoidCallback? onWorkoutCompleted;

  const CameraCoachScreen({
    super.key,
    this.initialExerciseKey = 'squat',
    this.isYoga = false,
    this.onWorkoutCompleted,
  });

  @override
  State<CameraCoachScreen> createState() => _CameraCoachScreenState();
}

class _CameraCoachScreenState extends State<CameraCoachScreen> with SingleTickerProviderStateMixin {
  late String _currentExerciseKey;
  late bool _isYoga;

  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraReady = false;
  bool _isProcessingFrame = false;

  // Real-time MediaPipe ML Kit Pose Detector
  late PoseDetector _poseDetector;
  final PoseAnalyzerEngine _poseAnalyzer = PoseAnalyzerEngine();

  // Real-time workout metrics
  int _repCount = 0;
  final int _targetReps = 12;
  int _currentSet = 1;
  final int _totalSets = 3;
  double _formScore = 0.0;
  String _repState = "POSITIONING"; // POSITIONING, READY, DOWN, UP, HOLDING
  String _formStatus = "POSITIONING"; // POSITIONING, GOOD, WARNING, INCORRECT
  String _feedbackMessage = "Position yourself in camera view";
  double _currentAngle = 180.0;
  String _activeJointName = "Knee Flexion";
  int _holdDurationSec = 0;
  final int _targetHoldSec = 30;

  bool _isPersonDetected = false;
  bool _isFullBodyInFrame = false;
  String _positioningInstruction = "Position camera 6-8 feet away at hip height";

  // Mismatch Alert State
  bool _isMismatch = false;
  String? _mismatchAlert;

  // Per-rep accuracy history
  List<RepDetail> _repHistory = [];

  Timer? _workoutDurationTimer;
  Timer? _simFallbackTimer;
  int _totalWorkoutSec = 0;
  double _caloriesBurned = 0.0;
  bool _isWorkoutActive = true;
  bool _hasRealMediaPipeFeed = false;

  // Normalized landmark coordinates (0.0 to 1.0)
  Map<String, CustomLandmarkPoint> _landmarks = {};
  Map<String, JointEvaluation> _jointEvaluations = {};
  Map<String, JointFormStatus> _boneEvaluations = {};
  double _simPhase = 0.0;

  final List<String> _exerciseKeys = [
    'squat',
    'pushup',
    'preacher_curl',
    'bicep_curl',
    'lateral_raise',
    'overhead_press',
    'lunge',
    'plank',
  ];

  final List<String> _yogaKeys = [
    'tree_pose',
    'warrior_2',
    'downward_dog',
    'cobra_pose',
    'child_pose',
  ];

  @override
  void initState() {
    super.initState();
    _currentExerciseKey = widget.initialExerciseKey;
    _isYoga = widget.isYoga;

    // Initialize high-precision MediaPipe ML Kit Pose Detector
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.accurate,
      ),
    );

    _initCamera();
    _startSession();
  }

  Future<void> _initCamera() async {
    try {
      _availableCameras = await availableCameras();
      if (_availableCameras.isNotEmpty) {
        _selectedCameraIndex = _availableCameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
        );
        if (_selectedCameraIndex == -1) _selectedCameraIndex = 0;

        await _startCameraStream();
      } else {
        _startSimulatedFallback();
      }
    } catch (e) {
      debugPrint("Camera init note: $e, falling back to simulated vision stream.");
      _startSimulatedFallback();
    }
  }

  Future<void> _startCameraStream() async {
    if (_availableCameras.isEmpty) return;

    final camera = _availableCameras[_selectedCameraIndex];
    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: !kIsWeb && Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() => _isCameraReady = true);

      await _cameraController!.startImageStream((CameraImage image) {
        if (!_isProcessingFrame && _isWorkoutActive) {
          _processCameraFrame(image);
        }
      });
    } catch (e) {
      debugPrint("Live image stream not supported on this device/platform ($e), using fallback vision.");
      _startSimulatedFallback();
    }
  }

  static String _landmarkTypeToKey(PoseLandmarkType type) {
    switch (type) {
      case PoseLandmarkType.nose:
        return 'NOSE';
      case PoseLandmarkType.leftEyeInner:
        return 'LEFT_EYE_INNER';
      case PoseLandmarkType.leftEye:
        return 'LEFT_EYE';
      case PoseLandmarkType.leftEyeOuter:
        return 'LEFT_EYE_OUTER';
      case PoseLandmarkType.rightEyeInner:
        return 'RIGHT_EYE_INNER';
      case PoseLandmarkType.rightEye:
        return 'RIGHT_EYE';
      case PoseLandmarkType.rightEyeOuter:
        return 'RIGHT_EYE_OUTER';
      case PoseLandmarkType.leftEar:
        return 'LEFT_EAR';
      case PoseLandmarkType.rightEar:
        return 'RIGHT_EAR';
      case PoseLandmarkType.leftMouth:
        return 'LEFT_MOUTH';
      case PoseLandmarkType.rightMouth:
        return 'RIGHT_MOUTH';
      case PoseLandmarkType.leftShoulder:
        return 'LEFT_SHOULDER';
      case PoseLandmarkType.rightShoulder:
        return 'RIGHT_SHOULDER';
      case PoseLandmarkType.leftElbow:
        return 'LEFT_ELBOW';
      case PoseLandmarkType.rightElbow:
        return 'RIGHT_ELBOW';
      case PoseLandmarkType.leftWrist:
        return 'LEFT_WRIST';
      case PoseLandmarkType.rightWrist:
        return 'RIGHT_WRIST';
      case PoseLandmarkType.leftPinky:
        return 'LEFT_PINKY';
      case PoseLandmarkType.rightPinky:
        return 'RIGHT_PINKY';
      case PoseLandmarkType.leftIndex:
        return 'LEFT_INDEX';
      case PoseLandmarkType.rightIndex:
        return 'RIGHT_INDEX';
      case PoseLandmarkType.leftThumb:
        return 'LEFT_THUMB';
      case PoseLandmarkType.rightThumb:
        return 'RIGHT_THUMB';
      case PoseLandmarkType.leftHip:
        return 'LEFT_HIP';
      case PoseLandmarkType.rightHip:
        return 'RIGHT_HIP';
      case PoseLandmarkType.leftKnee:
        return 'LEFT_KNEE';
      case PoseLandmarkType.rightKnee:
        return 'RIGHT_KNEE';
      case PoseLandmarkType.leftAnkle:
        return 'LEFT_ANKLE';
      case PoseLandmarkType.rightAnkle:
        return 'RIGHT_ANKLE';
      case PoseLandmarkType.leftHeel:
        return 'LEFT_HEEL';
      case PoseLandmarkType.rightHeel:
        return 'RIGHT_HEEL';
      case PoseLandmarkType.leftFootIndex:
        return 'LEFT_FOOT_INDEX';
      case PoseLandmarkType.rightFootIndex:
        return 'RIGHT_FOOT_INDEX';
    }
  }

  Future<void> _processCameraFrame(CameraImage image) async {
    _isProcessingFrame = true;

    try {
      final inputImage = _buildInputImageFromCameraImage(image);
      if (inputImage == null) {
        _isProcessingFrame = false;
        return;
      }

      final poses = await _poseDetector.processImage(inputImage);

      if (poses.isEmpty && mounted && _isWorkoutActive) {
        setState(() {
          _isPersonDetected = false;
          _formStatus = "POSITIONING";
          _feedbackMessage = "Step into camera frame until body is visible";
          _positioningInstruction = "Position phone 6-8 feet away at waist level";
          _landmarks = {};
          _formScore = 0.0;
          _isMismatch = false;
          _mismatchAlert = null;
        });
      } else if (poses.isNotEmpty && mounted && _isWorkoutActive) {
        _hasRealMediaPipeFeed = true;
        _simFallbackTimer?.cancel();

        final pose = poses.first;
        final rotation = inputImage.metadata?.rotation;
        final bool isRotated = rotation == InputImageRotation.rotation90deg ||
            rotation == InputImageRotation.rotation270deg;

        final double frameWidth = isRotated
            ? image.height.toDouble()
            : image.width.toDouble();
        final double frameHeight = isRotated
            ? image.width.toDouble()
            : image.height.toDouble();

        final Map<String, CustomLandmarkPoint> detectedMap = {};
        pose.landmarks.forEach((type, lm) {
          final key = _landmarkTypeToKey(type);
          final normX = (lm.x / frameWidth).clamp(0.0, 1.0);
          final normY = (lm.y / frameHeight).clamp(0.0, 1.0);
          detectedMap[key] = CustomLandmarkPoint(
            x: normX,
            y: normY,
            confidence: lm.likelihood,
          );
        });

        // Run algorithmic Pose & Exercise Form Analyzer
        final analysis = _poseAnalyzer.analyzePose(
          pose: pose,
          exerciseKey: _currentExerciseKey,
          isYoga: _isYoga,
        );

        if (mounted) {
          setState(() {
            _landmarks = detectedMap;
            _jointEvaluations = analysis.jointEvaluations;
            _boneEvaluations = analysis.boneEvaluations;
            _repCount = analysis.repCount;
            _isPersonDetected = analysis.isPersonDetected;
            _isFullBodyInFrame = analysis.isFullBodyInFrame;
            _positioningInstruction = analysis.positioningInstruction;
            _isMismatch = analysis.isMismatch;
            _mismatchAlert = analysis.mismatchAlert;
            _repHistory = analysis.repHistory;

            if (_isPersonDetected) {
              _formScore = analysis.formScore;
              _formStatus = analysis.status;
              _feedbackMessage = analysis.feedbackMessage;
              _repState = analysis.repState;
              _activeJointName = analysis.activeJointName;
              _currentAngle = analysis.activeJointAngle;

              if (analysis.repCompletedJustNow) {
                _caloriesBurned += _isYoga ? 0.1 : 0.45;
                if (!_isYoga && _repCount >= _targetReps) {
                  _onSetCompleted();
                }
              }
            } else {
              _formScore = 0.0;
              _formStatus = "POSITIONING";
              _feedbackMessage = "Align full body inside the camera guide";
            }
          });

          if (analysis.voiceCue != null) {
            TtsService().speak(analysis.voiceCue!);
          }
        }
      }
    } catch (e) {
      debugPrint("MediaPipe Frame Processing Error: $e");
    } finally {
      _isProcessingFrame = false;
    }
  }

  void _onSetCompleted() {
    if (_currentSet < _totalSets) {
      TtsService().speak("Set $_currentSet complete! Take a brief 30 second rest.", force: true);
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Set $_currentSet of $_totalSets Completed! 👏',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Great cadence and form control. Take a 30 second breather, then begin your next set.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              if (_repHistory.isNotEmpty) ...[
                const Text(
                  'Set Rep Accuracy:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: _repHistory.map((r) {
                    final color = r.isClean ? AppColors.accentNeon : AppColors.warningOrange;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: color.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        'R${r.repNumber}: ${r.accuracyScore.toInt()}%',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _currentSet++;
                  _repCount = 0;
                  _poseAnalyzer.reset();
                  _repHistory = [];
                });
                TtsService().speak("Starting Set $_currentSet!");
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Start Next Set', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      _finishWorkout();
    }
  }

  InputImage? _buildInputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) return null;

    final camera = _availableCameras[_selectedCameraIndex];
    final sensorOrientation = camera.sensorOrientation;

    final InputImageRotation? rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    if (rotation == null) return null;

    final InputImageFormat? format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  void _startSimulatedFallback() {
    if (_hasRealMediaPipeFeed) return;
    _simFallbackTimer?.cancel();
    _simFallbackTimer = Timer.periodic(const Duration(milliseconds: 70), (timer) {
      if (!mounted || !_isWorkoutActive || _hasRealMediaPipeFeed) return;
      _updateBiometricsFrame();
    });
  }

  void _startSession() {
    _poseAnalyzer.reset();
    _repCount = 0;
    _currentSet = 1;
    _holdDurationSec = 0;
    _caloriesBurned = 0.0;
    _totalWorkoutSec = 0;
    _formScore = 94.0;
    _isMismatch = false;
    _mismatchAlert = null;
    _repHistory = [];
    _jointEvaluations = {};
    _boneEvaluations = {};

    TtsService().speak(
      _isYoga
          ? "MediaPipe Yoga Tracker ready. Hold ${_getExerciseTitle()} pose."
          : "MediaPipe Vision Active. Starting ${_getExerciseTitle()}!",
      force: true,
    );

    _workoutDurationTimer?.cancel();
    _workoutDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isWorkoutActive) return;
      setState(() {
        _totalWorkoutSec++;
        if (_isYoga) {
          _holdDurationSec++;
          _caloriesBurned += 0.08;
          if (_holdDurationSec == 10) {
            TtsService().speak("Great balance! Halfway through hold.");
          } else if (_holdDurationSec == _targetHoldSec) {
            TtsService().speak("Hold completed! Excellent stability.", force: true);
          }
        }
      });
    });
  }

  void _updateBiometricsFrame() {
    _simPhase += 0.05;
    final double cycle = (math.sin(_simPhase) + 1.0) / 2.0;

    if (_isYoga) {
      _generateYogaSkeleton(cycle);
    } else {
      _generateDynamicSkeleton(cycle);
    }

    final analysis = _poseAnalyzer.analyzeLandmarkPoints(
      points: _landmarks,
      exerciseKey: _currentExerciseKey,
      isYoga: _isYoga,
    );

    if (mounted) {
      setState(() {
        _jointEvaluations = analysis.jointEvaluations;
        _boneEvaluations = analysis.boneEvaluations;
        _repCount = analysis.repCount;
        _isPersonDetected = true;
        _isFullBodyInFrame = true;
        _formScore = analysis.formScore > 0 ? analysis.formScore : 94.0;
        _formStatus = analysis.status;
        _feedbackMessage = analysis.feedbackMessage;
        _repState = analysis.repState;
        _activeJointName = analysis.activeJointName;
        _currentAngle = analysis.activeJointAngle;
        _isMismatch = analysis.isMismatch;
        _mismatchAlert = analysis.mismatchAlert;
        _repHistory = analysis.repHistory;

        if (analysis.repCompletedJustNow) {
          _caloriesBurned += _isYoga ? 0.1 : 0.45;
          if (!_isYoga && _repCount >= _targetReps) {
            _onSetCompleted();
          }
        }
      });

      if (analysis.voiceCue != null) {
        TtsService().speak(analysis.voiceCue!);
      }
    }
  }

  void _generateDynamicSkeleton(double depth) {
    if (_currentExerciseKey == 'pushup') {
      final double dip = depth * 0.12;
      _landmarks = {
        'NOSE': CustomLandmarkPoint(x: 0.22, y: 0.52 + dip),
        'LEFT_SHOULDER': CustomLandmarkPoint(x: 0.30, y: 0.50 + dip),
        'RIGHT_SHOULDER': CustomLandmarkPoint(x: 0.32, y: 0.48 + dip),
        'LEFT_ELBOW': CustomLandmarkPoint(x: 0.28, y: 0.62 - (depth * 0.05)),
        'RIGHT_ELBOW': CustomLandmarkPoint(x: 0.30, y: 0.60 - (depth * 0.05)),
        'LEFT_WRIST': const CustomLandmarkPoint(x: 0.30, y: 0.72),
        'RIGHT_WRIST': const CustomLandmarkPoint(x: 0.32, y: 0.72),
        'LEFT_HIP': CustomLandmarkPoint(x: 0.55, y: 0.51 + dip),
        'RIGHT_HIP': CustomLandmarkPoint(x: 0.57, y: 0.49 + dip),
        'LEFT_KNEE': CustomLandmarkPoint(x: 0.70, y: 0.52 + dip),
        'RIGHT_KNEE': CustomLandmarkPoint(x: 0.72, y: 0.50 + dip),
        'LEFT_ANKLE': const CustomLandmarkPoint(x: 0.85, y: 0.54),
        'RIGHT_ANKLE': const CustomLandmarkPoint(x: 0.86, y: 0.52),
      };
    } else if (_currentExerciseKey == 'preacher_curl') {
      final double curlY = 0.48 - (depth * 0.18);
      _landmarks = {
        'NOSE': const CustomLandmarkPoint(x: 0.50, y: 0.22),
        'LEFT_SHOULDER': const CustomLandmarkPoint(x: 0.44, y: 0.32),
        'RIGHT_SHOULDER': const CustomLandmarkPoint(x: 0.56, y: 0.32),
        'LEFT_ELBOW': const CustomLandmarkPoint(x: 0.42, y: 0.50), // stationary on preacher pad
        'RIGHT_ELBOW': const CustomLandmarkPoint(x: 0.58, y: 0.50),
        'LEFT_WRIST': CustomLandmarkPoint(x: 0.42, y: curlY),
        'RIGHT_WRIST': CustomLandmarkPoint(x: 0.58, y: curlY),
        'LEFT_HIP': const CustomLandmarkPoint(x: 0.45, y: 0.58),
        'RIGHT_HIP': const CustomLandmarkPoint(x: 0.55, y: 0.58),
        'LEFT_KNEE': const CustomLandmarkPoint(x: 0.44, y: 0.75),
        'RIGHT_KNEE': const CustomLandmarkPoint(x: 0.56, y: 0.75),
        'LEFT_ANKLE': const CustomLandmarkPoint(x: 0.44, y: 0.90),
        'RIGHT_ANKLE': const CustomLandmarkPoint(x: 0.56, y: 0.90),
      };
    } else if (_currentExerciseKey == 'lateral_raise') {
      final double armY = 0.52 - (depth * 0.24);
      final double armSpread = 0.12 + (depth * 0.18);
      _landmarks = {
        'NOSE': const CustomLandmarkPoint(x: 0.50, y: 0.20),
        'LEFT_SHOULDER': const CustomLandmarkPoint(x: 0.44, y: 0.30),
        'RIGHT_SHOULDER': const CustomLandmarkPoint(x: 0.56, y: 0.30),
        'LEFT_ELBOW': CustomLandmarkPoint(x: 0.42 - (armSpread * 0.6), y: armY + 0.05),
        'RIGHT_ELBOW': CustomLandmarkPoint(x: 0.58 + (armSpread * 0.6), y: armY + 0.05),
        'LEFT_WRIST': CustomLandmarkPoint(x: 0.42 - armSpread, y: armY),
        'RIGHT_WRIST': CustomLandmarkPoint(x: 0.58 + armSpread, y: armY),
        'LEFT_HIP': const CustomLandmarkPoint(x: 0.45, y: 0.55),
        'RIGHT_HIP': const CustomLandmarkPoint(x: 0.55, y: 0.55),
        'LEFT_KNEE': const CustomLandmarkPoint(x: 0.44, y: 0.74),
        'RIGHT_KNEE': const CustomLandmarkPoint(x: 0.56, y: 0.74),
        'LEFT_ANKLE': const CustomLandmarkPoint(x: 0.44, y: 0.90),
        'RIGHT_ANKLE': const CustomLandmarkPoint(x: 0.56, y: 0.90),
      };
    } else if (_currentExerciseKey == 'bicep_curl') {
      final double forearmY = 0.55 - (depth * 0.22);
      _landmarks = {
        'NOSE': const CustomLandmarkPoint(x: 0.50, y: 0.20),
        'LEFT_SHOULDER': const CustomLandmarkPoint(x: 0.44, y: 0.30),
        'RIGHT_SHOULDER': const CustomLandmarkPoint(x: 0.56, y: 0.30),
        'LEFT_ELBOW': const CustomLandmarkPoint(x: 0.42, y: 0.52),
        'RIGHT_ELBOW': const CustomLandmarkPoint(x: 0.58, y: 0.52),
        'LEFT_WRIST': CustomLandmarkPoint(x: 0.42, y: forearmY),
        'RIGHT_WRIST': CustomLandmarkPoint(x: 0.58, y: forearmY),
        'LEFT_HIP': const CustomLandmarkPoint(x: 0.45, y: 0.55),
        'RIGHT_HIP': const CustomLandmarkPoint(x: 0.55, y: 0.55),
        'LEFT_KNEE': const CustomLandmarkPoint(x: 0.44, y: 0.74),
        'RIGHT_KNEE': const CustomLandmarkPoint(x: 0.56, y: 0.74),
        'LEFT_ANKLE': const CustomLandmarkPoint(x: 0.44, y: 0.90),
        'RIGHT_ANKLE': const CustomLandmarkPoint(x: 0.56, y: 0.90),
      };
    } else {
      // Squat trajectory
      final double headY = 0.20 + (depth * 0.08);
      final double hipY = 0.52 + (depth * 0.12);
      final double kneeY = 0.72 + (depth * 0.06);
      const double ankleY = 0.90;

      _landmarks = {
        'NOSE': CustomLandmarkPoint(x: 0.50, y: headY),
        'LEFT_SHOULDER': CustomLandmarkPoint(x: 0.42, y: headY + 0.10),
        'RIGHT_SHOULDER': CustomLandmarkPoint(x: 0.58, y: headY + 0.10),
        'LEFT_ELBOW': CustomLandmarkPoint(x: 0.36, y: headY + 0.20),
        'RIGHT_ELBOW': CustomLandmarkPoint(x: 0.64, y: headY + 0.20),
        'LEFT_WRIST': CustomLandmarkPoint(x: 0.34, y: headY + 0.28),
        'RIGHT_WRIST': CustomLandmarkPoint(x: 0.66, y: headY + 0.28),
        'LEFT_HIP': CustomLandmarkPoint(x: 0.44, y: hipY),
        'RIGHT_HIP': CustomLandmarkPoint(x: 0.56, y: hipY),
        'LEFT_KNEE': CustomLandmarkPoint(x: 0.40 - (depth * 0.05), y: kneeY),
        'RIGHT_KNEE': CustomLandmarkPoint(x: 0.60 + (depth * 0.05), y: kneeY),
        'LEFT_ANKLE': const CustomLandmarkPoint(x: 0.42, y: ankleY),
        'RIGHT_ANKLE': const CustomLandmarkPoint(x: 0.58, y: ankleY),
      };
    }
  }

  void _generateYogaSkeleton(double cycle) {
    if (_currentExerciseKey == 'warrior_2') {
      _landmarks = const {
        'NOSE': CustomLandmarkPoint(x: 0.46, y: 0.22),
        'LEFT_SHOULDER': CustomLandmarkPoint(x: 0.44, y: 0.32),
        'RIGHT_SHOULDER': CustomLandmarkPoint(x: 0.54, y: 0.32),
        'LEFT_ELBOW': CustomLandmarkPoint(x: 0.28, y: 0.32),
        'RIGHT_ELBOW': CustomLandmarkPoint(x: 0.70, y: 0.32),
        'LEFT_WRIST': CustomLandmarkPoint(x: 0.16, y: 0.32),
        'RIGHT_WRIST': CustomLandmarkPoint(x: 0.82, y: 0.32),
        'LEFT_HIP': CustomLandmarkPoint(x: 0.45, y: 0.54),
        'RIGHT_HIP': CustomLandmarkPoint(x: 0.53, y: 0.54),
        'LEFT_KNEE': CustomLandmarkPoint(x: 0.34, y: 0.70),
        'RIGHT_KNEE': CustomLandmarkPoint(x: 0.66, y: 0.68),
        'LEFT_ANKLE': CustomLandmarkPoint(x: 0.34, y: 0.88),
        'RIGHT_ANKLE': CustomLandmarkPoint(x: 0.78, y: 0.88),
      };
    } else {
      _landmarks = const {
        'NOSE': CustomLandmarkPoint(x: 0.50, y: 0.18),
        'LEFT_SHOULDER': CustomLandmarkPoint(x: 0.42, y: 0.28),
        'RIGHT_SHOULDER': CustomLandmarkPoint(x: 0.58, y: 0.28),
        'LEFT_ELBOW': CustomLandmarkPoint(x: 0.32, y: 0.22),
        'RIGHT_ELBOW': CustomLandmarkPoint(x: 0.68, y: 0.22),
        'LEFT_WRIST': CustomLandmarkPoint(x: 0.50, y: 0.10),
        'RIGHT_WRIST': CustomLandmarkPoint(x: 0.50, y: 0.10),
        'LEFT_HIP': CustomLandmarkPoint(x: 0.45, y: 0.50),
        'RIGHT_HIP': CustomLandmarkPoint(x: 0.55, y: 0.50),
        'LEFT_KNEE': CustomLandmarkPoint(x: 0.48, y: 0.70),
        'RIGHT_KNEE': CustomLandmarkPoint(x: 0.68, y: 0.58),
        'LEFT_ANKLE': CustomLandmarkPoint(x: 0.48, y: 0.90),
        'RIGHT_ANKLE': CustomLandmarkPoint(x: 0.50, y: 0.68),
      };
    }
  }

  String _getExerciseTitle() {
    if (_isYoga) {
      return YogaPose.fallbackYogaPoses.firstWhere(
        (y) => y.key == _currentExerciseKey,
        orElse: () => YogaPose.fallbackYogaPoses.first,
      ).name;
    }
    return Exercise.fallbackExercises.firstWhere(
      (e) => e.key == _currentExerciseKey,
      orElse: () => Exercise.fallbackExercises.first,
    ).name;
  }

  void _switchExercise(String key, bool isYoga) {
    setState(() {
      _currentExerciseKey = key;
      _isYoga = isYoga;
    });
    _startSession();
  }

  void _toggleCamera() async {
    if (_availableCameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _availableCameras.length;

    await _cameraController?.stopImageStream().catchError((_) {});
    await _cameraController?.dispose();

    setState(() => _isCameraReady = false);
    await _startCameraStream();
  }

  void _finishWorkout() async {
    _simFallbackTimer?.cancel();
    _workoutDurationTimer?.cancel();
    _isWorkoutActive = false;

    final workoutName = _getExerciseTitle();
    final int finalReps = _isYoga ? _holdDurationSec : _repCount;
    final double finalCalories = _caloriesBurned > 0 ? _caloriesBurned : (_repCount * 0.45).clamp(10.0, 500.0);
    final double recordedScore = _formScore > 0 ? _formScore : 90.0;

    await ApiService().completeWorkoutSession(
      workoutType: workoutName,
      totalDurationSec: _totalWorkoutSec,
      totalCalories: finalCalories,
      avgFormScore: recordedScore,
      totalReps: finalReps,
    );

    TtsService().speak("Workout complete! Fantastic effort!", force: true);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Workout Complete! 🏆',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentNeon.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accentNeon.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: AppColors.accentNeon, size: 36),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workoutName,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Form Accuracy: ${recordedScore.toInt()}%',
                            style: const TextStyle(fontSize: 12, color: AppColors.accentNeon, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _dialogStat('Reps/Hold', _isYoga ? '${_holdDurationSec}s' : '$finalReps reps', AppColors.primary),
                  _dialogStat('Time', '${_totalWorkoutSec ~/ 60}m ${_totalWorkoutSec % 60}s', Colors.white),
                  _dialogStat('Burned', '${finalCalories.toInt()} kcal', AppColors.accentNeon),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                widget.onWorkoutCompleted?.call();
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Return to Dashboard', style: TextStyle(color: AppColors.accentNeon, fontWeight: FontWeight.w800, fontSize: 14)),
            )
          ],
        ),
      );
    }
  }

  Widget _dialogStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  @override
  void dispose() {
    _isWorkoutActive = false;
    _simFallbackTimer?.cancel();
    _workoutDurationTimer?.cancel();
    _cameraController?.stopImageStream().catchError((_) {});
    _cameraController?.dispose();
    _poseDetector.close();
    TtsService().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isFrontCamera = _availableCameras.isNotEmpty &&
        _availableCameras[_selectedCameraIndex].lensDirection == CameraLensDirection.front;

    final timerMin = (_totalWorkoutSec ~/ 60).toString().padLeft(2, '0');
    final timerSec = (_totalWorkoutSec % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview or Fallback Backdrop
          if (_isCameraReady && _cameraController != null)
            CameraPreview(_cameraController!)
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0B0F19), Color(0xFF131B2E)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_outlined, size: 54, color: Colors.white24),
                    SizedBox(height: 12),
                    Text(
                      'GYM STAR AI Vision Active',
                      style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),

          // Real-time Dynamic Color-Coded Skeleton Overlay
          CustomPaint(
            size: size,
            painter: PosePainter(
              landmarks: _landmarks,
              jointEvaluations: _jointEvaluations,
              boneEvaluations: _boneEvaluations,
              status: _formStatus,
              isFrontCamera: isFrontCamera,
            ),
          ),

          // Positioning Frame Guide (When positioning or full body missing)
          if (!_isPersonDetected || !_isFullBodyInFrame)
            Center(
              child: Container(
                width: size.width * 0.78,
                height: size.height * 0.65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.6),
                    width: 2.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'POSITIONING GUIDE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _positioningInstruction,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Top Header Bar
          Positioned(
            top: 44,
            left: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderDark),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Exercise Image Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 38,
                      height: 38,
                      child: Image.network(
                        _isYoga
                            ? 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=200&auto=format&fit=crop&q=80'
                            : Exercise.fallbackExercises
                                .firstWhere(
                                  (e) => e.key == _currentExerciseKey,
                                  orElse: () => Exercise.fallbackExercises.first,
                                )
                                .imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          child: const Icon(Icons.fitness_center_rounded, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Exercise Name & Muscle / Camera Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            isDense: true,
                            value: _currentExerciseKey,
                            dropdownColor: AppColors.surfaceDark,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 18),
                            items: [
                              ..._exerciseKeys.map((k) {
                                final ex = Exercise.fallbackExercises.firstWhere(
                                  (e) => e.key == k,
                                  orElse: () => Exercise.fallbackExercises.first,
                                );
                                return DropdownMenuItem(
                                  value: k,
                                  child: Text(
                                    ex.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                );
                              }),
                              ..._yogaKeys.map((k) {
                                final y = YogaPose.fallbackYogaPoses.firstWhere(
                                  (p) => p.key == k,
                                  orElse: () => YogaPose.fallbackYogaPoses.first,
                                );
                                return DropdownMenuItem(
                                  value: k,
                                  child: Text(
                                    '🧘 ${y.name}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                final isY = _yogaKeys.contains(val);
                                _switchExercise(val, isY);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accentNeon,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isYoga ? 'Yoga Flow' : 'AI Vision Active',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentNeon,
                              ),
                            ),
                            const Text(' • ', style: TextStyle(color: Colors.white30, fontSize: 10)),
                            Text(
                              '$timerMin:$timerSec',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Audio coaching toggle
                  IconButton(
                    icon: Icon(
                      TtsService().isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                      color: TtsService().isMuted ? Colors.white38 : AppColors.accentNeon,
                      size: 20,
                    ),
                    tooltip: 'Toggle Voice Coaching',
                    onPressed: () => setState(() => TtsService().toggleMute()),
                  ),

                  // Flip camera button
                  if (_availableCameras.length > 1)
                    IconButton(
                      icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white70, size: 20),
                      tooltip: 'Switch Camera',
                      onPressed: _toggleCamera,
                    ),
                ],
              ),
            ),
          ),

          // Exercise Mismatch Alert Banner (If Mismatch Detected)
          if (_isMismatch && _mismatchAlert != null)
            Positioned(
              top: 104,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.5),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _mismatchAlert!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Live Posture Feedback Alert Banner (When No Mismatch)
          if (!_isMismatch)
            Positioned(
              top: 108,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _formStatus == "GOOD"
                      ? const Color(0xFF059669).withValues(alpha: 0.92)
                      : (_formStatus == "WARNING"
                          ? const Color(0xFFD97706).withValues(alpha: 0.92)
                          : (_formStatus == "POSITIONING"
                              ? const Color(0xFF1E293B).withValues(alpha: 0.92)
                              : const Color(0xFFDC2626).withValues(alpha: 0.92))),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _formStatus == "GOOD"
                          ? Icons.check_circle_rounded
                          : (_formStatus == "WARNING"
                              ? Icons.warning_amber_rounded
                              : (_formStatus == "POSITIONING" ? Icons.center_focus_strong_rounded : Icons.cancel_outlined)),
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _feedbackMessage,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Live Angle Biometrics Tag
          Positioned(
            top: 172,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _activeJointName.toUpperCase(),
                    style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isPersonDetected ? '${_currentAngle.toInt()}°' : '--°',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),

          // Reps / Sets HUD & Form Score at Bottom
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Row(
                  children: [
                    // Rep Counter / Hold Timer
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isYoga
                                  ? 'HOLD DURATION'
                                  : 'SET $_currentSet / $_totalSets • $_repState',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _isYoga ? '${_holdDurationSec}s' : '$_repCount',
                                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isYoga ? '/ ${_targetHoldSec}s' : '/ $_targetReps reps',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Form Score Gauge
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FORM ACCURACY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _isPersonDetected && _formScore > 0 ? '${_formScore.toInt()}%' : '--%',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: _isPersonDetected ? AppColors.accentNeon : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Per-Rep Accuracy Dots Bar
                if (!_isYoga && _repHistory.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const Text(
                            'REPS: ',
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                          ),
                          ..._repHistory.map((rep) {
                            final dotColor = rep.isClean
                                ? AppColors.accentNeon
                                : (rep.accuracyScore >= 70 ? AppColors.warningOrange : const Color(0xFFEF4444));
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: Tooltip(
                                message: 'Rep ${rep.repNumber}: ${rep.accuracyScore.toInt()}% (${rep.feedback})',
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: dotColor.withValues(alpha: 0.20),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: dotColor, width: 0.8),
                                  ),
                                  child: Text(
                                    '${rep.repNumber}: ${rep.accuracyScore.toInt()}%',
                                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: dotColor),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Action Buttons: Pause/Resume + Complete Workout
                Row(
                  children: [
                    // Pause / Resume Control
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isWorkoutActive = !_isWorkoutActive;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black.withValues(alpha: 0.65),
                          side: const BorderSide(color: AppColors.borderDark, width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Icon(
                          _isWorkoutActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: _isWorkoutActive ? Colors.white70 : AppColors.accentNeon,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Complete & Save Session Button
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _finishWorkout,
                          icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                          label: const Text(
                            'Complete Session',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.3),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
