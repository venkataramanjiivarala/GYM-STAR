import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/pose_analyzer.dart';

class CustomLandmarkPoint {
  final double x;
  final double y;
  final double confidence;

  const CustomLandmarkPoint({
    required this.x,
    required this.y,
    this.confidence = 1.0,
  });
}

class PosePainter extends CustomPainter {
  final Map<String, CustomLandmarkPoint> landmarks;
  final Map<String, JointEvaluation>? jointEvaluations;
  final Map<String, JointFormStatus>? boneEvaluations;
  final String status; // Overall fallback: GOOD, WARNING, INCORRECT
  final String? activeJointBadge;
  final Offset? activeJointPos;
  final bool isFrontCamera;
  final Size? imageSize;

  PosePainter({
    required this.landmarks,
    this.jointEvaluations,
    this.boneEvaluations,
    required this.status,
    this.activeJointBadge,
    this.activeJointPos,
    this.isFrontCamera = true,
    this.imageSize,
  });

  // Color Palette Tokens
  static const Color colorGood = Color(0xFF00F59B); // Neon Emerald Green
  static const Color colorWarning = Color(0xFFFBBF24); // Amber Warning
  static const Color colorIncorrect = Color(0xFFFF3366); // Neon Crimson Alert
  static const Color colorNeutral = Color(0xFF00E5FF); // Electric Cyan
  static const Color colorMuted = Color(0xFF64748B); // Slate Muted

