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
  int _selectedMetricIndex = 0; // 0 = Form Score %, 1 = Reps, 2 = Calories

  final List<String> _metricTabs = ['Form Score (%)', 'Reps Completed', 'Calories (kcal)'];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() async {
    final data = await ApiService().fetchDashboardAnalytics();
    if (mounted) {
      setState(() {
        _dashboard = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Progress Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadDashboard(),
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceDark,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Stats Grid
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'TOTAL WORKOUTS',
                      value: '${_dashboard.totalWorkouts}',
                      subtitle: 'Sessions finished',
                      color: AppColors.primary,
                      icon: Icons.fitness_center,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      title: 'TOTAL REPS',
                      value: '${_dashboard.totalReps}',
                      subtitle: 'Accurate movements',
                      color: AppColors.accentNeon,
                      icon: Icons.repeat,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'AVG FORM SCORE',
                      value: '${_dashboard.avgFormScore.toStringAsFixed(1)}%',
                      subtitle: 'Biometric precision',
                      color: AppColors.accentNeon,
                      icon: Icons.auto_awesome,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      title: 'CALORIES BURNED',
                      value: '${_dashboard.totalCalories.toInt()} kcal',
                      subtitle: 'Total metabolic burn',
                      color: AppColors.warningOrange,
                      icon: Icons.local_fire_department,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Chart Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.surfaceCard),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weekly Performance Trend',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 14),

                    // Metric Switcher Chips
                    SizedBox(
                      height: 32,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _metricTabs.length,
                        itemBuilder: (context, idx) {
                          final isSelected = _selectedMetricIndex == idx;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(
                                _metricTabs[idx],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.bgDark,
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : AppColors.surfaceCard,
                              ),
                              onSelected: (_) => setState(() => _selectedMetricIndex = idx),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // fl_chart Line Chart
                    SizedBox(
                      height: 190,
                      child: LineChart(_buildChartData()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent Workouts History
              const Text(
                'Recent Workout History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              if (_dashboard.recentSessions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No sessions logged yet. Complete your first workout!', style: TextStyle(color: AppColors.textMuted)),
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
                      border: Border.all(color: AppColors.surfaceCard),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.workoutType,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${session.completedAt} • ${(session.totalDurationSec / 60).toStringAsFixed(1)} min • ${session.totalCalories.toInt()} kcal',
                                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accentNeon.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${session.avgFormScore.toInt()}% Form',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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

  LineChartData _buildChartData() {
    final trend = _dashboard.weeklyFormTrend;
    List<FlSpot> spots = [];

    for (int i = 0; i < trend.length; i++) {
      double yVal = 0;
      if (_selectedMetricIndex == 0) {
        yVal = trend[i].formScore;
      } else if (_selectedMetricIndex == 1) {
        yVal = trend[i].reps.toDouble();
      } else {
        yVal = trend[i].calories;
      }
      spots.add(FlSpot(i.toDouble(), yVal));
    }

    Color lineColor = _selectedMetricIndex == 0
        ? AppColors.accentNeon
        : (_selectedMetricIndex == 1 ? AppColors.primary : AppColors.warningOrange);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _selectedMetricIndex == 0 ? 10 : (_selectedMetricIndex == 1 ? 20 : 100),
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppColors.surfaceCard.withValues(alpha: 0.5),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            interval: 1,
            getTitlesWidget: (value, meta) {
              int idx = value.toInt();
              if (idx >= 0 && idx < trend.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    trend[idx].day,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 34,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (trend.length - 1).toDouble(),
      minY: _selectedMetricIndex == 0 ? 60 : 0,
      maxY: _selectedMetricIndex == 0 ? 100 : (_selectedMetricIndex == 1 ? 100 : 450),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: lineColor,
          barWidth: 3.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
              radius: 4,
              color: Colors.white,
              strokeWidth: 2,
              strokeColor: lineColor,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                lineColor.withValues(alpha: 0.35),
                lineColor.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}
