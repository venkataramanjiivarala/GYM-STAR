import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/api_service.dart';
import '../models/user_profile_model.dart';

class ProfilePlanModal extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile) onProfileUpdated;

  const ProfilePlanModal({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
  });

  @override
  State<ProfilePlanModal> createState() => _ProfilePlanModalState();
}

class _ProfilePlanModalState extends State<ProfilePlanModal> {
  late TextEditingController _nameController;
  late String _fitnessLevel;
  late String _primaryGoal;
  late double _weight;
  late double _height;
  AiPersonalizedPlan? _aiPlan;
  bool _isGenerating = false;

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _goals = [
    'Strength & Muscle Tone',
    'Weight Loss & Fat Burn',
    'Flexibility & Yoga Balance',
    'Muscle Hypertrophy',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _fitnessLevel = widget.profile.fitnessLevel;
    _primaryGoal = widget.profile.primaryGoal;
    _weight = widget.profile.weightKg;
    _height = widget.profile.heightCm;
  }

  void _generatePlan() async {
    setState(() => _isGenerating = true);
    final updatedProfile = UserProfile(
      name: _nameController.text.trim().isEmpty ? 'Athlete' : _nameController.text.trim(),
      email: widget.profile.email,
      fitnessLevel: _fitnessLevel,
      primaryGoal: _primaryGoal,
      weightKg: _weight,
      heightCm: _height,
    );

    widget.onProfileUpdated(updatedProfile);
    final plan = await ApiService().generateAiPlan(updatedProfile);

    if (mounted) {
      setState(() {
        _aiPlan = plan;
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '👤 Athlete Profile & AI Plan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 16),

            // Name Input
            const Text('Athlete Name', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),

            // Fitness Level Dropdown
            const Text('Fitness Experience Tier', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _fitnessLevel,
                  isExpanded: true,
                  dropdownColor: AppColors.surfaceDark,
                  items: _levels.map((lvl) => DropdownMenuItem(value: lvl, child: Text(lvl, style: const TextStyle(color: Colors.white)))).toList(),
                  onChanged: (val) => setState(() => _fitnessLevel = val!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Primary Goal
            const Text('Primary Fitness Target', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _goals.contains(_primaryGoal) ? _primaryGoal : _goals.first,
                  isExpanded: true,
                  dropdownColor: AppColors.surfaceDark,
                  items: _goals.map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(color: Colors.white)))).toList(),
                  onChanged: (val) => setState(() => _primaryGoal = val!),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generatePlan,
                icon: _isGenerating
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.auto_awesome, color: Colors.white),
                label: Text(
                  _isGenerating ? 'Synthesizing Pathway...' : 'Generate 7-Day AI Pathway',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Generated Plan Section
            if (_aiPlan != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _aiPlan!.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _aiPlan!.coachTip,
                      style: const TextStyle(fontSize: 12.5, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Weekly Schedule',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              ..._aiPlan!.weeklySchedule.map((day) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceCard),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          day.day.substring(0, 3).toUpperCase(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day.focus,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${day.duration} • ${day.type} ${day.exercises.isNotEmpty ? '• ${day.exercises.join(', ')}' : ''}',
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