  Color _getStatusColor(JointFormStatus? formStatus) {
    switch (formStatus) {
      case JointFormStatus.good:
        return colorGood;
      case JointFormStatus.warning:
        return colorWarning;
      case JointFormStatus.incorrect:
        return colorIncorrect;
      case JointFormStatus.neutral:
        return colorNeutral;
      case null:
        if (status == "GOOD") return colorGood;
        if (status == "WARNING") return colorWarning;
        return colorIncorrect;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.isEmpty) return;

    // Helper to map normalized coordinates (0.0 - 1.0) to canvas pixel coordinates
    Offset toCanvas(CustomLandmarkPoint lm) {
      double nx = lm.x;
      if (isFrontCamera) {
        nx = 1.0 - nx; // Mirror for selfie / front camera
      }
      return Offset(
        (nx * size.width).clamp(0.0, size.width),
        (lm.y * size.height).clamp(0.0, size.height),
      );
    }

    // MediaPipe Standard Biometric Connections
    final connections = [
      // Head & Face
      ['LEFT_EAR', 'LEFT_EYE'],
      ['LEFT_EYE', 'NOSE'],
      ['NOSE', 'RIGHT_EYE'],
      ['RIGHT_EYE', 'RIGHT_EAR'],
      ['LEFT_SHOULDER', 'RIGHT_SHOULDER'],

      // Torso Box
      ['LEFT_SHOULDER', 'LEFT_HIP'],
      ['RIGHT_SHOULDER', 'RIGHT_HIP'],
      ['LEFT_HIP', 'RIGHT_HIP'],

      // Arms
      ['LEFT_SHOULDER', 'LEFT_ELBOW'],
      ['LEFT_ELBOW', 'LEFT_WRIST'],
      ['RIGHT_SHOULDER', 'RIGHT_ELBOW'],
      ['RIGHT_ELBOW', 'RIGHT_WRIST'],

      // Legs
      ['LEFT_HIP', 'LEFT_KNEE'],
      ['LEFT_KNEE', 'LEFT_ANKLE'],
      ['RIGHT_HIP', 'RIGHT_KNEE'],
      ['RIGHT_KNEE', 'RIGHT_ANKLE'],

      // Feet
      ['LEFT_ANKLE', 'LEFT_HEEL'],
      ['LEFT_HEEL', 'LEFT_FOOT_INDEX'],
      ['RIGHT_ANKLE', 'RIGHT_HEEL'],
      ['RIGHT_HEEL', 'RIGHT_FOOT_INDEX'],
    ];

    // 1. Draw Bone Connectors (with per-bone & per-joint dynamic color coding)
    for (final conn in connections) {
      final p1Key = conn[0];
      final p2Key = conn[1];
      final p1 = landmarks[p1Key];
      final p2 = landmarks[p2Key];

      if (p1 != null && p2 != null && p1.confidence > 0.35 && p2.confidence > 0.35) {
        final pos1 = toCanvas(p1);
        final pos2 = toCanvas(p2);

        // Determine bone color
        JointFormStatus? boneStatus = boneEvaluations?['${p1Key}_$p2Key'] ??
            boneEvaluations?['${p2Key}_$p1Key'];

        if (boneStatus == null) {
          final j1 = jointEvaluations?[p1Key];
          final j2 = jointEvaluations?[p2Key];

          if (j1?.status == JointFormStatus.incorrect || j2?.status == JointFormStatus.incorrect) {
            boneStatus = JointFormStatus.incorrect;
          } else if (j1?.status == JointFormStatus.warning || j2?.status == JointFormStatus.warning) {
            boneStatus = JointFormStatus.warning;
          } else if (j1?.status == JointFormStatus.good || j2?.status == JointFormStatus.good) {
            boneStatus = JointFormStatus.good;
          } else {
            boneStatus = JointFormStatus.neutral;
          }
        }

        final boneColor = _getStatusColor(boneStatus);

        // Outer diffused glow
        final lineGlowPaint = Paint()
          ..color = boneColor.withValues(alpha: 0.35)
          ..strokeWidth = 7.0
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        // Inner crisp core
        final lineCorePaint = Paint()
          ..color = boneColor
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        canvas.drawLine(pos1, pos2, lineGlowPaint);
        canvas.drawLine(pos1, pos2, lineCorePaint);
      }
    }

    // 2. Draw Angle Arcs on active joints
    _drawAngleArcs(canvas, toCanvas);

    // 3. Draw Joint Nodes (Halo + Core + Alert Rings)
    landmarks.forEach((name, lm) {
      if (lm.confidence > 0.35) {
        final pos = toCanvas(lm);
        final evaluation = jointEvaluations?[name];
        final jointStatus = evaluation?.status;

        if (jointStatus == JointFormStatus.incorrect) {
          // Alert ring (pulse effect)
          final alertRing = Paint()
            ..color = colorIncorrect.withValues(alpha: 0.4)
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke;
          canvas.drawCircle(pos, 13.0, alertRing);

          // Glowing halo
          final haloPaint = Paint()
            ..color = colorIncorrect.withValues(alpha: 0.7)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pos, 8.5, haloPaint);

          // Core dot
          final corePaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pos, 4.5, corePaint);
        } else if (jointStatus == JointFormStatus.warning) {
          final haloPaint = Paint()
            ..color = colorWarning.withValues(alpha: 0.65)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pos, 8.5, haloPaint);

          final corePaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pos, 4.5, corePaint);
        } else if (jointStatus == JointFormStatus.good) {
          final haloPaint = Paint()
            ..color = colorGood.withValues(alpha: 0.6)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pos, 8.0, haloPaint);

