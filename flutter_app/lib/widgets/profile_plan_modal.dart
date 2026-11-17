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
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late String _fitnessLevel;
  late String _primaryGoal;
  late int _preferredDuration;
  late String _availableEquipment;
  late bool _voiceCoaching;
  AiPersonalizedPlan? _aiPlan;
  bool _isSaving = false;
  bool _isSavedSuccess = false;

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _goals = [
    'Strength & Muscle Tone',
    'Weight Loss & Fat Burn',
    'Flexibility & Balance',
    'Muscle Hypertrophy',
    'Cardiovascular Endurance',
  ];
  final List<int> _durations = [15, 30, 45, 60];
  final List<String> _equipmentOptions = [
    'Bodyweight Only',
    'Dumbbells & Bands',
    'Full Home Gym',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _ageController = TextEditingController(text: widget.profile.age.toString());
    _weightController = TextEditingController(text: widget.profile.weightKg.toInt().toString());
    _heightController = TextEditingController(text: widget.profile.heightCm.toInt().toString());
    _fitnessLevel = widget.profile.fitnessLevel;
    _primaryGoal = widget.profile.primaryGoal;
    _preferredDuration = widget.profile.preferredDurationMin;
    _availableEquipment = widget.profile.availableEquipment;
    _voiceCoaching = widget.profile.voiceCoaching;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _saveAndGeneratePlan() async {
    setState(() => _isSaving = true);

    final updated = widget.profile.copyWith(
      name: _nameController.text.trim().isEmpty ? 'Athlete' : _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 26,
      weightKg: double.tryParse(_weightController.text.trim()) ?? 72.0,
      heightCm: double.tryParse(_heightController.text.trim()) ?? 175.0,
      fitnessLevel: _fitnessLevel,
      primaryGoal: _primaryGoal,
      preferredDurationMin: _preferredDuration,
      availableEquipment: _availableEquipment,
      voiceCoaching: _voiceCoaching,
    );

    widget.onProfileUpdated(updated);

    // Save to FastAPI backend
    await ApiService().updateUserProfile(updated);
    final plan = await ApiService().generateAiPlan(updated);

    if (mounted) {
      setState(() {
        _aiPlan = plan;
        _isSaving = false;
        _isSavedSuccess = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isSavedSuccess = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: AppColors.borderDark, width: 1.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header with Avatar
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.person_rounded, size: 32, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.accentNeon,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_rounded, size: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Athlete Profile & Goals',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Personalizes AI Coach recommendations & posture analytics',
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.borderDark, height: 1),
            const SizedBox(height: 18),

            // Name
            const Text('Athlete Full Name', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.bgDark,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.borderDark)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.borderDark)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 16),

            // Age, Weight, Height Grid
            Row(
              children: [
                Expanded(
                  child: _numberField('Age (years)', _ageController),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _numberField('Weight (kg)', _weightController),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _numberField('Height (cm)', _heightController),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Fitness Level
            const Text('Fitness Experience Tier', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Row(
              children: _levels.map((lvl) {
                final isSelected = _fitnessLevel == lvl;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(lvl),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _fitnessLevel = lvl),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.bgDark,
                      labelStyle: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.borderDark),
                      showCheckmark: false,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Primary Goal
            const Text('Primary Fitness Target', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _goals.map((goal) {
                final isSelected = _primaryGoal == goal;
                return ChoiceChip(
                  label: Text(goal),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _primaryGoal = goal),
                  selectedColor: AppColors.violet,
                  backgroundColor: AppColors.bgDark,
                  labelStyle: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: isSelected ? AppColors.violet : AppColors.borderDark),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Preferred Duration
            const Text('Preferred Workout Duration', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Row(
              children: _durations.map((dur) {
                final isSelected = _preferredDuration == dur;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text('$dur min'),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _preferredDuration = dur),
                      selectedColor: AppColors.streakOrange,
                      backgroundColor: AppColors.bgDark,
                      labelStyle: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: isSelected ? AppColors.streakOrange : AppColors.borderDark),
                      showCheckmark: false,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Equipment Available
            const Text('Available Equipment', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _equipmentOptions.map((equip) {
                final isSelected = _availableEquipment == equip;
                return ChoiceChip(
                  label: Text(equip),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _availableEquipment = equip),
                  selectedColor: AppColors.accentNeon,
                  backgroundColor: AppColors.bgDark,
                  labelStyle: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: isSelected ? AppColors.accentNeon : AppColors.borderDark),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Voice Coaching Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Real-Time Voice Coaching', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: const Text('Spoken form cues during reps', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                value: _voiceCoaching,
                activeThumbColor: AppColors.accentNeon,
                onChanged: (val) => setState(() => _voiceCoaching = val),
              ),
            ),
            const SizedBox(height: 22),

            // Save & Generate AI Pathway Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveAndGeneratePlan,
                icon: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(_isSavedSuccess ? Icons.check_circle_rounded : Icons.auto_awesome_rounded, color: Colors.white),
                label: Text(
                  _isSavedSuccess ? 'Profile Saved & Synchronized! ✓' : (_isSaving ? 'Syncing...' : 'Save & Generate AI Plan'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSavedSuccess ? AppColors.accentNeon : AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // AI Generated Weekly Schedule
            if (_aiPlan != null) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.bgDark,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bolt_rounded, color: AppColors.warningOrange, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _aiPlan!.title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _aiPlan!.coachTip,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                    ),
                    const SizedBox(height: 16),
                    ..._aiPlan!.weeklySchedule.map((day) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderDark),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(day.day, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
                                    Text(day.focus, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.white)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(day.duration, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentNeon)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _numberField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bgDark,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderDark)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderDark)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }
}
