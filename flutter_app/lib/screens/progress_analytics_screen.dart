import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/constants/app_colors.dart';
import '../core/services/api_service.dart';
import '../models/analytics_model.dart';
import '../widgets/stat_card.dart';

class ProgressAnalyticsScreen extends StatefulWidget {
  const ProgressAnalyticsScreen({super.key});

  @override
  State<ProgressAnalyticsScreen> createState() => _ProgressAnalyticsScreenState();
}

class _ProgressAnalyticsScreenState extends State<ProgressAnalyticsScreen> {
  ProgressDashboard _dashboard = ProgressDashboard.defaultDashboard;
  bool _isLoading = true;
  String _selectedTimeframe = '7d';
  int _selectedMetricIndex = 0; // 0 = Form Score %, 1 = Reps, 2 = Calories

  final List<String> _timeframeFilters = ['7d', '30d', '90d', 'all'];
  final List<String> _timeframeLabels = ['7 Days', '30 Days', '90 Days', 'All Time'];
  final List<String> _metricTabs = ['Form Accuracy (%)', 'Reps Completed', 'Calories Burned'];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    ApiService().workoutCompletedNotifier.addListener(_onWorkoutFinished);
  }

  @override
  void dispose() {
    ApiService().workoutCompletedNotifier.removeListener(_onWorkoutFinished);
    super.dispose();
  }

  void _onWorkoutFinished() {
    if (mounted) {
      _loadDashboard();
    }
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    final data = await ApiService().fetchDashboardAnalytics(timeframe: _selectedTimeframe);
    if (mounted) {
      setState(() {
        _dashboard = data;
        _isLoading = false;
      });
    }
  }

  void _setTimeframe(String tf) {
    setState(() => _selectedTimeframe = tf);
    _loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text(
          'Progress & Biometrics',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: _loadDashboard,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceDark,
              child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeframe filter selector
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  children: List.generate(_timeframeFilters.length, (idx) {
                    final tf = _timeframeFilters[idx];
                    final isSelected = _selectedTimeframe == tf;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _setTimeframe(tf),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _timeframeLabels[idx],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 18),

              // Summary Stats Grid
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'TOTAL SESSIONS',
                      value: '${_dashboard.totalWorkouts}',
                      subtitle: 'Verified workouts',
                      color: AppColors.primary,
                      icon: Icons.fitness_center_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      title: 'TOTAL REPETITIONS',
                      value: '${_dashboard.totalReps}',
                      subtitle: 'Accurate movements',
                      color: AppColors.accentNeon,
                      icon: Icons.repeat_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'AVG FORM ACCURACY',
                      value: _dashboard.avgFormScore > 0
                          ? '${_dashboard.avgFormScore.toStringAsFixed(1)}%'
                          : '--',
                      subtitle: _dashboard.avgFormScore > 0
                          ? 'Biometric score'
                          : 'No data yet',
                      color: AppColors.accentNeon,
                      icon: Icons.verified_user_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      title: 'TOTAL CALORIES',
                      value: '${_dashboard.totalCalories.toInt()} kcal',
                      subtitle: 'Energy expenditure',
                      color: AppColors.streakOrange,
                      icon: Icons.local_fire_department_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'ACTIVE MINUTES',
                      value: '${_dashboard.totalActiveMinutes} min',
                      subtitle: 'Time under tension',
                      color: AppColors.violet,
                      icon: Icons.timer_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      title: 'CURRENT STREAK',
                      value: '${_dashboard.streakDays} Days',
                      subtitle: 'Training consistency',
                      color: AppColors.streakOrange,
                      icon: Icons.bolt_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Interactive Performance Chart
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.borderDark),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'PERFORMANCE TREND',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selectedTimeframe.toUpperCase(),
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Metric switcher pills
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_metricTabs.length, (idx) {
                          final isSel = _selectedMetricIndex == idx;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(_metricTabs[idx]),
                              selected: isSel,
                              onSelected: (_) => setState(() => _selectedMetricIndex = idx),
                              backgroundColor: AppColors.bgDark,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                fontSize: 11,
                                fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                                color: isSel ? Colors.white : AppColors.textSecondary,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              side: BorderSide(color: isSel ? AppColors.primary : AppColors.borderDark),
                              showCheckmark: false,
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Line Chart with smooth curvature and glowing spots
                    SizedBox(
                      height: 200,
                      child: _dashboard.recentSessions.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.show_chart_rounded,
                                      size: 36, color: AppColors.textMuted),
                                  SizedBox(height: 8),
                                  Text(
                                    'No workout data yet',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Complete workouts to see your trend chart',
                                    style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11),
                                  ),
                                ],
                              ),
                            )
                          : LineChart(
                              _buildLineChartData(),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Muscle Group Distribution — derived from real workout sessions
              if (_dashboard.recentSessions.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MUSCLE GROUP DISTRIBUTION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._buildMuscleGroupBars(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Personal Records Section — real data only
              if (_dashboard.totalWorkouts > 0) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PERSONAL RECORDS (PRS)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _prPill(
                            'Best Form',
                            _dashboard.avgFormScore > 0
                                ? '${_dashboard.avgFormScore.toStringAsFixed(1)}%'
                                : '--',
                            Icons.verified_user_rounded,
                            AppColors.accentNeon,
                          ),
                          const SizedBox(width: 10),
                          _prPill(
                            'Total Reps',
                            '${_dashboard.totalReps}',
                            Icons.bolt_rounded,
                            AppColors.streakOrange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _prPill(
                            'Active Minutes',
                            '${_dashboard.totalActiveMinutes} min',
                            Icons.timer_outlined,
                            AppColors.violet,
                          ),
                          const SizedBox(width: 10),
                          _prPill(
                            'Best Streak',
                            '${_dashboard.streakDays} Days',
                            Icons.local_fire_department_rounded,
                            AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Recent Recorded Workout History
              const Text(
                'Recorded Workout Sessions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),

              if (_dashboard.recentSessions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: const Text(
                    'No workouts completed yet. Start your first session!',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                )
              else
                ..._dashboard.recentSessions.map((session) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.fitness_center_rounded, color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      session.workoutType,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${session.totalDurationSec ~/ 60}m ${session.totalDurationSec % 60}s • ${session.totalCalories.toInt()} kcal • ${session.completedAt.split('T').first}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.accentNeon.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.accentNeon.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '${session.avgFormScore.toInt()}% Form',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentNeon,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds muscle bar widgets from real session workout types
  List<Widget> _buildMuscleGroupBars() {
    // Map workout type keywords to muscle groups
    final Map<String, int> counts = {
      'Legs & Glutes': 0,
      'Chest & Triceps': 0,
      'Back & Biceps': 0,
      'Core & Stability': 0,
      'Shoulders': 0,
    };

    for (final s in _dashboard.recentSessions) {
      final wt = s.workoutType.toLowerCase();
      if (wt.contains('squat') || wt.contains('lunge') || wt.contains('leg') || wt.contains('glute')) {
        counts['Legs & Glutes'] = counts['Legs & Glutes']! + 1;
      } else if (wt.contains('push') || wt.contains('chest') || wt.contains('tricep') || wt.contains('dip')) {
        counts['Chest & Triceps'] = counts['Chest & Triceps']! + 1;
      } else if (wt.contains('pull') || wt.contains('row') || wt.contains('curl') || wt.contains('bicep') || wt.contains('deadlift')) {
        counts['Back & Biceps'] = counts['Back & Biceps']! + 1;
      } else if (wt.contains('plank') || wt.contains('core') || wt.contains('crunch') || wt.contains('abs') || wt.contains('mountain')) {
        counts['Core & Stability'] = counts['Core & Stability']! + 1;
      } else if (wt.contains('press') || wt.contains('raise') || wt.contains('shoulder') || wt.contains('overhead')) {
        counts['Shoulders'] = counts['Shoulders']! + 1;
      } else {
        counts['Core & Stability'] = counts['Core & Stability']! + 1;
      }
    }

    final total = counts.values.fold(0, (a, b) => a + b);
    if (total == 0) return [];

    final colors = [AppColors.primary, AppColors.accentNeon, AppColors.violet, AppColors.streakOrange, AppColors.purple];
    final entries = counts.entries.where((e) => e.value > 0).toList();

    return entries.asMap().entries.map((mapEntry) {
      final idx = mapEntry.key;
      final entry = mapEntry.value;
      final ratio = entry.value / total;
      final pct = '${(ratio * 100).round()}%';
      final color = colors[idx % colors.length];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _muscleBar(entry.key, ratio, pct, color),
      );
    }).toList();
  }

  Widget _muscleBar(String label, double ratio, String percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text(percent, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: AppColors.bgDark,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 7,
          ),
        ),
      ],
    );
  }

  Widget _prPill(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildLineChartData() {
    final trend = _dashboard.weeklyFormTrend;
    List<FlSpot> spots = [];

    for (int i = 0; i < trend.length; i++) {
      double yVal = 0.0;
      if (_selectedMetricIndex == 0) {
        yVal = trend[i].formScore > 0 ? trend[i].formScore : 0.0;
      } else if (_selectedMetricIndex == 1) {
        yVal = trend[i].reps.toDouble();
      } else {
        yVal = trend[i].calories;
      }
      spots.add(FlSpot(i.toDouble(), yVal));
    }

    if (spots.isEmpty) {
      spots = [const FlSpot(0, 0), const FlSpot(6, 0)];
    }

    Color lineColor = AppColors.primary;
    if (_selectedMetricIndex == 0) {
      lineColor = AppColors.accentNeon;
    } else if (_selectedMetricIndex == 2) {
      lineColor = AppColors.streakOrange;
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _selectedMetricIndex == 0 ? 20 : 50,
        getDrawingHorizontalLine: (val) => FlLine(
          color: AppColors.borderDark.withValues(alpha: 0.6),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (val, meta) {
              final idx = val.toInt();
              if (idx >= 0 && idx < trend.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    trend[idx].day,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 34,
            getTitlesWidget: (val, meta) {
              return Text(
                val.toInt().toString(),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: lineColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 4,
              color: lineColor,
              strokeWidth: 2,
              strokeColor: AppColors.surfaceDark,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: lineColor.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }
}