          final corePaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pos, 4.0, corePaint);
        } else {
          // Standard neutral joint
          final haloPaint = Paint()
            ..color = colorNeutral.withValues(alpha: 0.45)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pos, 6.0, haloPaint);

          final corePaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pos, 3.0, corePaint);
        }
      }
    });

    // 4. Draw Floating HUD Angle Badges on active evaluated joints
    if (jointEvaluations != null && jointEvaluations!.isNotEmpty) {
      for (final entry in jointEvaluations!.entries) {
        final lm = landmarks[entry.key];
        if (lm != null && lm.confidence > 0.35) {
          final pos = toCanvas(lm);
          final evaluation = entry.value;

          // Offset badge slightly away from joint center to avoid occlusion
          final isLeft = entry.key.contains('LEFT');
          final double offsetX = isFrontCamera ? (isLeft ? 48.0 : -48.0) : (isLeft ? -48.0 : 48.0);
          final badgeCenter = Offset(
            (pos.dx + offsetX).clamp(40.0, size.width - 40.0),
            (pos.dy - 18.0).clamp(25.0, size.height - 25.0),
          );

          _drawJointBadge(
            canvas: canvas,
            center: badgeCenter,
            title: evaluation.label ?? '${evaluation.angle.toInt()}°',
            statusColor: _getStatusColor(evaluation.status),
          );
        }
      }
    } else if (activeJointBadge != null && activeJointPos != null) {
      // Fallback single badge
      final overallColor = _getStatusColor(null);
      _drawJointBadge(
        canvas: canvas,
        center: activeJointPos!,
        title: activeJointBadge!,
        statusColor: overallColor,
      );
    }
  }

  void _drawAngleArcs(Canvas canvas, Offset Function(CustomLandmarkPoint) toCanvas) {
    final triplets = [
      ['LEFT_HIP', 'LEFT_KNEE', 'LEFT_ANKLE'],
      ['RIGHT_HIP', 'RIGHT_KNEE', 'RIGHT_ANKLE'],
      ['LEFT_SHOULDER', 'LEFT_ELBOW', 'LEFT_WRIST'],
      ['RIGHT_SHOULDER', 'RIGHT_ELBOW', 'RIGHT_WRIST'],
      ['LEFT_SHOULDER', 'LEFT_HIP', 'LEFT_KNEE'],
      ['RIGHT_SHOULDER', 'RIGHT_HIP', 'RIGHT_KNEE'],
    ];

    for (final triplet in triplets) {
      final aKey = triplet[0];
      final bKey = triplet[1]; // Vertex
      final cKey = triplet[2];

      final evaluation = jointEvaluations?[bKey];
      if (evaluation == null) continue;

      final pA = landmarks[aKey];
      final pB = landmarks[bKey];
      final pC = landmarks[cKey];

      if (pA != null && pB != null && pC != null &&
          pA.confidence > 0.35 && pB.confidence > 0.35 && pC.confidence > 0.35) {
        final vA = toCanvas(pA);
        final vB = toCanvas(pB);
        final vC = toCanvas(pC);

        final angleA = math.atan2(vA.dy - vB.dy, vA.dx - vB.dx);
        final angleC = math.atan2(vC.dy - vB.dy, vC.dx - vB.dx);

        double sweep = angleC - angleA;
        if (sweep > math.pi) sweep -= 2 * math.pi;
        if (sweep < -math.pi) sweep += 2 * math.pi;

        final arcColor = _getStatusColor(evaluation.status);

        final arcPaint = Paint()
          ..color = arcColor.withValues(alpha: 0.8)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

        final fanPaint = Paint()
          ..color = arcColor.withValues(alpha: 0.12)
          ..style = PaintingStyle.fill;

        final rect = Rect.fromCircle(center: vB, radius: 22.0);
        canvas.drawArc(rect, angleA, sweep, false, arcPaint);
        canvas.drawArc(rect, angleA, sweep, true, fanPaint);
      }
    }
  }

  void _drawJointBadge({
    required Canvas canvas,
    required Offset center,
    required String title,
    required Color statusColor,
  }) {
    final textSpan = TextSpan(
      text: title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    const double dotSize = 6.0;
    const double paddingX = 8.0;
    const double paddingY = 5.0;
    final badgeWidth = textPainter.width + dotSize + paddingX * 2 + 5.0;
    final badgeHeight = textPainter.height + paddingY * 2;

    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: badgeWidth,
        height: badgeHeight,
      ),
      const Radius.circular(8),
    );

    // Dark obsidian glass background
    final bgPaint = Paint()
      ..color = const Color(0xE60A101D)
      ..style = PaintingStyle.fill;

    // Glowing border matched to status
    final borderPaint = Paint()
      ..color = statusColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(badgeRect, bgPaint);
    canvas.drawRRect(badgeRect, borderPaint);

    // Small status indicator dot
    final dotPaint = Paint()
      ..color = statusColor
      ..style = PaintingStyle.fill;
    final dotCenter = Offset(
      center.dx - badgeWidth / 2 + paddingX + dotSize / 2,
      center.dy,
    );
    canvas.drawCircle(dotCenter, dotSize / 2, dotPaint);

    // Text paint
    textPainter.paint(
      canvas,
      Offset(
        dotCenter.dx + dotSize / 2 + 5.0,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return true;
  }
}
