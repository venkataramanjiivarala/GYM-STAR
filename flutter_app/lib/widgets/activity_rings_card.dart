import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/analytics_model.dart';

class ActivityRingsCard extends StatelessWidget {
  final ProgressDashboard dashboard;
  final VoidCallback onStartDailyWorkout;

  const ActivityRingsCard({
    super.key,
    required this.dashboard,
    required this.onStartDailyWorkout,
  });

  @override
  Widget build(BuildContext context) {
    // Daily goals
    const double targetCalories = 350.0;
    const double targetMinutes = 30.0;
    const double targetReps = 60.0;

    // Derive daily activity from actual sessions completed today
    double todayCalories = 0.0;
    int todayMinutes = 0;
    int todayReps = 0;

    for (var s in dashboard.recentSessions) {
      if (s.isToday) {
        todayCalories += s.totalCalories;
        todayMinutes += (s.totalDurationSec ~/ 60);
        todayReps += s.totalReps;
      }
    }

    final double calProgress = (todayCalories / targetCalories).clamp(0.0, 1.0);
    final double minProgress = (todayMinutes / targetMinutes).clamp(0.0, 1.0);
    final double repProgress = (todayReps / targetReps).clamp(0.0, 1.0);

    final int overallCompletion = (((calProgress + minProgress + repProgress) / 3.0) * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderDark, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DAILY ACTIVITY TARGET',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '$overallCompletion%',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: overallCompletion >= 100
                              ? AppColors.accentNeon.withValues(alpha: 0.16)
                              : AppColors.primary.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          overallCompletion >= 100 ? 'Goal Crushed! 🔥' : 'In Progress',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: overallCompletion >= 100 ? AppColors.accentNeon : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Apple Fitness+ Style Concentric Rings Painter
              SizedBox(
                width: 78,
                height: 78,
                child: CustomPaint(
                  painter: _ConcentricRingsPainter(
                    calProgress: calProgress,
                    minProgress: minProgress,
                    repProgress: repProgress,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: AppColors.borderDark, height: 1),
          const SizedBox(height: 14),

          // 3 Metric breakdown columns
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metricPill(
                label: 'Move (kcal)',
                value: '${todayCalories.toInt()} / ${targetCalories.toInt()}',
                color: AppColors.streakOrange,
                icon: Icons.local_fire_department_rounded,
              ),
              _metricPill(
                label: 'Exercise (min)',
                value: '$todayMinutes / ${targetMinutes.toInt()}',
                color: AppColors.accentNeon,
                icon: Icons.timer_outlined,
              ),
              _metricPill(
                label: 'Reps Target',
                value: '$todayReps / ${targetReps.toInt()}',
                color: AppColors.primary,
                icon: Icons.fitness_center_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricPill({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConcentricRingsPainter extends CustomPainter {
  final double calProgress;
  final double minProgress;
  final double repProgress;

  _ConcentricRingsPainter({
    required this.calProgress,
    required this.minProgress,
    required this.repProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeW = 6.0;

    // Ring 1 (Outer - Calories Orange)
    final r1 = (size.width / 2) - 4;
    _drawRing(canvas, center, r1, strokeW, AppColors.streakOrange, calProgress);

    // Ring 2 (Middle - Minutes Neon)
    final r2 = r1 - strokeW - 2.5;
    _drawRing(canvas, center, r2, strokeW, AppColors.accentNeon, minProgress);

    // Ring 3 (Inner - Reps Primary)
    final r3 = r2 - strokeW - 2.5;
    _drawRing(canvas, center, r3, strokeW, AppColors.primary, repProgress);
  }

  void _drawRing(Canvas canvas, Offset center, double radius, double strokeW, Color color, double progress) {
    // Background track
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    if (progress > 0) {
      final fgPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round;

      final sweepAngle = (2 * math.pi) * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConcentricRingsPainter oldDelegate) {
    return oldDelegate.calProgress != calProgress ||
        oldDelegate.minProgress != minProgress ||
        oldDelegate.repProgress != repProgress;
  }
}

